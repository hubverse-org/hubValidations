#' Check that the metadata file is being submitted to the correct folder
#'
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#'
#' @export
check_metadata_file_location <- function(file_path) {
  dir_name <- dirname(file_path)
  check <- dir_name == "model-metadata"

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "File should be submitted to directory
      {.val \"model-metadata\"} not {.val {dir_name}}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Metadata file directory name",
    msg_attribute = cli::format_inline("must be {.val \"model-metadata\"}."),
    msg_verbs = c("matches", "must match"),
    details = details)
}
