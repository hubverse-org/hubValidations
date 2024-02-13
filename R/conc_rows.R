conc_rows <- function(tbl, mask = NULL, sep = "-") {
  if (!is.null(mask)) {
    tbl[mask] <- ""
  }
  tbl_dim <- dim(tbl)
  rows <- split(
    unlist(tbl, use.names = FALSE),
    rep(1:tbl_dim[1], tbl_dim[2])
  )
  lapply(rows, function(x) {
    paste(x, collapse = sep)
  }) %>%
    unlist(use.names = FALSE)
}
