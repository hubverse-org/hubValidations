#' Check target file can be read successfully
#'
#' @inheritParams check_target_file_name
#' @inherit check_target_file_name return
#'
#' @export
check_target_file_read <- function(file_path, hub_path = ".") {
  try_read <- try(
    {
      if (fs::path_ext(file_path) == "csv") {
        read_target_file(
          target_file_path = file_path,
          hub_path = hub_path,
          coerce_types = "target"
        )
      } else {
        read_target_file(
          target_file_path = file_path,
          hub_path = hub_path,
          coerce_types = "none"
        )
      }
    },
    silent = TRUE
  )
  check <- !inherits(try_read, "try-error")

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      attr(try_read, "condition")$message,
      "\n",
      "Please check file path is correct and target file can be read using {.fn read_target_file}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "target file",
    msg_attribute = "successfully.",
    msg_verbs = c("could be read", "could not be read"),
    error = TRUE,
    details = details
  )
}
