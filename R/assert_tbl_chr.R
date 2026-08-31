# Check that a function requiring `tbl_chr` was given an all character table.
assert_tbl_chr <- function(tbl_chr, call = rlang::caller_env()) {
  is_typed <- !vapply(tbl_chr, is.character, logical(1L))
  if (!any(is_typed)) {
    return(invisible(NULL))
  }
  types <- tbl_col_types(tbl_chr[is_typed]) # nolint: object_usage_linter
  cli::cli_abort(
    c(
      "Every column of {.arg tbl_chr} must be character.",
      "x" = "{cli::qty(types)}Column{?s} {.val {names(types)}}
      {?is/are} of type {.val {types}}.",
      "i" = "Use {.code read_model_out_file(coerce_types = \"chr\")} to read a
      submission as character."
    ),
    call = call
  )
}
