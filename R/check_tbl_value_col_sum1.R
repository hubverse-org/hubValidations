#' Check that `pmf` output type values of model output data sum to 1.
#'
#' Checks that values in the `value` column of `pmf` output type
#' data for each unique task ID combination sum to 1.
#' Check only performed if `tbl` contains `pmf` output type data.
#' If not, the check is skipped and a `<message/check_info>` condition class
#' object is returned.
#'
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
check_tbl_value_col_sum1 <- function(tbl, file_path) {
  if (!"pmf" %in% tbl[["output_type"]]) {
    return(
      capture_check_info(
        file_path,
        "No pmf output types to check for sum of 1. Check skipped."
      )
    )
  }

  tbl <- tbl[tbl[["output_type"]] == "pmf", ]
  error_tbl <- check_values_sum1(tbl)

  check <- is.null(error_tbl)

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline("See {.var error_tbl} attribute for details.")
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Values in {.var value} column",
    msg_verbs = c("do", "do not"),
    msg_attribute = "sum to 1 for all unique task ID value combination of pmf
    output types.",
    details = details,
    error_tbl = error_tbl
  )
}


check_values_sum1 <- function(tbl) {
  group_cols <- names(tbl)[!names(tbl) %in% hubUtils::std_colnames]
  tbl[["value"]] <- as.numeric(tbl[["value"]])

  check_tbl <- dplyr::group_by(
    tbl,
    dplyr::across(dplyr::all_of(group_cols))
  ) |>
    dplyr::arrange("output_type_id", .by_group = TRUE) |>
    dplyr::summarise(sum1 = isTRUE(all.equal(sum(.data[["value"]]), 1L)))

  if (all(check_tbl$sum1)) {
    return(NULL)
  }

  dplyr::filter(check_tbl, !.data[["sum1"]]) |>
    dplyr::select(-dplyr::all_of("sum1")) |>
    dplyr::ungroup() |>
    dplyr::mutate(output_type = "pmf")
}
