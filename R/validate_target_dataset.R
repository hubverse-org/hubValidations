#' Validate dataset level properties of a given target type
#'
#' @inheritParams validate_target_file
#' @inheritParams check_target_dataset_unique
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
#' Details of checks performed by `validate_target_dataset()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations"))  |>
#' dplyr::filter(.data$`parent fun` == "validate_target_dataset", !.data$optional)  |>
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
#' # Validate single file target datasets
#' hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
#' validate_target_dataset(hub_path,
#'   target_type = "time-series"
#' )
#' validate_target_dataset(hub_path,
#'   target_type = "oracle-output"
#' )
#' # Validate multi-file partitioned target datasets
#' hub_path <- system.file("testhubs/v5/target_dir", package = "hubUtils")
#' validate_target_dataset(hub_path,
#'   target_type = "time-series"
#' )
#' validate_target_dataset(hub_path,
#'   target_type = "oracle-output"
#' )
validate_target_dataset <- function(
  hub_path,
  target_type = c("time-series", "oracle-output"),
  validations_cfg_path = NULL,
  round_id = "default"
) {
  target_type <- rlang::arg_match(target_type)
  checks <- new_target_validations()

  checks$target_dataset_exists <- try_check(
    check_target_dataset_exists(
      hub_path = hub_path,
      target_type = target_type
    ),
    # Use target type as file_path here as it's not guaranteed a
    # valid target path can be detected yet
    target_type
  )
  if (is_any_error(checks$target_dataset_exists)) {
    return(checks)
  }
  checks$target_dataset_unique <- try_check(
    check_target_dataset_unique(
      hub_path = hub_path,
      target_type = target_type
    ),
    # Use target type as file_path here as it's not guaranteed a
    # valid target path can be detected yet
    target_type
  )
  if (is_any_error(checks$target_dataset_unique)) {
    return(checks)
  }
  # Now detection of a valid path is guaranteed so use the actual file path
  # going forward
  file_path <- basename(hubData::get_target_path(hub_path, target_type))

  checks$target_dataset_file_ext_unique <- try_check(
    check_target_dataset_file_ext_unique(
      hub_path = hub_path,
      target_type = target_type
    ),
    file_path
  )
  if (is_any_error(checks$target_dataset_file_ext_unique)) {
    return(checks)
  }
  checks$target_dataset_rows_unique <- try_check(
    check_target_dataset_rows_unique(
      hub_path = hub_path,
      target_type = target_type
    ),
    file_path
  )

  custom_checks <- execute_custom_checks(
    validations_cfg_path = validations_cfg_path,
    subclass = "target_validations"
  )
  checks <- combine(checks, custom_checks)

  checks
}
