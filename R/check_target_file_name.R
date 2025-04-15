#' Check that a hive-partitioned target data file name can be correctly parsed.
#'
#' @param file_path A character string representing the path to the target data file
#' relative to the `target-data` directory.
#' @inherit check_valid_round_id return
#' @export
check_target_file_name <- function(file_path) {
  check <- try(is_hive_partitioned_path(file_path), silent = TRUE)
  if (isFALSE(check)) {
    return(
      capture_check_info(
        file_path,
        "Target file path not hive-partitioned. Check skipped."
      )
    )
  }
  details <- NULL
  if (inherits(check, "try-error")) {
    errors <- attr(check, "condition")$body # nolint: object_usage_linter
    details <- cli::format_inline("File path segments {errors} malformed.")
    check <- FALSE
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Hive-style partition file path segments",
    msg_attribute = "valid.",
    msg_verbs = c("are", "must be"),
    error = TRUE,
    details = details
  )
}
