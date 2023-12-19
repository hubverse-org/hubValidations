#' Validate a submitted model data file. Checks both file level properties like
#' file name, extension, location etc as well as model output data, i.e. the contents
#' of the file.
#'
#' @inherit validate_model_data return params
#' @param skip_submit_window_check Logical. Whether to skip the submission window check.
#' @param skip_check_config Logical. Whether to skip the hub config validation check.
#'  check.
#' @param submit_window_ref_date_from whether to get the reference date around
#' which relative submission windows will be determined from the file's
#' `file_path` round ID or the `file` contents themselves.
#' `file` requires that the file can be read.
#' Only applicable when a round is configured to determine the submission
#' windows relative to the value in a date column in model output files.
#' Not applicable when explicit submission window start and end dates are
#' provided in the hub's config.
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' validate_submission(hub_path, file_path)
validate_submission <- function(hub_path, file_path, round_id_col = NULL,
                                validations_cfg_path = NULL,
                                skip_submit_window_check = FALSE,
                                skip_check_config = FALSE,
                                submit_window_ref_date_from = c(
                                  "file",
                                  "file_path"
                                )) {
  check_hub_config <- new_hub_validations()
  if (!skip_check_config) {
    check_hub_config$valid_config <- try_check(
      check_config_hub_valid(hub_path),
      file_path
    )
    if (not_pass(check_hub_config$valid_config)) {
      return(check_hub_config)
    }
  }

  if (skip_submit_window_check) {
    checks_submission_time <- new_hub_validations()
  } else {
    checks_submission_time <- validate_submission_time(
      hub_path, file_path,
      ref_date_from = submit_window_ref_date_from
    )
  }

  checks_file <- validate_model_file(
    hub_path = hub_path,
    file_path = file_path,
    validations_cfg_path = validations_cfg_path
  )

  if (any(purrr::map_lgl(checks_file, ~ is_any_error(.x)))) {
    return(
      combine(check_hub_config, checks_file, checks_submission_time)
    )
  }

  checks_data <- validate_model_data(
    hub_path = hub_path,
    file_path = file_path,
    round_id_col = round_id_col,
    validations_cfg_path = validations_cfg_path
  )

  combine(check_hub_config, checks_file, checks_data, checks_submission_time)
}
