#' Concatenate validation objects
#'
#' Combines multiple validation objects of the same class into one. Works with
#' both single-file validation objects (`hub_validations`, `target_validations`)
#' and multi-file collection objects (`hub_validations_collection`,
#' `target_validations_collection`). For more details on these classes,
#' see [article on `<hub_validations>` S3 class objects](
#' https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).
#'
#' For `hub_validations` objects, all inputs must share the same `where`
#' attribute (i.e., be validations for the same subject).
#'
#' For `hub_validations_collection` objects, the individual `hub_validations`
#' objects from all collections are extracted and grouped by their `where`
#' attribute, combining validation results for the same subject.
#'
#' Subclasses (e.g., `target_validations`, `target_validations_collection`) are
#' preserved.
#'
#' @param ... Validation objects to be concatenated. All objects must be of the
#'   same class. NULL values are ignored. Empty objects are filtered out when
#'   combining multiple inputs, but a single empty input is returned as-is.
#' @return An object of the same class as the inputs, or NULL if no valid
#'   inputs provided.
#' @seealso [new_hub_validations()], [new_hub_validations_collection()],
#'   [new_target_validations()], [new_target_validations_collection()]
#'
#' @export
combine <- function(...) {
  UseMethod("combine")
}

#' @export
combine.hub_validations <- function(...) {
  # Discard NULLs but preserve empty objects for now. NULLs may be passed as

  # subsequent arguments (e.g., combine(checks, custom_checks) where
  # custom_checks is NULL).
  objects <- rlang::list2(...) |>
    purrr::discard(is.null)

  # Get class from first object (which triggered dispatch) to preserve
  # subclasses (e.g., target_validations)
  orig_class <- class(objects[[1]])

  # Validate all objects have the same class (strict: no subclass mixing)
  validate_internal_class(objects, class = orig_class[1], strict = TRUE)

  # Single input: return as-is (preserves empty objects)
  if (length(objects) == 1L) {
    return(objects[[1]])
  }

  # Multiple inputs: remove empty objects
  non_empty <- purrr::compact(objects)

  # All empty: return first object (preserves class)
  if (length(non_empty) == 0L) {
    return(objects[[1]])
  }

  # Enforce same where (only non-empty objects have where attribute)
  where <- assert_same_where_attr(non_empty)

  combined <- do.call(c, non_empty)

  # Merge warnings attributes from all objects
  warnings <- purrr::map(non_empty, ~ attr(.x, "warnings")) |>
    purrr::list_flatten() |>
    purrr::compact()

  structure(
    combined,
    class = orig_class,
    where = where,
    warnings = if (length(warnings) > 0) warnings else NULL
  )
}

#' @rdname combine
#'
#' @export
combine.hub_validations_collection <- function(...) {
  # Discard NULLs but preserve empty collections for now. NULLs may be passed
  # as subsequent arguments.
  objects <- rlang::list2(...) |>
    purrr::discard(is.null)

  # Get class from first object (which triggered dispatch) to preserve
  # subclasses (e.g., target_validations_collection)
  orig_class <- class(objects[[1]])

  # Validate all objects have the same class (strict: no subclass mixing)
  validate_internal_class(objects, class = orig_class[1], strict = TRUE)

  # Single input: return as-is (preserves empty collections)
  if (length(objects) == 1L) {
    return(objects[[1]])
  }

  # Multiple inputs: remove empty collections
  non_empty <- purrr::compact(objects)

  # All empty: return first object (preserves class)
  if (length(non_empty) == 0L) {
    return(objects[[1]])
  }

  # Extract all hub_validations objects from all collections.
  # unname() each collection to prevent names being used as prefixes.
  all_validations <- purrr::map(non_empty, unname) |>
    purrr::list_flatten()
  combined <- merge_validations_by_where(all_validations)

  # Merge warnings attributes from all collections
  warnings <- purrr::map(non_empty, ~ attr(.x, "warnings")) |>
    purrr::list_flatten() |>
    purrr::compact()

  structure(
    combined,
    class = orig_class,
    warnings = if (length(warnings) > 0) warnings else NULL
  )
}

# Helper to assert all objects have the same where attribute and extract it.
assert_same_where_attr <- function(x) {
  if (length(x) == 0L) {
    return(NULL)
  }

  where_values <- purrr::map_chr(x, extract_where)
  unique_where <- unique(where_values)

  if (length(unique_where) > 1L) {
    cli::cli_abort(
      c(
        "Cannot combine {.cls hub_validations} objects with different
        {.arg where} values.",
        "x" = "Found {length(unique_where)} different values: {.val {unique_where}}"
      )
    )
  }

  unique_where
}
