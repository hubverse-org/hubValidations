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
#' @param file_modification_check Character string. Whether to perform check and what to
#' return when modification/deletion of a previously submitted model output file
#' or deletion of a previously submitted model metadata file is detected in PR:
#' - `"error"`: Appends a `<error/check_error>` condition class object for each
#' applicable modified/deleted file.
#' - `"warning"`: Appends a `<error/check_failure>` condition class object for each
#' applicable modified/deleted file.
#' - `"message"`: Appends a `<message/check_info>` condition class object for each
#' applicable modified/deleted file.
#' - `"none"`: No modification/deletion checks performed.
#' @param allow_submit_window_mods Logical. Whether to allow modifications/deletions
#' of model output files within their submission windows. Defaults to `TRUE`.
#' @inheritParams validate_model_file
#' @inheritParams validate_submission
#' @details
#'
#' Only model output and model metadata files are individually validated using
#' `validate_submission()` or `validate_model_metadata()` respectively although
#' as part of checks, hub config files are also validated.
#' Any other files included in the PR are ignored but flagged in a message.
#'
#' By default, modifications (which include renaming) and deletions of
#' previously submitted model output files and deletions or renaming of
#' previously submitted model metadata files are not allowed
#' and return a `<error/check_error>` condition class object for each
#' applicable modified/deleted file. This behaviour can be modified through
#' arguments `file_modification_check`, which controls whether modification/deletion
#' checks are performed and what is returned if modifications/deletions are detected,
#' and `allow_submit_window_mods`, which controls whether modifications/deletions
#' of model output files are allowed within their submission windows.
#'
#' When modification/deletion checks are enabled, each affected file creates an
#' entry in the returned collection named by the file's path. The check within
#' each entry is named `valid_file_status` (reflecting that we validate the
#' file's git status).
#' For example, to access the check for a deleted file:
#' `collection[["team1-goodmodel/2022-10-15-team1-goodmodel.csv"]][["valid_file_status"]]`.
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
#'
#' Finally, note that it is **necessary for `derived_task_ids` to be specified if any
#' task IDs with `required` values have dependent derived task IDs**. If this
#' is the case and derived task IDs are not specified, the dependent nature of
#' derived task ID values will result in **false validation errors when
#' validating required values**.
#'
#' ### Checks on model output files
#'
#' Details of checks performed by `validate_submission()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations"))  |>
#' dplyr::filter(
#'  .data$`parent fun` %in% c(
#'                              "validate_submission_time",
#'                              "validate_model_file",
#'                              "validate_model_data"
#'                            ) |
#'  .data$`check fun` == "check_config_hub_valid",
#'  !.data$optional
#'  )  |>
#'   dplyr::select(-"parent fun", -"check fun", -"optional")  |>
#'   dplyr::mutate("Extra info" = dplyr::case_when(
#'     is.na(.data$`Extra info`) ~ "",
#'     TRUE ~ .data$`Extra info`
#'   ))  |>
#'   knitr::kable()  |>
#'   kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"))  |>
#'   kableExtra::column_spec(1, bold = TRUE)
#' ```
#'
#' ### Checks on model metadata files
#'
#' Details of checks performed by `validate_model_metadata()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations"))  |>
#' dplyr::filter(.data$`parent fun` == "validate_model_metadata")  |>
#'   dplyr::select(-"parent fun", -"check fun")  |>
#'   dplyr::mutate("Extra info" = dplyr::case_when(
#'     is.na(.data$`Extra info`) ~ "",
#'     TRUE ~ .data$`Extra info`
#'   ))  |>
#'   knitr::kable()  |>
#'   kableExtra::kable_styling(
#'      bootstrap_options = c(
#'          "striped", "hover", "condensed", "responsive"
#'        )
#'      )  |>
#'   kableExtra::column_spec(1, bold = TRUE)
#' ```
#' @return An object of class `hub_validations_collection`, a collection of
#'   validation results. The collection includes entries for hub config
#'   validation (`"hub-config"`) and file-specific validations (named by
#'   file path).
#' @export
#'
#' @examples
#' \dontrun{
#' validate_pr(
#'   hub_path = ".",
#'   gh_repo = "hubverse-org/ci-testhub-simple",
#'   pr_number = 3
#' )
#' }
validate_pr <- function(
  hub_path = ".",
  gh_repo,
  pr_number,
  round_id_col = NULL,
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  validations_cfg_path = NULL,
  skip_submit_window_check = FALSE,
  file_modification_check = c(
    "error",
    "failure",
    "warn",
    "message",
    "none"
  ),
  allow_submit_window_mods = TRUE,
  submit_window_ref_date_from = c(
    "file",
    "file_path"
  ),
  derived_task_ids = NULL
) {
  file_modification_check <- rlang::arg_match(file_modification_check)
  if (file_modification_check == "warn") {
    lifecycle::deprecate_warn(
      "0.6.1",
      "validate_pr(file_modification_check = 'will not accept option `warn` in
      future versions. Use `failure` instead')"
    )
    file_modification_check <- "failure"
  }
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
  model_output_dir <- get_hub_model_output_dir(hub_path) # nolint: object_name_linter
  model_metadata_dir <- "model-metadata" # nolint: object_name_linter

  # Check hub config first - return early if invalid
  config_validations <- new_hub_validations(
    valid_config = try_check(
      check_config_hub_valid(hub_path),
      file_path = "hub-config"
    )
  )
  if (is_any_error(config_validations)) {
    return(new_hub_validations_collection(config_validations))
  }

  # nolint next: object_usage_linter
  file_validations <- tryCatch(
    {
      pr_files <- gh::gh(
        "/repos/{gh_repo}/pulls/{pr_number}/files",
        gh_repo = gh_repo,
        pr_number = pr_number,
        per_page = 100,
        .limit = Inf
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
      ) |>
        dplyr::mutate(
          rel_path = dplyr::case_when(
            .data$model_output ~ fs::path_rel(.data$filename, model_output_dir),
            .data$model_metadata ~
              fs::path_rel(.data$filename, model_metadata_dir),
            .default = .data$filename
          ),
          hub_path = hub_path
        )
      inform_unvalidated_files(pr_df)

      # Check for config file modifications
      config_warning <- check_pr_config_modified(pr_df)

      model_output_files <- pr_df$rel_path[
        pr_df$model_output & pr_df$status != "removed"
      ]
      model_metadata_files <- pr_df$rel_path[
        pr_df$model_metadata & pr_df$status != "removed"
      ]

      # Validate model output files (returns collections)
      model_output_collections <- purrr::map(
        model_output_files,
        \(.x) {
          validate_submission(
            hub_path,
            file_path = .x,
            output_type_id_datatype = output_type_id_datatype,
            validations_cfg_path = validations_cfg_path,
            skip_submit_window_check = skip_submit_window_check,
            derived_task_ids = derived_task_ids,
            skip_check_config = TRUE
          )
        }
      )

      # Validate model metadata files (returns hub_validations, wrap in collections)
      model_metadata_collections <- purrr::map(
        model_metadata_files,
        \(.x) {
          new_hub_validations_collection(
            validate_model_metadata(
              hub_path,
              file_path = .x,
              validations_cfg_path = validations_cfg_path
            )
          )
        }
      )

      # Check for file modifications/deletions (returns collections)
      mod_collections <- if (file_modification_check != "none") {
        purrr::map(
          c("model_output", "model_metadata"),
          \(.x) {
            check_valid_files_status(
              pr_df,
              file_type = .x,
              alert = file_modification_check,
              allow_submit_window_mods = allow_submit_window_mods
            )
          }
        )
      } else {
        NULL
      }

      # Combine all collections
      all_collections <- c(
        list(new_hub_validations_collection(config_validations)),
        model_output_collections,
        model_metadata_collections,
        mod_collections
      )
      result <- purrr::reduce(all_collections, combine)
      if (!is.null(config_warning)) {
        attr(result, "warnings") <- list(config_warning)
      }
      result
    },
    error = function(e) {
      # This handler is used when an unrecoverable error is thrown. This can
      # happen when, e.g., the csv file cannot be parsed by read_csv(). In this
      # situation, we want to output all the validations until this point plus
      # this "unrecoverable" error.
      exec_error <- capture_exec_error(
        file_path = paste0(gh_repo, "#", pr_number),
        msg = conditionMessage(e)
      )
      error_validations <- new_hub_validations(exec_error = exec_error)
      as_hub_validations_collection(list(config_validations, error_validations))
    }
  )
}

# Sends message reporting any files with changes in PR that were not validated.
inform_unvalidated_files <- function(
  pr_df,
  filetypes_to_validate = c("model_output", "model_metadata")
) {
  ignore <- rowSums(pr_df[filetypes_to_validate]) == 0L
  ignored_files <- pr_df[["filename"]][ignore]
  if (length(ignored_files) == 0L) {
    return(invisible(NULL))
  }

  ignored_bullets <- sprintf("{.val %s}", ignored_files) |>
    purrr::set_names(rep("*", length(ignored_files)))

  cli::cli_inform(
    c(
      "i" = "PR contains commits to additional files which have not been checked:",
      ignored_bullets,
      "\n"
    )
  )
}
# Check that the git status of files in a PR is valid (i.e., files have not been
# modified, deleted, or renamed when not allowed). Returns a hub_validations_collection
# (or target_validations_collection for target file types).
# The check name "valid_file_status" reflects that we're validating the git status.
# The check class returned (check_info, check_failure, or check_error) depends on
# the user's `file_modification_check` setting.
check_valid_files_status <- function(
  pr_df,
  file_type = c(
    "model_output", # nolint
    "model_metadata",
    "timeseries",
    "oracle_output"
  ),
  alert = c("message", "failure", "error"),
  allow_submit_window_mods = TRUE
) {
  file_type <- rlang::arg_match(file_type)
  alert <- rlang::arg_match(alert)
  is_target <- file_type %in% c("timeseries", "oracle_output")

  # subset pr_df to the file type being checked. We check model output and model
  # metadata files separately as model metadata files are only checked for
  # deletions/renaming.
  # Also, they have no submission window so deletions are not affected by
  # allow_submit_window_mods
  df <- pr_df[pr_df[[file_type]], ]

  # Subset to files whose modification/deletion is not allowed and needs reporting.
  df <- switch(
    file_type,
    model_output = df[df$status %in% c("removed", "modified", "renamed"), ],
    df[df$status %in% c("removed", "renamed"), ]
  )
  if (nrow(df) == 0L) {
    if (is_target) {
      return(new_target_validations_collection())
    } else {
      return(new_hub_validations_collection())
    }
  }

  # Check each file and wrap in validations (collection merger handles grouping)
  validations <- purrr::map(
    seq_len(nrow(df)),
    \(.x) {
      df_row <- df[.x, ]
      check <- check_valid_file_status(
        df_row = df_row,
        file_type = file_type,
        allow_submit_window_mods = allow_submit_window_mods,
        alert = alert
      )
      if (is.null(check)) {
        return(NULL)
      }
      if (is_target) {
        new_target_validations(valid_file_status = check)
      } else {
        new_hub_validations(valid_file_status = check)
      }
    }
  ) |>
    purrr::compact()

  if (is_target) {
    as_target_validations_collection(validations)
  } else {
    as_hub_validations_collection(validations)
  }
}


# Check that the git status of an individual file is valid. Returns the appropriate
# check object based on the alert setting, or NULL if the change is allowed.
check_valid_file_status <- function(
  df_row,
  file_type,
  allow_submit_window_mods,
  alert
) {
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
      msg <- as.character(allow_mod) |>
        cli::ansi_strip() |>
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
  # from validate_pr argument file_modification_check
  if (alert == "message") {
    capture_check_info(
      file_path = df_row$rel_path,
      msg = cli::format_inline(
        "Previously submitted {stringr::str_replace(file_type, '_', ' ')} file
          {.path {df_row$filename}} {df_row$status}."
      )
    )
  } else {
    error <- alert == "error"
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
  }
}

# Check for config file modifications in a PR and return a warning if found.
# Returns an exec_warning condition object if config files modified, NULL otherwise.
check_pr_config_modified <- function(pr_df) {
  config_dir <- "hub-config"

  # Identify config files that were modified (not just added)
  config_files <- pr_df$filename[
    fs::path_has_parent(pr_df$filename, config_dir) &
      pr_df$status %in% c("modified", "renamed")
  ]

  if (length(config_files) == 0L) {
    return(NULL)
  }

  capture_validation_warning(
    msg = cli::format_inline(
      "Hub config file{?s} modified: {.path {basename(config_files)}}.
      Config changes may affect validation of existing model output and
      target data. Please review carefully for consistency."
    ),
    where = config_dir,
    config_files = config_files
  )
}
