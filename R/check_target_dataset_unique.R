#' Check that a single unique target dataset exists for a given target type.
#'
#' @inheritParams hubData::get_target_path
#' @inherit check_tbl_col_types return
#' @export
check_target_dataset_unique <- function(hub_path, target_type = c(
                                          "time-series", "oracle-output"
                                        )) {
  target_type <- rlang::arg_match(target_type)
  file_path <- file.path("target-data", target_type)

  target_path <- hubData::get_target_path(hub_path, target_type)
  target_n <- length(target_path)

  if (target_n == 0L) {
    return(
      capture_check_info(
        file_path = file_path,
        cli::format_inline("No {.field {target_type}} target type files detected in
        {.path target-data} directory. Check skipped.")
      )
    )
  }

  check <- target_n == 1L
  details <- NULL
  if (!check) {
    details <- cli::format_inline(
      "Multiple {.field {target_type}} datasets found:
      {.path {basename(target_path)}}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.path target-data} directory",
    msg_attribute = cli::format_inline(
      "single unique {.field {target_type}} dataset."
    ),
    msg_verbs = c("contains", "must contain"),
    error = FALSE,
    details = details
  )
}
