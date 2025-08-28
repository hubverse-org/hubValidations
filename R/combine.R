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

  combined <- c(...)
  if (is.null(names(combined))) {
    combined_names <- NULL
  } else {
    combined_names <- make.unique(names(combined), sep = "_")
  }
  structure(
    combined,
    class = c("hub_validations", "list"),
    names = combined_names
  )
}
#' Concatenate `target_validations` S3 class objects
#'
#' @param ... `target_validations` S3 class objects to be concatenated.
#' @return a `target_validations` S3 class object.

#' @export
combine.target_validations <- function(...) {
  rlang::list2(...) %>%
    purrr::compact() %>%
    validate_internal_class(class = "target_validations")

  combined <- c(...)
  if (is.null(names(combined))) {
    combined_names <- NULL
  } else {
    combined_names <- make.unique(names(combined), sep = "_")
  }
  structure(
    combined,
    class = c("target_validations", "hub_validations", "list"),
    names = combined_names
  )
}
