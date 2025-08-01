#' Check model data rows are all unique
#'
#' Checks that combinations of task ID, output type and output type ID value
#' combinations are unique, by checking that there are no duplicate rows across
#' all `tbl` columns excluding the `value` column.
#' @inheritParams check_tbl_values
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
check_tbl_rows_unique <- function(tbl, file_path, hub_path) {
  tbl[["values"]] <- NULL
  check <- !any(duplicated(tbl))

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "Rows containing duplicate combinations: {.val {which(duplicated(tbl))}}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "All combinations of task ID column/{.var output_type}/{.var output_type_id} values",
    msg_attribute = "unique.",
    msg_verbs = c("are", "must be"),
    details = details
  )
}
