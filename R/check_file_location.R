#' Check file is being submitted to the correct folder
#'
#' Checks that the `model_id` metadata in the file name matches the directory name
#' the file is being submitted to.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#'
#' @export
check_file_location <- function(file_path) {
  dir_name <- dirname(file_path)
  model_id <- parse_file_name(file_path)$model_id
  check <- model_id == dir_name

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "File should be submitted to directory
            {.val {model_id}} not {.val {dir_name}}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "File directory name",
    msg_attribute = cli::format_inline("{.var model_id}
                                           metadata in file name."),
    msg_verbs = c("matches", "must match"),
    details = details
  )
}
