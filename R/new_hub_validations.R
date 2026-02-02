#' Create new or convert list to `hub_validations` S3 class object
#'
#' A `hub_validations` object contains validation results for a single
#' validation subject. Depending on context, this could be a file, a
#' configuration directory (`hub-config`), or a target dataset type
#' (`time-series`, `oracle-output`).
#' All checks must have the same `$where` value, which is extracted and stored
#' as the `where` attribute.
#'
#' @param ... named elements to be included. Each element must be an object which
#'   inherits from class `<hub_check>`. All checks must have the same `$where` value.
#' @param x a list of named elements. Each element must be an object which
#'   inherits from class `<hub_check>`. All checks must have the same `$where` value.
#'
#' @return an S3 object of class `<hub_validations>` with a `where` attribute.
#' @export
#' @describeIn new_hub_validations Create new `<hub_validations>` S3 class object
#' @examples
#' new_hub_validations()
#'
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' new_hub_validations(
#'   file_exists = check_file_exists(file_path, hub_path),
#'   file_name = check_file_name(file_path)
#' )
#' x <- list(
#'   file_exists = check_file_exists(file_path, hub_path),
#'   file_name = check_file_name(file_path)
#' )
#' as_hub_validations(x)
new_hub_validations <- function(...) {
  x <- rlang::dots_list(...) |>
    purrr::compact()

  validate_internal_class(x, class = "hub_check")
  where <- assert_same_where(x)

  if (length(x) == 0L) {
    names(x) <- NULL
  }

  structure(
    x,
    class = c("hub_validations", "list"),
    where = where
  )
}

#' @export
#' @describeIn new_hub_validations Convert list to `<hub_validations>` S3 class object
as_hub_validations <- function(x) {
  if (!inherits(x, "list")) {
    cli::cli_abort(
      c(
        "x" = "{.var x} must inherit from class {.cls list} not {.cls {class(x)}}."
      )
    )
  }
  validate_internal_class(x, class = "hub_check")
  where <- assert_same_where(x)

  if (length(x) == 0L) {
    names(x) <- NULL
  }

  structure(
    x,
    class = c("hub_validations", "list"),
    where = where
  )
}

# ---- hub_validations_collection class ----

#' Create new or convert list to `hub_validations_collection` S3 class object
#'
#' A `hub_validations_collection` is a container for validation results from
#' multiple validation subjects. It is a named list where each element is a
#' `hub_validations` object. Names are automatically extracted from the
#' `where` attribute of each `hub_validations` object. If multiple
#' `hub_validations` objects have the same `where` value, they are merged using
#' [combine()]. Empty `hub_validations` objects are ignored.
#'
#' @param ... `hub_validations` objects to be included.
#' @param x a list where each element is a `hub_validations` object.
#'
#' @return an S3 object of class `<hub_validations_collection>`. Elements are
#'   named by their `where` attribute
#'   (e.g., `collection[["path/to/file.csv"]]`).
#' @export
#' @describeIn new_hub_validations_collection Create new
#'   `<hub_validations_collection>` S3 class object
#' @examples
#' new_hub_validations_collection()
#'
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#'
#' # Create validations for two different files
#' file_path_1 <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' validations_1 <- new_hub_validations(
#'   file_exists = check_file_exists(file_path_1, hub_path),
#'   file_name = check_file_name(file_path_1)
#' )
#'
#' file_path_2 <- "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
#' validations_2 <- new_hub_validations(
#'   file_exists = check_file_exists(file_path_2, hub_path),
#'   file_name = check_file_name(file_path_2)
#' )
#'
#' # Combine into a collection
#' collection <- new_hub_validations_collection(validations_1, validations_2)
#'
#' # Print the collection
#' collection
#'
#' # Get file paths (element names)
#' names(collection)
#'
#' # Access validations for a specific file
#' collection[[file_path_1]]
#'
#' # Access validations for a specific file and check
#' collection$`team1-goodmodel/2022-10-08-team1-goodmodel.csv`$file_exists
new_hub_validations_collection <- function(...) {
  x <- rlang::dots_list(...) |>
    purrr::compact()

  validate_internal_class(x, class = "hub_validations")
  if (length(x) > 0L) {
    x <- merge_validations_by_where(x)
  } else {
    names(x) <- NULL
  }
  class(x) <- c("hub_validations_collection", "list")
  x
}

# Helper to merge a list of hub_validations objects by where attribute.
# Objects with the same where value are combined using combine().
# Returns a named list where names are the where values.
merge_validations_by_where <- function(x) {
  if (length(x) == 0L) {
    return(x)
  }

  where_values <- purrr::map_chr(x, extract_where)
  unique_where <- unique(where_values)

  purrr::map(unique_where, function(w) {
    same_where <- x[where_values == w]
    if (length(same_where) == 1L) {
      same_where[[1]]
    } else {
      do.call(combine, same_where)
    }
  }) |>
    purrr::set_names(unique_where)
}

# Helper to extract where attribute from hub_validations object.
extract_where <- function(x) {
  where <- attr(x, "where")
  if (is.null(where)) {
    cli::cli_abort(
      c(
        "Cannot determine where for {.cls hub_validations} object.",
        "x" = "Object has no {.arg where} attribute."
      )
    )
  }
  where
}

#' @export
#' @describeIn new_hub_validations_collection Convert list to
#'   `<hub_validations_collection>` S3 class object
as_hub_validations_collection <- function(x) {
  if (!inherits(x, "list")) {
    cli::cli_abort(
      c(
        "x" = "{.var x} must inherit from class {.cls list} not {.cls {class(x)}}."
      )
    )
  }
  x <- purrr::compact(x)
  validate_internal_class(x, class = "hub_validations")
  if (length(x) > 0L) {
    x <- merge_validations_by_where(x)
  } else {
    names(x) <- NULL
  }
  class(x) <- c("hub_validations_collection", "list")
  x
}
