#' Validate a submitted model data file submission time.
#'
#' @inherit validate_model_data return params
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' validate_submission_time(hub_path, file_path)
validate_submission_time <- function(hub_path, file_path) {
  checks <- list()
  class(checks) <- c("hub_validations", "list")

  checks$submission_time <- try_check(
    check_submission_time(
      file_path = file_path,
      hub_path = hub_path
    ),
    file_path = file_path
  )
  checks
}
