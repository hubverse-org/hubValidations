#' Validate a submitted target data file.
#'
#' Checks both file level properties like
#' file name, extension, location etc as well as target data, i.e. the
#' contents of the file.
#' @inheritParams validate_target_file
#' @inherit validate_target_data return params
#' @inheritParams validate_submission
#' @export
#' @details
#'
#' Details of checks performed by `validate_target_submission()`
#'
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations")) %>%
#' dplyr::filter(
#'  .data$`parent fun` %in% c(
#'                              "validate_target_file",
#'                              "validate_target_data"
#'                            ) |
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
#' @examples
#' hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
#' validate_target_submission(
#'   hub_path,
#'   file_path = "time-series.csv",
#'   target_type = "time-series"
#' )
#' # Example with partitioned data
#' hub_path <- system.file("testhubs/v5/target_dir", package = "hubUtils")
#' validate_target_submission(
#'   hub_path,
#'   file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
#'   target_type = "time-series"
#' )
validate_target_submission <- function(
  hub_path,
  file_path,
  target_type = c(
    "time-series",
    "oracle-output"
  ),
  date_col = NULL,
  allow_extra_dates = FALSE,
  round_id = "default",
  na = c("NA", ""),
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
  skip_check_config = FALSE
) {
  checkmate::assert_string(date_col, null.ok = TRUE)
  check_hub_config <- new_target_validations()
  target_type <- rlang::arg_match(target_type)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)

  if (!skip_check_config) {
    check_hub_config$valid_config <- try_check(
      check_config_hub_valid(hub_path),
      file_path
    )
    if (not_pass(check_hub_config$valid_config)) {
      return(check_hub_config)
    }
  }

  checks_file <- validate_target_file(
    hub_path = hub_path,
    file_path = file_path,
    validations_cfg_path = validations_cfg_path,
    round_id = round_id
  )

  if (any(purrr::map_lgl(checks_file, ~ is_any_error(.x)))) {
    return(
      combine(check_hub_config, checks_file)
    )
  }

  checks_data <- validate_target_data(
    hub_path = hub_path,
    file_path = file_path,
    target_type = target_type,
    date_col = date_col,
    allow_extra_dates = allow_extra_dates,
    na = na,
    output_type_id_datatype = output_type_id_datatype,
    validations_cfg_path = validations_cfg_path,
    round_id = round_id
  )

  combine(check_hub_config, checks_file, checks_data)
}
