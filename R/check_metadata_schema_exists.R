#' Check whether a metadata schema file exists
#' @inherit check_metadata_file_exists params
#' @inherit check_tbl_col_types return
#'
#' @export
check_metadata_schema_exists <- function(hub_path = ".") {
  check_file_exists(hub_path = hub_path,
                    subdir = "hub-config",
                    file_path = "model-metadata-schema.json")
}
