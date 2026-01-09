#' Validate file level properties of a target data file.
#'
#' @param file_path A character string representing the path to the target data
#'  file relative to the `target-data` directory.
#' @param validations_cfg_path Path to YAML file configuring custom validation checks.
#' If `NULL` defaults to standard `hub-config/validations.yml` path. For more details
#' see [article on custom validation checks](
#' https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.html).
#' @param round_id Character string. Not generally relevant to target datasets
#' but can be used to specify a specific block of custom validation checks.
#' Otherwise best set to `"default"` which will deploy the default custom
#' validation checks.
#' @inheritParams check_tbl_colnames
#' @return An object of class `hub_validations`. Each named element contains
#' a `hub_check` class object reflecting the result of a given check. Function
#' will return early if a check returns an error.
#'
#' For more details on the structure of `<hub_validations>` objects, including
#' how to access more information on individual checks,
#' see [article on `<hub_validations>` S3 class objects](
#' https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).
#' @export
#' @details
#'
#' Details of checks performed by `validate_target_file()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations"))  |>
#' dplyr::filter(.data$`parent fun` == "validate_target_file", !.data$optional)  |>
#'   dplyr::select(-"parent fun", -"check fun", -"optional")  |>
#'   dplyr::mutate("Extra info" = dplyr::case_when(
#'     is.na(.data$`Extra info`) ~ "",
#'     TRUE ~ .data$`Extra info`
#'   ))  |>
#'   knitr::kable()  |>
#'   kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"))  |>
#'   kableExtra::column_spec(1, bold = TRUE)
#' ```
#' @examples
#' hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
#' validate_target_file(hub_path,
#'   file_path = "time-series.csv"
#' )
#' validate_target_file(hub_path,
#'   file_path = "oracle-output.csv"
#' )
#' hub_path <- system.file("testhubs/v5/target_dir", package = "hubUtils")
#' validate_target_file(hub_path,
#'   file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"
#' )
#' validate_target_file(hub_path,
#'   file_path = "oracle-output/output_type=pmf/part-0.parquet"
#' )
validate_target_file <- function(
  hub_path,
  file_path,
  validations_cfg_path = NULL,
  round_id = "default"
) {
  checks <- new_target_validations()

  checks$target_file_exists <- try_check(
    check_file_exists(
      file_path = file_path,
      hub_path = hub_path,
      subdir = "target-data"
    ),
    file_path
  )
  if (is_any_error(checks$target_file_exists)) {
    return(checks)
  }

  checks$target_partition_file_name <- try_check(
    check_target_file_name(file_path),
    file_path
  )
  if (is_any_error(checks$target_partition_file_name)) {
    return(checks)
  }

  checks$target_file_ext <- try_check(
    check_target_file_ext_valid(
      file_path = file_path
    ),
    file_path
  )
  if (is_any_error(checks$target_file_ext)) {
    return(checks)
  }

  custom_checks <- execute_custom_checks(
    validations_cfg_path = validations_cfg_path,
    subclass = "target_validations"
  )
  checks <- combine(checks, custom_checks)

  checks
}
