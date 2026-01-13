#' Create new or convert list to `target_validations` S3 class object
#'
#' @param ... named elements to be included. Each element must be an object which
#' inherits from class `<hub_check>`.
#' @param x a list of named elements. Each element must be an object which
#' inherits from class `<hub_check>`.
#'
#' @return an S3 object of class `<target_validations>`.
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
  class(x) <- c("target_validations", "hub_validations", "list")
  x
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
  class(x) <- c("target_validations", "hub_validations", "list")
  x
}
