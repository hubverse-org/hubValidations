#' Check whether a metadata schema file exists
#'
#' @param file_path character string. Path to the file being validated relative to
#' the hub's model-metadata directory.
#' @inheritParams hubUtils::connect_hub
#'
#' @inherit check_valid_round_id return
#'
#' @export
check_metadata_file_exists <- function(hub_path = ".", file_path) {
  check_file_exists(hub_path = hub_path, subdir = "model-metadata",
                    file_path = file_path)
}
