#' Validate Pull Request
#'
#' Validates model output and model metadata files in a Pull Request.
#'
#' @param gh_repo GitHub repository address in the format `username/repo`
#' @param pr_number Number of the pull request to validate
#' @param round_id_col Character string. The name of the column containing
#' `round_id`s. Only required if files contain a column that contains `round_id`
#' details but has not been configured via `round_id_from_variable: true` and
#' `round_id:` in in hub `tasks.json` config file.
#' @param file_modify_check Character string. Whether to perform check and what to
#' return when modification/deletion of a previously submitted model output file
#' or deletion of a previously submitted model metadata file is detected in PR:
#' - `"error"`: Appends a `<error/check_error>` condition class object for each
#' applicable modified/deleted file.
#' - `"warning"`: Appends a `<warning/check_warning>` condition class object for each
#' applicable modified/deleted file.
#' - `"message"`: Appends a `<message/check_info>` condition class object for each
#' applicable modified/deleted file.
#' - `"none"`: No modification/deletion checks performed.
#' @param allow_submit_window_mods Logical. Whether to allow modifications/deletions
#' of model output files within their submission windows. Defaults to `TRUE`.
#' @inheritParams validate_model_file
#' @inheritParams validate_submission
#' @details
#' Only model output and model metadata files are individually validated using
#' `validate_submission()` with each file although as part of checks, hub config
#' files are also validated. Any other files included in the PR are ignored but
#' flagged in a message.
#'
#' By default, modifications and deletions of previously submitted model output
#' files and deletions of previously submitted model metadata files are not allowed
#' and return a `<error/check_error>` condition class object for each
#' applicable modified/deleted file. This behaviour can be modified through
#' arguments `file_modify_check`, which controls whether modification/deletion
#' checks are performed and what is returned if modifications/deletions are detected,
#' and `allow_submit_window_mods`, which controls whether modifications/deletions
#' of model output files are allowed within their submission windows.
#'
#' Note that to establish **relative** submission windows when performing
#' modification/deletion checks and `allow_submit_window_mods`
#' is `TRUE`, the reference date is taken as the `round_id` extracted from
#' the file path (i.e. `submit_window_ref_date_from` is always set to `"file_path"`).
#' This is because we cannot extract dates from columns of deleted
#' files. If hub submission window reference dates do not match round IDs in file paths,
#' currently `allow_submit_window_mods` will not work correctly and is best set
#' to `FALSE`. This only relates to hubs/rounds where submission windows are
#' determined relative to a reference date and not when explicit submission
#' window start and end dates are provided in the config.
#' @return An object of class `hub_validations`.
#' @export
#'
#' @examples
#' \dontrun{
#' validate_pr(
#'   hub_path = ".",
#'   gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
#'   pr_number = 3
#' )
#' }
validate_pr <- function(hub_path = ".", gh_repo, pr_number,
                        round_id_col = NULL, validations_cfg_path = NULL,
                        skip_submit_window_check = FALSE,
                        file_modify_check = c("error", "warn", "message", "none"),
                        allow_submit_window_mods = TRUE,
                        submit_window_ref_date_from = c(
                          "file",
                          "file_path"
                        )) {
  file_modify_check <- rlang::arg_match(file_modify_check)
  model_output_dir <- get_hub_model_output_dir(hub_path)
  model_metadata_dir <- "model-metadata"
  validations <- new_hub_validations()

  validations$valid_config <- try_check(check_config_hub_valid(hub_path),
    file_path = basename(hub_path)
  )
  if (is_any_error(validations$valid_config)) {
    return(validations)
  }

  tryCatch(
    {
      pr_files <- gh::gh(
        "/repos/{gh_repo}/pulls/{pr_number}/files",
        gh_repo = gh_repo,
        pr_number = pr_number
      )
      pr_df <- tibble::tibble(
        filename = purrr::map_chr(pr_files, ~ .x$filename),
        status = purrr::map_chr(pr_files, ~ .x$status),
        model_output = purrr::map_lgl(
          .data$filename,
          ~ fs::path_has_parent(.x, model_output_dir) &&
            stringr::str_detect(.x, "README", negate = TRUE)
        ),
        model_metadata = purrr::map_lgl(
          .data$filename,
          ~ fs::path_has_parent(.x, model_metadata_dir) &&
            stringr::str_detect(.x, "README", negate = TRUE)
        ),
      ) %>%
        dplyr::mutate(
          rel_path = dplyr::case_when(
            .data$model_output ~ fs::path_rel(.data$filename, model_output_dir),
            .data$model_metadata ~ fs::path_rel(.data$filename, model_metadata_dir),
            .default = .data$filename
          ),
          hub_path = hub_path
        )
      inform_unvalidated_files(pr_df)

      model_output_files <- pr_df$rel_path[pr_df$model_output &
        pr_df$status != "removed"]
      model_metadata_files <- pr_df$rel_path[pr_df$model_metadata &
        pr_df$status != "removed"]

      if (file_modify_check != "none") {
        file_modifications <- purrr::map(
          c("model_output", "model_metadata"),
          ~ check_pr_modf_del_files(
            pr_df,
            file_type = .x,
            alert = file_modify_check,
            allow_submit_window_mods = allow_submit_window_mods
          )
        ) %>%
          purrr::reduce(combine)
      } else {
        file_modifications <- NULL
      }


      model_output_vals <- purrr::map(
        model_output_files,
        ~ validate_submission(
          hub_path,
          file_path = .x,
          validations_cfg_path = validations_cfg_path,
          skip_submit_window_check = skip_submit_window_check,
          skip_check_config = TRUE
        )
      ) %>%
        purrr::list_flatten() %>%
        as_hub_validations()

      model_metadata_vals <- purrr::map(
        model_metadata_files,
        ~ validate_model_metadata(
          hub_path,
          file_path = .x,
          validations_cfg_path = validations_cfg_path
        )
      ) %>%
        purrr::list_flatten() %>%
        as_hub_validations()


      validations <- combine(
        validations,
        file_modifications,
        model_output_vals,
        model_metadata_vals
      )
    },
    error = function(e) {
      # This handler is used when an unrecoverable error is thrown. This can
      # happen when, e.g., the csv file cannot be parsed by read_csv(). In this
      # situation, we want to output all the validations until this point plus
      # this "unrecoverable" error.
      e <- capture_exec_error(
        file_path = gh_repo,
        msg = conditionMessage(e)
      )
      validations <<- combine(
        validations,
        new_hub_validations(e)
      )
    }
  )
  return(validations)
}

# Sends message reporting any files with changes in PR that were not validated.
inform_unvalidated_files <- function(pr_df) {
  unvalidated_files <- pr_df[!pr_df$model_output & !pr_df$model_metadata,
    "filename",
    drop = TRUE
  ]
  if (length(unvalidated_files) == 0L) {
    return(invisible(NULL))
  }

  unvalidated_bullets <- sprintf("{.val %s}", unvalidated_files) %>%
    purrr::set_names(rep("*", length(unvalidated_files)))

  cli::cli_inform(
    c(
      "i" = "PR contains commits to additional files which have not been checked:",
      unvalidated_bullets, "\n"
    )
  )
}
# Checks for model output file modifications and model output & model metadata
# file deletions. Returns an <error/check_error>⁠ condition class object if any
# modification or deletion detected.
check_pr_modf_del_files <- function(pr_df, file_type = c(
                                      "model_output",
                                      "model_metadata"
                                    ),
                                    alert = c("message", "warn", "error"),
                                    allow_submit_window_mods = TRUE) {
  file_type <- rlang::arg_match(file_type)
  alert <- rlang::arg_match(alert)

  # subset pr_df to the file type beiing checked. We check model output and model
  # metadata files separately as model metadata files are only check for deletions.
  # Also, they have no submission window so deletions are not affected by
  # allow_submit_window_mods
  df <- pr_df[pr_df[[file_type]], ]

  # Subset to files whose modification/deletion is not allowed and needs reporting.
  df <- switch(file_type,
    model_output = df[df$status %in% c("removed", "modified", "renamed"), ],
    model_metadata = df[df$status %in% c("removed", "renamed"), ]
  )
  if (nrow(df) == 0L) {
    return(new_hub_validations())
  }
  # Check whether modifications allowed and return notification object according
  # to alert for any file that violates allowed mod/del.
  out <- purrr::map(
    .x = 1:nrow(df),
    ~ check_pr_modf_del_file(
      df_row = df[.x, ],
      file_type = file_type,
      allow_submit_window_mods = allow_submit_window_mods,
      alert = alert
    )
  ) %>%
    purrr::compact()

  as_hub_validations(out) %>%
    purrr::set_names(sprintf("%s_mod_%i", file_type, seq_along(out)))
}


# Check individual file for non-allowed modification/deletion and return appropriate
# notification object according to alert
check_pr_modf_del_file <- function(df_row, file_type, allow_submit_window_mods,
                                   alert) {

  # If mods/dels allowed within submission window and file_type == "model_output",
  #  try checking whether file is within their submission window.
  if (allow_submit_window_mods && file_type == "model_output") {
    allow_mod <- try(
      file_within_submission_window(
        hub_path = df_row$hub_path,
        file_path = df_row$rel_path,
        ref_date_from = "file_path"
      ),
      silent = TRUE
    )
    # If check fails return exec error class object
    if (inherits(allow_mod, "try-error")) {
      msg <- as.character(allow_mod) %>%
        cli::ansi_strip() %>%
        clean_msg()
      return(
        capture_exec_error(
          file_path = df_row$rel_path,
          msg = cli::format_inline(
            sprintf(
              "Could not check submission window for file {.val %s}. EXEC ERROR: %s",
              df_row$rel_path,
              msg
            )
          )
        )
      )
    }
    # If within submission window, return NULL
    if (allow_mod) {
      return(NULL)
    }
  }

  # The type of object returned depends on argument alert, which is passed down
  # from validate_pr argument file_modify_check
  if (alert == "message") {
    return(
      capture_check_info(
        file_path = df_row$rel_path,
        msg = cli::format_inline(
          "Previously submitted {stringr::str_replace(file_type, '_', ' ')} file
          {.path {df_row$filename}} {df_row$status}."
        )
      )
    )
  } else {
    error <- alert == "error"
    return(
      capture_check_cnd(
        check = FALSE,
        file_path = df_row$rel_path,
        msg_subject = paste(
          "Previously submitted",
          stringr::str_replace(file_type, "_", " "),
          "files"
        ),
        msg_verbs = c("were not", "must not be"),
        msg_attribute = paste0(df_row$status, "."),
        details = cli::format_inline(
          "{.path {df_row$filename}} {df_row$status}."
        ),
        error = error
      )
    )
  }
}
