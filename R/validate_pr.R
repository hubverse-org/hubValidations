#' Validate Pull Request
#'
#' @param gh_repo GitHub repository address in the format `username/repo`
#' @param pr_number Number of the pull request to validate
#' @param round_id_col Character string. The name of the column containing
#' `round_id`s. Only required if files contain a column that contains `round_id`
#' details but has not been configured via `round_id_from_variable: true` and
#' `round_id:` in in hub `tasks.json` config file.
#' @inheritParams validate_model_file
#' @inheritParams validate_submission
#'
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
                        skip_submit_window_check = FALSE) {
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
          )
        )
      inform_unvalidated_files(pr_df)

      model_output_files <- pr_df$rel_path[pr_df$model_output &
        pr_df$status != "removed"]
      model_metadata_files <- pr_df$rel_path[pr_df$model_metadata &
        pr_df$status != "removed"]

      file_modifications <- purrr::map(
        c("model_output", "model_metadata"),
        ~ check_pr_modf_del_files(pr_df, file_type = .x)
      ) %>%
        purrr::reduce(combine)

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
  unvalidated_files <- pr_df[!pr_df$model_output & !pr_df$model_metadata, "filename", drop = TRUE]
  if (length(unvalidated_files) == 0L) {
    return(invisible(NULL))
  }

  unvalidated_bullets <- purrr::map_chr(
    unvalidated_files,
    ~ paste0("{.val ", .x, "}")
  ) %>%
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
                                    )) {
  file_type <- rlang::arg_match(file_type)
  df <- pr_df[pr_df[[file_type]], ]
  df <- switch(file_type,
    model_output = df[df$status %in% c("removed", "modified"), ],
    model_metadata = df[df$status == "removed", ]
  )

  purrr::imap(
    .x = df$rel_path,
    ~ hubValidations::capture_check_cnd(
      check = FALSE,
      file_path = .x,
      msg_subject = paste(
        "Previously submitted",
        stringr::str_replace(file_type, "_", " "),
        "files"
      ),
      msg_verbs = c("were not", "must not be"),
      msg_attribute = paste0(df$status[.y], "."),
      details = cli::format_inline(
        "{.path {df$filename[.y]}} {df$status[.y]}."
      ),
      error = TRUE
    )
  ) %>%
    hubValidations::as_hub_validations()
}
