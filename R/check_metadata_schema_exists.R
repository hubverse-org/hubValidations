#' Check whether a metadata schema file exists
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_metadata_schema_exists <- function(hub_path = ".") {
  metadata_schema_path <- file.path(hub_path, "hub-config",
                                    "model-metadata-schema.json")
  rel_path <- file.path("hub-config", "model-metadata-schema.json")
  check <- fs::file_exists(metadata_schema_path)

  capture_check_cnd(
    check = check,
    file_path = metadata_schema_path,
    msg_subject = "Metadata schema file",
    msg_attribute = cli::format_inline("at path {.path {rel_path}}."),
    msg_verbs = c("exists", "does not exist"),
    error = TRUE)
}
