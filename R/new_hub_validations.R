#' Create new or convert list to `hub_validations` S3 class object
#'
#' @param ... named elements to be included. Each element must be an object which
#' inherits from class `<hub_check>`.
#' @param x a list of named elements. Each element must be an object which
#' inherits from class `<hub_check>`.
#'
#' @return an S3 object of class `<hub_validations>`.
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
  class(x) <- c("hub_validations", "list")
  x
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
  class(x) <- c("hub_validations", "list")
  x
}
