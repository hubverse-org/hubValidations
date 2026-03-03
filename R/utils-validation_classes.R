# Assert all hub_check objects have the same $where value.
# Returns the common where value, or NULL if x is empty.
assert_same_where <- function(x) {
  if (length(x) == 0L) {
    return(NULL)
  }

  where_values <- purrr::map_chr(x, "where")
  unique_where <- unique(where_values)

  if (length(unique_where) > 1L) {
    cli::cli_abort(
      c(
        "All checks in a {.cls hub_validations} object must have the same
        {.arg where} value.",
        "x" = "Found {length(unique_where)} different values: {.val {unique_where}}"
      )
    )
  }

  unique_where
}

#' Validate that all elements of x inherit from (or are of) the specified class.
#' @param x List of objects to validate.
#' @param class The class to check against.
#' @param strict If FALSE (default), subclasses are allowed (uses inherits()).
#'   If TRUE, first class must match exactly (no subclass mixing).
#' @return Invisible TRUE if validation passes, otherwise errors.
#' @noRd
validate_internal_class <- function(
  x,
  class = c(
    "hub_check", # nolint
    "hub_validations",
    "target_validations",
    "hub_validations_collection",
    "target_validations_collection"
  ),
  strict = FALSE
) {
  if (length(x) == 0L) {
    return(invisible(TRUE))
  }
  class <- rlang::arg_match(class)

  if (strict) {
    # Strict: first class must match exactly (no subclass mixing)
    first_classes <- purrr::map_chr(x, ~ class(.x)[1])
    valid <- first_classes == class
  } else {
    # Default: subclasses allowed
    valid <- purrr::map_lgl(x, ~ inherits(.x, class))
  }

  if (any(!valid)) {
    verb <- if (strict) "be of" else "inherit from" # nolint: object_usage_linter
    cli::cli_abort(
      c(
        "!" = "All elements must {verb} class {.cls {class}}.",
        "x" = "{cli::qty(sum(!valid))} Element{?s} with ind{?ex/ices}
           {.val {which(!valid)}} {cli::qty(sum(!valid))} do{?es/} not."
      )
    )
  }
  invisible(TRUE)
}

# ---- hub_validations subsetting and assignment methods ----
# These methods maintain class invariants:
# - where attribute is always consistent with checks' $where values
# - Only hub_check objects can be assigned
# - Class is preserved (including subclasses like target_validations)

#' @export
`[.hub_validations` <- function(x, i) {
  orig_class <- class(x)
  result <- NextMethod()
  if (length(result) == 0L) {
    attr(result, "where") <- NULL
  } else {
    attr(result, "where") <- attr(x, "where")
  }
  class(result) <- orig_class
  result
}

#' @export
`$<-.hub_validations` <- function(x, name, value) {
  orig_class <- class(x)

  if (is.null(value)) {
    x[[name]] <- NULL
    if (length(x) == 0L) {
      attr(x, "where") <- NULL
    }
  } else {
    if (!inherits(value, "hub_check")) {
      cli::cli_abort(
        "Can only assign {.cls hub_check} objects to {.cls hub_validations}."
      )
    }

    current_where <- attr(x, "where")
    new_where <- value$where

    if (is.null(current_where)) {
      attr(x, "where") <- new_where
    } else if (current_where != new_where) {
      cli::cli_abort(
        c(
          "Cannot add check with different {.arg where} value.",
          "x" = "Expected {.val {current_where}}, got {.val {new_where}}."
        )
      )
    }

    x[[name]] <- value
  }

  class(x) <- orig_class
  x
}

#' @export
`[[<-.hub_validations` <- function(x, i, value) {
  orig_class <- class(x)

  if (is.null(value)) {
    x <- NextMethod()
    if (length(x) == 0L) {
      attr(x, "where") <- NULL
    }
  } else {
    if (!inherits(value, "hub_check")) {
      cli::cli_abort(
        "Can only assign {.cls hub_check} objects to {.cls hub_validations}."
      )
    }

    current_where <- attr(x, "where")
    new_where <- value$where

    if (is.null(current_where)) {
      attr(x, "where") <- new_where
    } else if (current_where != new_where) {
      cli::cli_abort(
        c(
          "Cannot add check with different {.arg where} value.",
          "x" = "Expected {.val {current_where}}, got {.val {new_where}}."
        )
      )
    }

    x <- NextMethod()
  }

  class(x) <- orig_class
  x
}
