#' Validate Target Data Pull Request
#'
#' Validates target data files in a Pull Request.
#'
#' @param gh_repo GitHub repository address in the format `username/repo`
#' @param pr_number Number of the pull request to validate
#' @param file_modification_check Character string. Whether to perform check and what to
#' return when modification/deletion of a previously submitted target data file is detected in PR:
#' - `"none"`: No modification/deletion checks performed.
#' - `"message"`: Appends a `<message/check_info>` condition class object for each
#' applicable modified/deleted file.
#' - `"failure"`: Appends a `<error/check_failure>` condition class object for each
#' applicable modified/deleted file.
#' - `"error"`: Appends a `<error/check_error>` condition class object for each
#' applicable modified/deleted file.
#'
#' Defaults to `"none`".
#' @param allow_target_type_deletion Logical. Whether to allow deletion of an entire
#' target type dataset (i.e. all files of a target type) in the PR. Defaults to `FALSE`.
#' @inheritParams validate_target_dataset
#' @inheritParams validate_target_submission
#' @details
#'
#' Only target data files are individually validated using
#' `validate_target_submission()` although as part of checks, hub config files and
#' any affected target type datasets as a whole are also validated via
#' `validate_target_dataset()`.
#' Any other files included in the PR are ignored but flagged in a message.
#'
#' By default, modifications (which include renaming) and deletions of
#' previously submitted target data files are allowed.
#' This behaviour can be modified through
#' arguments `file_modification_check`, which controls whether modification/deletion
#' checks are performed and what is returned if modifications/deletions are detected.
#'
#'
#' ### Checks on target dataset
#'
#' Details of checks performed by `validate_target_dataset()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations")) %>%
#' dplyr::filter(
#'  .data$`parent fun` == "validate_target_dataset" |
#'  .data$`check fun` == "check_config_hub_valid",
#'  !.data$optional
#'  ) %>%
#'   dplyr::select(-"parent fun", -"check fun", -"optional") %>%
#'   dplyr::mutate("Extra info" = dplyr::case_when(
#'     is.na(.data$`Extra info`) ~ "",
#'     TRUE ~ .data$`Extra info`
#'   )) %>%
#'   knitr::kable() %>%
#'   kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) %>%
#'   kableExtra::column_spec(1, bold = TRUE)
#' ```
#'
#' ### Checks on individual target files
#'
#' Details of checks performed by `validate_target_submission()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations")) %>%
#' dplyr::filter(.data$`parent fun` %in% c(
#'                                          "validate_target_file",
#'                                          "validate_target_data"
#'                                        )
#'              ) %>%
#'   dplyr::select(-"parent fun", -"check fun") %>%
#'   dplyr::mutate("Extra info" = dplyr::case_when(
#'     is.na(.data$`Extra info`) ~ "",
#'     TRUE ~ .data$`Extra info`
#'   )) %>%
#'   knitr::kable() %>%
#'   kableExtra::kable_styling(
#'      bootstrap_options = c(
#'          "striped", "hover", "condensed", "responsive"
#'        )
#'      ) %>%
#'   kableExtra::column_spec(1, bold = TRUE)
#' ```
#' @return An object of class `target_validations`.
#' @export
#'
#' @examples
#' \dontrun{
#' tmp_dir <- withr::local_tempdir()
#' ci_target_hub_path <- fs::path(tmp_dir, "target")
#' gert::git_clone(
#'   url = "https://github.com/hubverse-org/ci-testhub-target.git",
#'   path = ci_target_hub_path
#' )
#' # Validate addition of single file in single file target dataset
#' gert::git_branch_checkout(
#'   "add-file-oracle-output",
#'   repo = ci_target_hub_path
#' )
#' validate_target_pr(
#'   hub_path = ci_target_hub_path,
#'   gh_repo = "hubverse-org/ci-testhub-target",
#'   pr_number = 1
#' )
#' # Validate addition of multiple files in partitioned target dataset
#' gert::git_branch_checkout(
#'   "add-target-dir-files-v5",
#'   repo = ci_target_hub_path
#' )
#' validate_target_pr(
#'   hub_path = ci_target_hub_path,
#'   gh_repo = "hubverse-org/ci-testhub-target",
#'   pr_number = 2
#' )
#' }
validate_target_pr <- function(
  hub_path = ".",
  gh_repo,
  pr_number,
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  date_col = NULL,
  allow_extra_dates = FALSE,
  na = c("NA", ""),
  round_id = "default",
  validations_cfg_path = NULL,
  file_modification_check = c("none", "message", "failure", "error"),
  allow_target_type_deletion = FALSE
) {
  checkmate::assert_string(date_col, null.ok = TRUE)
  file_modification_check <- rlang::arg_match(file_modification_check)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
  target_data_dir <- "target-data" # nolint: object_name_linter
  filetypes_to_validate <- c("timeseries", "oracle_output")

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
        timeseries = purrr::map_lgl(
          .data$filename,
          ~ is_target_type_file(.x, "time-series")
        ),
        oracle_output = purrr::map_lgl(
          .data$filename,
          ~ is_target_type_file(.x, "oracle-output")
        ),
      ) %>%
        dplyr::mutate(
          rel_path = dplyr::case_when(
            .data$timeseries | .data$oracle_output ~
              fs::path_rel(.data$filename, target_data_dir),
            .default = .data$filename
          ),
          hub_path = hub_path
        )
      inform_unvalidated_files(pr_df, filetypes_to_validate)

      validations <- new_target_validations()

      # Return early if no target data files in PR
      if (!any(c(pr_df$timeseries, pr_df$oracle_output))) {
        cli::cli_alert_info(
          "No changes to target data files in PR #{pr_number} of {gh_repo}.
          Checks skipped."
        )
        return(validations)
      }

      # Check config before proceeding
      validations$valid_config <- try_check(
        check_config_hub_valid(hub_path),
        file_path = basename(hub_path)
      )
      if (is_any_error(validations$valid_config)) {
        return(validations)
      }

      # When config exists, ignore user-provided date_col and use config value
      # (schema creation functions will extract it from config)
      if (hubUtils::has_target_data_config(hub_path)) {
        date_col <- NULL
      }

      if (file_modification_check != "none") {
        file_modifications <- purrr::map(
          filetypes_to_validate,
          ~ check_pr_modf_del_files(
            pr_df,
            file_type = .x,
            alert = file_modification_check,
            allow_submit_window_mods = FALSE
          )
        ) %>%
          purrr::reduce(combine)
      } else {
        file_modifications <- NULL
      }

      # Validate time-series data files ====
      # If any time-series files are included in the PR, even if removed, validate the
      # entire time-series target dataset once
      skip_dataset_check <- skip_ds_check(
        hub_path,
        target_type = "time-series",
        allow_target_type_deletion = allow_target_type_deletion
      )
      # If deletion of an entire dataset is allowed and there are no files of the
      # target_type left in the hub, skip the dataset check. Otherwise will return
      # a check error
      if (any(pr_df$timeseries) && !skip_dataset_check) {
        ts_dataset_vals <- try_check(
          validate_target_dataset(
            hub_path,
            target_type = "time-series",
            validations_cfg_path = validations_cfg_path,
            round_id = round_id
          ),
          file_path = "time-series"
        )
      } else {
        ts_dataset_vals <- NULL
      }
      # Validate individual time-series files but only if not removed
      ts_files <- pr_df$rel_path[
        pr_df$timeseries & pr_df$status != "removed"
      ]
      if (length(ts_files) > 0L) {
        ts_vals <- purrr::map(
          ts_files,
          ~ validate_target_submission(
            hub_path,
            file_path = .x,
            target_type = "time-series",
            date_col = date_col,
            allow_extra_dates = allow_extra_dates,
            na = na,
            output_type_id_datatype = output_type_id_datatype,
            validations_cfg_path = validations_cfg_path,
            round_id = round_id,
            skip_check_config = TRUE
          )
        ) %>%
          purrr::list_flatten() %>%
          as_target_validations()
      } else {
        ts_vals <- NULL
      }

      # Validate oracle-output data ====
      # If any oracle-output files are included in the PR, even if removed, validate the
      # entire oracle-output target dataset once
      skip_dataset_check <- skip_ds_check(
        hub_path,
        target_type = "oracle-output",
        allow_target_type_deletion = allow_target_type_deletion
      )
      # If deletion of an entire dataset is allowed and there are no files of the
      # target_type left in the hub, skip the dataset check. Otherwise will return
      # a check error
      if (any(pr_df$oracle_output) && !skip_dataset_check) {
        oo_dataset_vals <- try_check(
          validate_target_dataset(
            hub_path,
            target_type = "oracle-output",
            validations_cfg_path = validations_cfg_path,
            round_id = round_id
          ),
          file_path = "oracle-output"
        )
      } else {
        oo_dataset_vals <- NULL
      }
      # Validate individual time-series files but only if not removed
      oo_files <- pr_df$rel_path[
        pr_df$oracle_output & pr_df$status != "removed"
      ]
      if (length(oo_files) > 0L) {
        oo_vals <- purrr::map(
          oo_files,
          ~ validate_target_submission(
            hub_path,
            file_path = .x,
            target_type = "oracle-output",
            date_col = date_col,
            allow_extra_dates = allow_extra_dates,
            na = na,
            output_type_id_datatype = output_type_id_datatype,
            validations_cfg_path = validations_cfg_path,
            round_id = round_id,
            skip_check_config = TRUE
          )
        ) %>%
          purrr::list_flatten() %>%
          as_target_validations()
      } else {
        oo_vals <- NULL
      }

      validations <- combine(
        validations,
        file_modifications,
        ts_dataset_vals,
        ts_vals,
        oo_dataset_vals,
        oo_vals
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

# Check if file is a standalone target data file named exactly as the target type.
# For example: "time-series.csv" or "oracle-output.parquet"
is_target_type_single_file <- function(
  path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)

  file_name <- fs::path_ext_remove(fs::path_file(path)) # filename without extension
  ext <- fs::path_ext(path) # extension
  file_name == target_type && ext %in% c("csv", "parquet")
}

# Check if file lives inside a target-data/<target_type>/ directory (any depth),
# but exclude README files which are not data files.
is_target_type_dir_file <- function(
  path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  fs::path_has_parent(path, fs::path("target-data", target_type)) &&
    stringr::str_detect(path, "README", negate = TRUE)
}

# Determine whether a file path corresponds to a target data file of a given
# target type.
#
# This function checks if the given path represents either:
# - a standalone target data file (e.g. `time-series.csv`, `oracle-output.parquet`), or
# - a file inside a `target-data/<target_type>/` directory, excluding README files.
#
# Used to classify pull request files based on their relation to specific target types.
is_target_type_file <- function(
  path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  is_target_type_single_file(path, target_type) ||
    is_target_type_dir_file(path, target_type)
}

# Determine whether to skip target dataset checks
skip_ds_check <- function(
  hub_path,
  target_type = c("time-series", "oracle-output"),
  allow_target_type_deletion = FALSE
) {
  target_type <- rlang::arg_match(target_type)
  no_ts <- length(hubData::get_target_path(hub_path, target_type)) == 0L
  no_ts && allow_target_type_deletion
}
