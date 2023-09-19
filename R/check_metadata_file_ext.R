#' Check file is being submitted to the correct folder
#'
#' Checks that the `model_id` metadata in the file name matches the directory name
#' the file is being submitted to.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#'
#' @export
check_metadata_file_ext <- function(file_path) {
  ext <- fs::path_ext(file_path)
  check <- ext %in% c("yml", "yaml")

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "However, it was {.val {ext}}."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Metadata file extension",
    msg_attribute = cli::format_inline("{.val yml} or {.val yaml}."),
    msg_verbs = c("is", "must be"),
    details = details,
    error = TRUE)
}
