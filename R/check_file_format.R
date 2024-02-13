#' Check file format is accepted by hub.
#'
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_file_format <- function(file_path, hub_path, round_id) {
  file_format <- fs::path_ext(file_path)
  file_formats <- get_hub_file_formats(hub_path, round_id)

  check <- file_format %in% file_formats

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline("Must be one of {.val {file_formats}}
                                      not {.val {file_format}}")
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "File",
    msg_attribute = "accepted hub format.",
    error = TRUE,
    details = details
  )
}
