#' Check target data rows are all unique
#'
#' Check that there are no duplicate rows in target data files being validated.
#'
#' @details
#' If datasets are versioned, multiple observations are allowed in `time-series`
#' target data, so long as they have different `as_of` values. The `as_of` column
#' is therefore included when determining duplicates.
#' In `oracle-output` data, there should be only a single observation,
#' regardless of the `as_of` value so the column it is not be included when
#' determining duplicates.
#' @inheritParams check_target_tbl_colnames
#' @inherit check_tbl_col_types return
#' @export
check_target_tbl_rows_unique <- function(
  target_tbl,
  target_type = c(
    "time-series",
    "oracle-output"
  ),
  file_path,
  hub_path
) {
  target_type <- rlang::arg_match(target_type)

  if (target_type == "time-series") {
    target_tbl[["observation"]] <- NULL
  } else {
    target_tbl[["oracle_value"]] <- NULL
    target_tbl[["as_of"]] <- NULL
  }

  duplicates <- duplicated(target_tbl)
  check <- !any(duplicates)

  if (check) {
    details <- NULL
    duplicate_rows <- NULL
  } else {
    duplicate_rows <- which(duplicates)
    details <- cli::format_inline(
      "Rows containing duplicate combinations: {.val {duplicate_rows}}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "{.field {target_type}} target data rows"
    ),
    msg_attribute = "unique.",
    msg_verbs = c("are", "must be"),
    details = details,
    duplicate_rows = duplicate_rows
  )
}
