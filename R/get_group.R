# Group a tbl using values across all columns
group_tbl <- function(tbl, mask = NULL) {
  if (!is.null(mask)) {
    tbl[mask] <- NA
  }
  dplyr::group_by(tbl, dplyr::pick(dplyr::everything()))
}

# Get a vector of indices of the group each row belongs to when grouping
# a tbl by all columns
get_group_indices <- function(tbl, mask = NULL) {
  group_tbl(tbl, mask = mask) |>
    dplyr::group_indices()
}

# Get a list of the row indices associated with each group when grouping
# a tbl by all columns
get_group_rows <- function(tbl, mask = NULL) {
  group_tbl(tbl, mask = mask) |>
    dplyr::group_rows()
}
