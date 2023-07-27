#' Check file can be read successfully
#'
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_file_read <- function(file_path, hub_path = ".") {
  try_read <- try(
    read_model_out_file(file_path, hub_path),
    silent = TRUE
  )
  check <- !inherits(try_read, "try-error")

  if (check) {
    details <- NULL
  } else {
    read_fun <- switch(fs::path_ext(file_path),
      csv = "arrow::read_csv_arrow",
      parquet = "arrow::read_parquet",
      arrow = "arrow::read_feather"
    )
    details <- cli::format_inline(
        attr(try_read, "condition")$message, "\n",
      "Please check file path is correct and file can be read using {.fn {read_fun}}"
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
