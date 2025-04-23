#' Check that a target data file has a valid extension.
#'
#' Note that files which are part of a hive partitioned dataset must have
#' parquet file extension only.
#' @inheritParams check_target_file_name
#' @inherit check_valid_round_id return
#' @export
check_target_file_ext_valid <- function(file_path) {
  hive <- is_hive_partitioned_path(file_path, strict = FALSE)
  if (hive) {
    valid_ext <- c("parquet")
    subject <- "Hive-partitioned target data file"
  } else {
    valid_ext <- c("csv", "parquet")
    subject <- "Target data file"
  }
  file_ext <- fs::path_ext(file_path)

  check <- file_ext %in% valid_ext
  details <- NULL

  if (!check) {
    invalid_ext <- setdiff(file_ext, valid_ext) # nolint: object_usage_linter
    details <- cli::format_inline(
      "Extension {.val {invalid_ext}} is not.
    Must be one of {.val {valid_ext}}."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = paste(subject, "extension"),
    msg_attribute = "valid.",
    error = TRUE,
    details = details
  )
}
