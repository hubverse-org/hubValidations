validate_internal_class <- function(
  x,
  class = c(
    "hub_check", # nolint
    "hub_validations",
    "target_validations"
  )
) {
  if (length(x) == 0L) {
    return(invisible(TRUE))
  }
  class <- rlang::arg_match(class)
  valid <- purrr::map_lgl(x, ~ inherits(.x, class))
  if (any(!valid)) {
    cli::cli_abort(
      c(
        "!" = "All elements must inherit from class {.cls {class}}.",
        "x" = "{cli::qty(sum(!valid))} Element{?s} with ind{?ex/ices}
           {.val {which(!valid)}} {cli::qty(sum(!valid))} do{?es/} not."
      )
    )
  }
  invisible(TRUE)
}
