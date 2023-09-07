#' Valid properties of a model output file.
#'
#' @inheritParams check_tbl_colnames
#' @return An object of class `hub_validations`. Each named element contains
#' a `hub_check` class object reflecting the result of a given check. Function
#' will return early if a check returns an error.
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' validate_model_file(hub_path,
#'   file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' )
#' validate_model_file(hub_path,
#'   file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
#' )
validate_model_file <- function(hub_path, file_path) {
  checks <- list()
  class(checks) <- c("hub_validations", "list")

  checks$file_exists <- check_file_exists(
    file_path = file_path,
    hub_path = hub_path
  )
  if (is_error(checks$file_exists)) {
    return(checks)
  }

  checks$file_name <- check_file_name(file_path)
  if (is_error(checks$file_name)) {
    return(checks)
  }

  checks$file_location <- check_file_location(file_path)

  file_meta <- parse_file_name(file_path)
  round_id <- file_meta$round_id

  checks$round_id_valid <- check_valid_round_id(
    round_id = round_id,
    file_path = file_path,
    hub_path = hub_path
  )
  if (is_error(checks$round_id_valid)) {
    return(checks)
  }

  checks$file_format <- check_file_format(
    file_path = file_path,
    hub_path = hub_path,
    round_id = round_id
  )
  if (is_error(checks$file_format)) {
    return(checks)
  }

  checks$metadata_exists <- check_metadata_file_exists_for_output_submission(
    hub_path = hub_path,
    file_path = file_path
  )
  if (is_error(checks$metadata_exists)) {
    return(checks)
  }

  # TODO: Add section for custom file checks

  checks
}
