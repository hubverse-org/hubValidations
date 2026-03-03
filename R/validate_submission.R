#' Validate a submitted model data file.
#'
#' Checks both file level properties like
#' file name, extension, location etc as well as model output data, i.e. the contents
#' of the file.
#'
#' @inherit validate_model_data params
#' @inheritParams hubData::create_hub_schema
#' @inheritParams expand_model_out_grid
#' @param skip_submit_window_check Logical. Whether to skip the submission window check.
#' @param skip_check_config Logical. Whether to skip the hub config validation check.
#' @param submit_window_ref_date_from whether to get the reference date around
#' which relative submission windows will be determined from the file's
#' `file_path` round ID or the `file` contents themselves.
#' `file` requires that the file can be read.
#' Only applicable when a round is configured to determine the submission
#' windows relative to the value in a date column in model output files.
#' Not applicable when explicit submission window start and end dates are
#' provided in the hub's config.
#' @return A `hub_validations_collection` object containing validation results
#'   organized by file. The collection includes separate entries for hub config
#'   validation (keyed by `"hub-config"`) and file-specific validations (keyed by
#'   file path).
#' @export
#' @details
#' Note that it is **necessary for `derived_task_ids` to be specified if any
#' task IDs with `required` values have dependent derived task IDs**. If this
#' is the case and derived task IDs are not specified, the dependent nature of
#' derived task ID values will result in **false validation errors when
#' validating required values**.
#'
#' Details of checks performed by `validate_submission()`
#'
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
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' validate_submission(hub_path, file_path)
validate_submission <- function(
  hub_path,
  file_path,
  round_id_col = NULL,
  validations_cfg_path = NULL,
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  skip_submit_window_check = FALSE,
  skip_check_config = FALSE,
  submit_window_ref_date_from = c(
    "file",
    "file_path"
  ),
  derived_task_ids = NULL
) {
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)

  # Config validation (separate from file validation)
  config_validations <- NULL
  if (!skip_check_config) {
    config_check <- try_check(
      check_config_hub_valid(hub_path),
      "hub-config"
    )
    config_validations <- new_hub_validations(valid_config = config_check)
    if (not_pass(config_check)) {
      return(new_hub_validations_collection(config_validations))
    }
  }

  # File validations
  checks_file <- validate_model_file(
    hub_path = hub_path,
    file_path = file_path,
    validations_cfg_path = validations_cfg_path
  )

  if (!skip_submit_window_check) {
    checks_file$submission_time <- try_check(
      check_submission_time(
        hub_path = hub_path,
        file_path = file_path,
        ref_date_from = submit_window_ref_date_from
      ),
      file_path = file_path
    )
  }

  if (any(purrr::map_lgl(checks_file, \(.x) is_any_error(.x)))) {
    return(new_hub_validations_collection(config_validations, checks_file))
  }

  checks_data <- validate_model_data(
    hub_path = hub_path,
    file_path = file_path,
    round_id_col = round_id_col,
    output_type_id_datatype = output_type_id_datatype,
    validations_cfg_path = validations_cfg_path,
    derived_task_ids = derived_task_ids
  )

  new_hub_validations_collection(
    config_validations,
    combine(checks_file, checks_data)
  )
}
