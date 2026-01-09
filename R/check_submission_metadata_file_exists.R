#' Check whether a metadata file for the given model exists
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_submission_metadata_file_exists <- function(file_path, hub_path = ".") {
  metadata_file_path <- try(
    get_metadata_file_name(hub_path, file_path, ext = "auto"),
    silent = TRUE
  )

  check <- !inherits(metadata_file_path, "try-error")

  if (check) {
    # nolint start: object_usage_linter
    rel_path <- rel_file_path(
      metadata_file_path,
      hub_path,
      subdir = "model-metadata"
    )
    # nolint end
    msg_attribute <- cli::format_inline("at path {.path {rel_path}}.")
  } else {
    metadata_file_paths <- get_metadata_file_name(
      hub_path,
      file_path,
      ext = "both"
    )
    # nolint start: object_usage_linter
    rel_paths <- rel_file_path(
      metadata_file_paths,
      hub_path,
      subdir = "model-metadata"
    )
    # nolint end
    msg_attribute <- cli::format_inline(
      "at path {.path {rel_paths[1]}} or
                                           {.path {rel_paths[2]}}."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Metadata file",
    msg_attribute = msg_attribute,
    msg_verbs = c("exists", "does not exist"),
    error = FALSE
  )
}
