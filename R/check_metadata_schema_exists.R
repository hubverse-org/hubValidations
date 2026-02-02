#' Check whether a metadata schema file exists
#' @inherit check_metadata_file_exists params
#' @param file_path Path to the model metadata file being validated. Used as
#'   the `$where` in the returned check object, since this check is a
#'   prerequisite for validating that file.
#' @inherit check_tbl_col_types return
#'
#' @export
check_metadata_schema_exists <- function(hub_path = ".", file_path) {
  schema_path <- fs::path(hub_path, "hub-config", "model-metadata-schema.json")
  check <- fs::file_exists(schema_path)

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Model metadata schema file",
    msg_attribute = cli::format_inline(
      "at path {.path hub-config/model-metadata-schema.json}."
    ),
    msg_verbs = c("exists", "does not exist"),
    error = TRUE
  )
}
