#' Valid properties of a metadata file.
#'
#' @inheritParams validate_model_file
#' @param round_id character string. The round identifier. Used primarily to indicate whether the "default" or a round specific configuration should be used for custom validations.
#' @return An object of class `hub_validations`. Each named element contains
#' a `hub_check` class object reflecting the result of a given check. Function
#' will return early if a check returns an error.
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' validate_model_metadata(hub_path,
#'   file_path = "hub-baseline.yml"
#' )
#' validate_model_metadata(hub_path,
#'   file_path = "team1-goodmodel.yaml"
#' )
validate_model_metadata <- function(hub_path, file_path, round_id = "default",
                                    validations_cfg_path = NULL) {
  checks <- new_hub_validations()

  checks$metadata_schema_exists <- try_check(
    check_metadata_schema_exists(hub_path), file_path
  )
  if (is_any_error(checks$metadata_schema_exists)) {
    return(checks)
  }

  checks$metadata_file_exists <- try_check(
    check_metadata_file_exists(
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$metadata_file_exists)) {
    return(checks)
  }

  checks$metadata_file_ext <- try_check(
    check_metadata_file_ext(file_path), file_path
  )
  checks$metadata_file_location <- try_check(
    check_metadata_file_location(file_path), file_path
  )
  if (is_any_error(checks$metadata_file_location) ||
    is_any_error(checks$metadata_file_ext)) {
    return(checks)
  }

  checks$metadata_matches_schema <- try_check(
    check_metadata_matches_schema(
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$metadata_matches_schema)) {
    return(checks)
  }

  # file name matches model id specified in metadata file
  checks$metadata_file_name <- try_check(
    check_metadata_file_name(
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$metadata_file_name)) {
    return(checks)
  }

  custom_checks <- execute_custom_checks(validations_cfg_path = validations_cfg_path)
  checks <- combine(checks, custom_checks)

  checks
}
