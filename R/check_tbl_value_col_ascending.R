#' Check that `quantile` and `cdf` output type values of model output data
#' are non-descending
#'
#' Checks that values in the `value` column for `quantile` and `cdf` output type
#' data for each unique task ID/output type combination
#' are non-descending when arranged by increasing `output_type_id` order.
#' Check only performed if `tbl` contains `quantile` or `cdf` output type data.
#' If not, the check is skipped and a `<message/check_info>` condition class
#' object is returned.
#'
#' @inherit check_tbl_colnames params return
#' @export
check_tbl_value_col_ascending <- function(tbl, file_path) {
  if (all(!c("cdf", "quantile") %in% tbl[["output_type"]])) {
    return(
      capture_check_info(
        file_path,
        "No quantile or cdf output types to check for non-descending values.
        Check skipped."
      )
    )
  }

  output_type_tbl <- split(tbl, tbl[["output_type"]])[c("cdf", "quantile")] %>%
    purrr::compact()

  non_asc_df <- purrr::map(
    output_type_tbl,
    check_values_ascending
  ) %>%
    purrr::list_rbind()

  check <- nrow(non_asc_df) == 0L

  if (check) {
    details <- NULL
    non_asc_df <- NULL
  } else {
    details <- cli::format_inline("See {.var error_tbl} attribute for details.")
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "For each unique task ID value/output type combination,",
    msg_verbs = c("all values non-decreasing", "decreasing values detected"),
    msg_attribute = "as output_type_ids increase.",
    details = details,
    error_tbl = non_asc_df
  )
}


check_values_ascending <- function(tbl) {
  group_cols <- names(tbl)[!names(tbl) %in% hubUtils::std_colnames]
  tbl[["value"]] <- as.numeric(tbl[["value"]])

  check_tbl <- dplyr::group_by(tbl, dplyr::across(dplyr::all_of(group_cols))) %>%
    dplyr::arrange("output_type_id", .by_group = TRUE) %>%
    dplyr::summarise(non_asc = any(diff(.data[["value"]]) < 0))

  if (!any(check_tbl$non_asc)) {
    return(NULL)
  }

  output_type <- unique(tbl["output_type"])

  dplyr::filter(check_tbl, .data[["non_asc"]]) %>%
    dplyr::select(-dplyr::all_of("non_asc")) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(.env$output_type)
}
