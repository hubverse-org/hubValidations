#' Validate a submitted model data file. Checks both file level properties like
#' file name, extension, location etc as well as model output data, i.e. the contents
#' of the file.
#'
#' @inherit validate_model_data return params
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' validate_submission(hub_path, file_path)
validate_submission <- function(hub_path, file_path, round_id_col = NULL,
                                validations_cfg_path = NULL) {
  checks_file <- validate_model_file(
    hub_path = hub_path,
    file_path = file_path,
    validations_cfg_path = validations_cfg_path
  )

  if (any(purrr::map_lgl(checks_file, ~ is_error(.x)))) {
    return(checks_file)
  }

  checks_data <- validate_model_data(
    hub_path = hub_path,
    file_path = file_path,
    round_id_col = round_id_col,
    validations_cfg_path = validations_cfg_path
  )

  checks <- c(checks_file, checks_data)
  class(checks) <- c("hub_validations", "list")

  checks
}
