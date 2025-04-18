#' Valid file level properties of a submitted model output file.
#'
#' @inheritParams check_tbl_colnames
#' @param validations_cfg_path Path to `validations.yml` file. If `NULL`
#' defaults to `hub-config/validations.yml`.
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
#' Details of checks performed by `validate_model_file()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations")) %>%
#' dplyr::filter(.data$`parent fun` == "validate_model_file", !.data$optional) %>%
#'   dplyr::select(-"parent fun", -"check fun", -"optional") %>%
#'   dplyr::mutate("Extra info" = dplyr::case_when(
#'     is.na(.data$`Extra info`) ~ "",
#'     TRUE ~ .data$`Extra info`
#'   )) %>%
#'   knitr::kable() %>%
#'   kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) %>%
#'   kableExtra::column_spec(1, bold = TRUE)
#' ```
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' validate_model_file(hub_path,
#'   file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' )
#' validate_model_file(hub_path,
#'   file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
#' )
validate_model_file <- function(hub_path, file_path,
                                validations_cfg_path = NULL) {
  checks <- new_hub_validations()

  checks$file_exists <- try_check(
    check_file_exists(
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$file_exists)) {
    return(checks)
  }

  checks$file_name <- try_check(
    check_file_name(file_path), file_path
  )
  if (is_any_error(checks$file_name)) {
    return(checks)
  }

  checks$file_location <- try_check(
    check_file_location(file_path), file_path
  )

  file_meta <- parse_file_name(file_path)
  round_id <- file_meta$round_id

  checks$round_id_valid <- try_check(
    check_valid_round_id(
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$round_id_valid)) {
    return(checks)
  }

  checks$file_format <- try_check(
    check_file_format(
      file_path = file_path,
      hub_path = hub_path,
      round_id = round_id
    ), file_path
  )
  if (is_any_error(checks$file_format)) {
    return(checks)
  }

  checks$file_n <- try_check(
    check_file_n(
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )

  checks$metadata_exists <- try_check(
    check_submission_metadata_file_exists(
      hub_path = hub_path,
      file_path = file_path
    ), file_path
  )

  custom_checks <- execute_custom_checks(validations_cfg_path = validations_cfg_path)
  checks <- combine(checks, custom_checks)

  checks
}
