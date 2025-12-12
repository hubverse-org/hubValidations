#' Raise conditions stored in a `hub_validations` S3 object
#'
#' This is meant to be used in CI workflows to raise conditions from
#' `hub_validations` objects but can also be useful locally to summarise the
#' results of checks contained in a `hub_validations` S3 object.
#'
#' @param x A `hub_validations` object
#' @param verbose Logical. If `TRUE`, print the results of all checks prior to
#' raising condition and summarising `hub_validations` S3 object check results.
#' @param show_warnings Logical. If `TRUE`, print check-level warnings inline
#' with their checks. Validation-level warnings are always printed. Default
#' `FALSE`.
#'
#' @return An error if one of the elements of `x` is of class `check_failure`,
#' `check_error`, `check_exec_error` or `check_exec_warning`.
#' `TRUE` invisibly otherwise.
#'
#' @export
check_for_errors <- function(x, verbose = FALSE, show_warnings = FALSE) {
  # Store validation-level warnings and strip from object to control when printed
  validation_warnings <- attr(x, "warnings")
  attr(x, "warnings") <- NULL

  if (verbose) {
    cli::cli_h2("Individual check results")
    print(x, show_check_warnings = show_warnings)
    cli::cli_h1("Overall validation result")
  }

  flag_checks <- x[purrr::map_lgl(x, ~ not_pass(.x))]
  class(flag_checks) <- c("hub_validations", "list")

  if (length(flag_checks) > 0) {
    # Print validation-level warnings with failures summary
    print_validation_warnings(validation_warnings)
    print(flag_checks, show_check_warnings = show_warnings)
    rlang::abort(
      "\nThe validation checks produced some failures/errors reported above."
    )
  }

  # Print validation-level warnings before success message
  print_validation_warnings(validation_warnings)
  cli::cli_alert_success("All validation checks have been successful.")
  return(invisible(TRUE))
}
