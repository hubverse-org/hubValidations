#' Validate a submitted model data file submission time.
#'
#' @inherit validate_model_data return params
#' @inheritParams check_submission_time
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' validate_submission_time(hub_path, file_path)
validate_submission_time <- function(hub_path, file_path, ref_date_from = c(
                                       "file_path",
                                       "file"
                                     )) {
  checks <- new_hub_validations()

  checks$submission_time <- try_check(
    check_submission_time(
      file_path = file_path,
      hub_path = hub_path,
      ref_date_from = ref_date_from
    ),
    file_path = file_path
  )
  checks
}
