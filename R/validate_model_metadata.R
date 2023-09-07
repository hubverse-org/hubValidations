#' Valid properties of a metadata file.
#'
#' @inheritParams check_tbl_colnames
#' @return An object of class `hub_validations`. Each named element contains
#' a `hub_check` class object reflecting the result of a given check. Function
#' will return early if a check returns an error.
#'
#' @importFrom yaml read_yaml
#' @importFrom jsonlite toJSON
#' @importFrom jsonvalidate json_validate
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' validate_model_file(hub_path,
#'   file_path = "team1-goodmodel.yml"
#' )
validate_model_metadata <- function(hub_path, file_path) {
  checks <- list()
  class(checks) <- c("hub_validations", "list")

  checks$metadata_schema_exists <- check_metadata_schema_exists(hub_path)
  if (is_error(checks$metadata_schema_exists)) {
    return(checks)
  }

  checks$metadata_file_exists <- check_metadata_file_exists(
    file_path = file_path,
    hub_path = hub_path
  )
  if (is_error(checks$metadata_file_exists)) {
    return(checks)
  }

  checks$metadata_file_ext <- check_metadata_file_ext(file_path)

  checks$metadata_file_location <- check_metadata_file_location(file_path)
  if (is_error(checks$metadata_file_location) ||
      is_error(checks$metadata_file_ext)) {
    return(checks)
  }

  checks$metadata_matches_schema <- check_metadata_matches_schema(
    file_path = file_path,
    hub_path = hub_path)
  if (is_error(checks$metadata_matches_schema)) {
    return(checks)
  }

  # file name matches model id specified in metadata file
  checks$metadata_file_name <- check_metadata_file_name(file_path = file_path,
                                                        hub_path = hub_path)
  if (is_error(checks$metadata_file_name)) {
    return(checks)
  }

  # TODO: Add section for custom file checks

  checks
}
