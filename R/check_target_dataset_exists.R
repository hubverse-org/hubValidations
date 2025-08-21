#' Check target dataset can be detected for a given target type
#'
#' @inheritParams check_target_dataset_unique
#' @inherit check_target_dataset_unique return
#'
#' @export
check_target_dataset_exists <- function(
  hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  file_path <- target_type
  target_path <- hubData::get_target_path(hub_path, target_type)

  check <- length(target_path) > 0L

  if (length(target_path) == 1L) {
    # If only single target path detected, return the relative path to
    # the actual dataset as `file_path`, otherwise continue returning
    # the target type. More than one target path will be detected by
    # check_target_dataset_unique.
    file_path <- hubData::get_target_path(hub_path, target_type) |>
      rel_file_path(hub_path, subdir = "target-data")
  }

  capture_check_cnd(
    check = check,
    file_path = as.character(file_path),
    msg_subject = cli::format_inline("{.field {target_type}} dataset"),
    msg_attribute = NULL,
    msg_verbs = c("detected.", "not detected."),
    error = TRUE
  )
}
