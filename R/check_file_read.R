#' Check file can be read successfully
#'
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_file_read <- function(file_path, hub_path = ".") {
  try_read <- try(
    {
      if (fs::path_ext(file_path) == "csv") {
        tbl <- read_model_out_file( # nolint: object_usage_linter
          file_path = file_path,
          hub_path = hub_path,
          coerce_types = "hub"
        )
      } else {
        tbl <- read_model_out_file(
          file_path = file_path,
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
      attr(try_read, "condition")$message, "\n",
      "Please check file path is correct and file can be read using {.fn read_model_out_file}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "File",
    msg_attribute = "successfully.",
    msg_verbs = c("could be read", "could not be read"),
    error = TRUE,
    details = details
  )
}
