#' Check a model output file name can be correctly parsed.
#'
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#' @export
check_file_name <- function(file_path) {
  check <- !inherits(
    try(parse_file_name(file_path), silent = TRUE),
    "try-error"
  )
  if (check) {
      details <- NULL
  } else {
      details <- "Could not correctly parse submission metadata."
  }
  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "File name {.val {basename(file_path)}}",
    msg_attribute = "valid.",
    error = TRUE,
    details = details
  )
}
