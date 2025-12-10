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
  objects <- rlang::list2(...) %>%
    purrr::compact()
  validate_internal_class(objects, class = "hub_validations")

  combined <- c(...)
  if (is.null(names(combined))) {
    combined_names <- NULL
  } else {
    combined_names <- make.unique(names(combined), sep = "_")
  }

  # Merge warnings attributes from all objects
  warnings <- purrr::map(objects, ~ attr(.x, "warnings")) %>%
    purrr::list_flatten() %>%
    purrr::compact()

  structure(
    combined,
    class = c("hub_validations", "list"),
    names = combined_names,
    warnings = if (length(warnings) > 0) warnings else NULL
  )
}
#' Concatenate `target_validations` S3 class objects
#'
#' @param ... `target_validations` S3 class objects to be concatenated.
#' @return a `target_validations` S3 class object.

#' @export
combine.target_validations <- function(...) {
  objects <- rlang::list2(...) %>%
    purrr::compact()
  validate_internal_class(objects, class = "target_validations")

  combined <- c(...)
  if (is.null(names(combined))) {
    combined_names <- NULL
  } else {
    combined_names <- make.unique(names(combined), sep = "_")
  }

  # Merge warnings attributes from all objects
  warnings <- purrr::map(objects, ~ attr(.x, "warnings")) %>%
    purrr::list_flatten() %>%
    purrr::compact()

  structure(
    combined,
    class = c("target_validations", "hub_validations", "list"),
    names = combined_names,
    warnings = if (length(warnings) > 0) warnings else NULL
  )
}
