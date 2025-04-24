group_tbl <- function(tbl, mask = NULL, sep = "-") {
  if (!is.null(mask)) {
    tbl[mask] <- NA
  }
  dplyr::group_by(tbl, dplyr::pick(dplyr::everything()))
}


get_group_indices <- function(tbl, mask = NULL, sep = "-") {
  group_tbl(tbl, mask = mask, sep = "-") |>
    dplyr::group_indices()
}

get_group_rows <- function(tbl, mask = NULL, sep = "-") {
  group_tbl(tbl, mask = mask, sep = "-") |>
    dplyr::group_rows()
}

