#' Generic to test if a tbl or vector contains distributional output types
#'
#' If x is a tbl, the unique values of `output_type` column are tested.
#' @param x Oracle output tbl or vector of `output_type` names to test.
#' @return Named logical vector.
#' @noRd
is_distributional <- function(x) {
  UseMethod("is_distributional")
}
#' @export
is_distributional.default <- function(x) {
  is_distributional <- x %in% c("cdf", "pmf")
  purrr::set_names(is_distributional, x)
}
#' @export
is_distributional.data.frame <- function(x) {
  if (!has_output_types(x)) {
    return(character())
  }
  output_types <- unique(x[["output_type"]])
  is_distributional <- output_types %in% c("cdf", "pmf")
  purrr::set_names(is_distributional, output_types)
}
#' Row-wise test for distributional output type
#'
#' @param tbl A data frame containing an `output_type` column.
#' @return Logical vector indicating distributional rows.
#' @noRd
is_distributional_row <- function(tbl) {
  if (!has_output_types(tbl)) {
    return(logical())
  }
  tbl[["output_type"]] %in% c("cdf", "pmf")
}

#' Test presence of output_type_id column
#'
#' @param tbl A data frame.
#' @return Logical scalar indicating presence of column.
#' @noRd
has_output_type_ids <- function(tbl) {
  any(colnames(tbl) == "output_type_id")
}
#' Test presence of output_type column
#'
#' @param tbl A data frame.
#' @return Logical scalar indicating presence of column.
#' @noRd
has_output_types <- function(tbl) {
  any(colnames(tbl) == "output_type")
}
#' Test if any distributional types exist in the table
#'
#' @param tbl A data frame.
#' @return Logical scalar indicating any distributional entries.
#' @noRd
has_distributional <- function(tbl) {
  any(colnames(tbl) == "output_type_id") &&
    any(tbl[["output_type"]] %in% c("cdf", "pmf"))
}
#' Test if all output_type_id values are NA
#'
#' @param tbl A data frame.
#' @return Logical scalar that is TRUE if all IDs are NA.
#' @noRd
has_all_na_output_type_ids <- function(tbl) {
  any(colnames(tbl) == "output_type_id") &&
    all(is.na(tbl[["output_type_id"]]))
}

#' Get unique output types with non-NA IDs
#'
#' Returns a character vector of unique `output_type` names for which
#' `output_type_id` is not `NA`.
#'
#' @param tbl A data frame containing `output_type` and `output_type_id` columns.
#' @return A character vector of unique output types with non-missing IDs.
#' @noRd
has_non_na_output_type_ids <- function(tbl) {
  unique(tbl$output_type[!is.na(tbl$output_type_id)])
}
