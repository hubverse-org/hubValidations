#' Print results of `validate_...()` function as a bullet list
#'
#' @param x An object of class `hub_validations`
#' @param ... Unused argument present for class consistency
#'
#'
#' @export
print.hub_validations <- function(x, ...) {
  if (length(x) == 0L) {
    msg <- cli::format_inline("Empty {.cls hub_validations}")
  } else {
    msg <- stats::setNames(
      paste(
        fs::path_file(purrr::map_chr(x, "where")),
        purrr::map_chr(x, "message"),
        sep = ": "
      ),
      dplyr::case_when(
        purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_success")) ~ "v",
        purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_failure")) ~ "!",
        purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_exec_warn")) ~ "!",
        purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_error")) ~ "x",
        purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_exec_error")) ~ "x",
        purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_info")) ~ "i",
        TRUE ~ "*"
      )
    )
  }

  octolog::octo_inform(msg)
}


#' Concatenate `hub_validations` S3 class objects
#'
#' @param ... `hub_validations` S3 class objects to be concatenated.
#' @return a `hub_validations` S3 class object.
#'
#' @export
combine <- function(...) {
  UseMethod("combine")
}

#' @export
combine.hub_validations <- function(...) {
  rlang::list2(...) %>%
    purrr::compact() %>%
    validate_internal_class(class = "hub_validations")

    structure(c(...),
    class = c("hub_validations", "list")
  )
}

validate_internal_class <- function(x, class = c(
  "hub_check",
  "hub_validations"
)) {
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

summary.hub_validations <- function(x, ...) {

  # TODO
  NULL
}

# TODO: Code to consider implementing more hierarchical printing of messages.
# Currently not implemented as pr_hub_validations class not implemented.
#' Print results of `validate_pr()` function as a bullet list
#'
#' @param x An object of class `pr_hub_validations`
#' @param ... Unused argument present for class consistency
#'
#'
#' @export
print.pr_hub_validations <- function(x, ...) {
  purrr::map(x, print)
}
