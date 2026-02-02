#' Create new or convert list to `target_validations` S3 class object
#'
#' A `target_validations` object contains validation results for a single
#' validation subject. Depending on context, this could be a target data file,
#' the hub configuration directory (`hub-config`), or a target dataset type
#' (`time-series`, `oracle-output`).
#' All checks must have the same `$where` value, which is extracted and stored
#' as the `where` attribute.
#'
#' @param ... named elements to be included. Each element must be an object which
#'   inherits from class `<hub_check>`. All checks must have the same `$where` value.
#' @param x a list of named elements. Each element must be an object which
#'   inherits from class `<hub_check>`. All checks must have the same `$where` value.
#'
#' @return an S3 object of class `<target_validations>` with a `where` attribute.
#' @export
#' @describeIn new_target_validations Create new `<target_validations>` S3 class object
#' @examples
#' new_target_validations()
#'
#' hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
#' file_path <- "time-series.csv"
#' new_target_validations(
#'   target_file_name = check_target_file_name(file_path),
#'   target_file_ext_valid = check_target_file_ext_valid(file_path)
#' )
#' x <- list(
#'   target_file_name = check_target_file_name(file_path),
#'   target_file_ext_valid = check_target_file_ext_valid(file_path)
#' )
#' as_target_validations(x)
#' file_path <- "time-series/target=flu_hosp_rate/part-0.parquet"
#' new_target_validations(
#'   target_file_name = check_target_file_name(file_path),
#'   target_file_ext_valid = check_target_file_ext_valid(file_path)
#' )
new_target_validations <- function(...) {
  x <- rlang::dots_list(...) |>
    purrr::compact()

  validate_internal_class(x, class = "hub_check")
  where <- assert_same_where(x)

  if (length(x) == 0L) {
    names(x) <- NULL
  }

  structure(
    x,
    class = c("target_validations", "hub_validations", "list"),
    where = where
  )
}

#' @export
#' @describeIn new_target_validations Convert list to `<target_validations>` S3 class object
as_target_validations <- function(x) {
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
    class = c("target_validations", "hub_validations", "list"),
    where = where
  )
}

# ---- target_validations_collection class ----

#' Create new or convert list to `target_validations_collection` S3 class object
#'
#' A `target_validations_collection` is a container for target validation results
#' from multiple validation subjects. It is a named list where each element is a
#' `target_validations` object. Names are automatically extracted from the
#' `where` attribute of each `target_validations` object. If multiple
#' `target_validations` objects have the same `where` value, they are merged using
#' [combine()]. Empty `target_validations` objects are ignored.
#'
#' @param ... `target_validations` objects to be included.
#' @param x a list where each element is a `target_validations` object.
#'
#' @return an S3 object of class `<target_validations_collection>`. Elements are
#'   named by their `where` attribute
#'   (e.g., `collection[["path/to/file.csv"]]`).
#' @export
#' @describeIn new_target_validations_collection Create new
#'   `<target_validations_collection>` S3 class object
#' @examples
#' new_target_validations_collection()
#'
#' # Create validations for two different files
#' file_path_1 <- "time-series.csv"
#' validations_1 <- new_target_validations(
#'   target_file_name = check_target_file_name(file_path_1),
#'   target_file_ext_valid = check_target_file_ext_valid(file_path_1)
#' )
#'
#' file_path_2 <- "other-data.csv"
#' validations_2 <- new_target_validations(
#'   target_file_name = check_target_file_name(file_path_2),
#'   target_file_ext_valid = check_target_file_ext_valid(file_path_2)
#' )
#'
#' # Combine into a collection
#' collection <- new_target_validations_collection(validations_1, validations_2)
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
#' # Access a specific check within a file's validations
#' collection[["time-series.csv"]]$target_file_name
new_target_validations_collection <- function(...) {
  x <- rlang::dots_list(...) |>
    purrr::compact()

  validate_internal_class(x, class = "target_validations")
  if (length(x) > 0L) {
    x <- merge_validations_by_where(x)
  } else {
    names(x) <- NULL
  }
  class(x) <- c(
    "target_validations_collection",
    "hub_validations_collection",
    "list"
  )
  x
}

#' @export
#' @describeIn new_target_validations_collection Convert list to
#'   `<target_validations_collection>` S3 class object
as_target_validations_collection <- function(x) {
  if (!inherits(x, "list")) {
    cli::cli_abort(
      c(
        "x" = "{.var x} must inherit from class {.cls list} not {.cls {class(x)}}."
      )
    )
  }
  x <- purrr::compact(x)
  validate_internal_class(x, class = "target_validations")
  if (length(x) > 0L) {
    x <- merge_validations_by_where(x)
  } else {
    names(x) <- NULL
  }
  class(x) <- c(
    "target_validations_collection",
    "hub_validations_collection",
    "list"
  )
  x
}
