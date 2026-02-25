#' Raise conditions stored in validation objects
#'
#' Checks validation objects for errors and raises conditions if any are found.
#' Works with `hub_validations` and `hub_validations_collection` objects, as
#' well as their subclasses (`target_validations` and
#' `target_validations_collection`). Can be used in CI workflows to signal
#' validation failures, or locally to summarise validation results.
#'
#' For more details on these classes, see
#' [article on `<hub_validations>` S3 class objects](
#' https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).
#'
#' @param x A `hub_validations` or `hub_validations_collection` object
#'   (including subclasses `target_validations` and
#'   `target_validations_collection`).
#' @param verbose Logical. If `TRUE`, print the results of all checks prior to
#' raising condition and summarising validation object check results.
#' @param show_warnings Logical. If `TRUE`, print check-level warnings inline
#' with their checks. Validation-level warnings are always printed. Default
#' `FALSE`.
#'
#' @return An error if one of the elements of `x` is of class `check_failure`,
#' `check_error`, `check_exec_error` or `check_exec_warning`.
#' `TRUE` invisibly otherwise.
#' @seealso [validate_submission()], [validate_pr()],
#'   [validate_target_submission()], [validate_target_pr()]
#'
#' @export
check_for_errors <- function(x, verbose = FALSE, show_warnings = FALSE) {
  UseMethod("check_for_errors")
}

#' @export
check_for_errors.hub_validations <- function(
  x,
  verbose = FALSE,
  show_warnings = FALSE
) {
  # Store validation-level warnings and strip from object to control when printed
  validation_warnings <- attr(x, "warnings")
  attr(x, "warnings") <- NULL

  if (verbose) {
    cli::cli_h2("Individual check results")
    print(x, show_check_warnings = show_warnings)
    cli::cli_h1("Overall validation result")
  }

  flag_checks <- extract_failing_checks(x)

  if (!is.null(flag_checks)) {
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
  invisible(TRUE)
}

#' @export
check_for_errors.hub_validations_collection <- function(
  x,
  verbose = FALSE,
  show_warnings = FALSE
) {
  # Store validation-level warnings and strip from object to control when printed
  validation_warnings <- attr(x, "warnings")
  attr(x, "warnings") <- NULL

  if (verbose) {
    cli::cli_h2("Individual check results")
    print(x, show_check_warnings = show_warnings)
    cli::cli_h1("Overall validation result")
  }

  # Extract failing checks from each file, removing files with no failures
  flag_checks_by_file <- purrr::map(x, extract_failing_checks) |>
    purrr::compact()

  if (length(flag_checks_by_file) > 0) {
    # Print validation-level warnings with failures summary
    print_validation_warnings(validation_warnings)

    print(
      as_hub_validations_collection(flag_checks_by_file),
      show_check_warnings = show_warnings
    )

    rlang::abort(
      "\nThe validation checks produced some failures/errors reported above."
    )
  }

  # Print validation-level warnings before success message
  print_validation_warnings(validation_warnings)
  cli::cli_alert_success("All validation checks have been successful.")
  invisible(TRUE)
}

# Extract checks that didn't pass from a hub_validations object.
# Returns NULL if all checks passed, otherwise a hub_validations object
# containing only the failing checks.
extract_failing_checks <- function(validations) {
  failed <- validations[purrr::map_lgl(validations, not_pass)]
  if (length(failed) == 0L) NULL else failed
}
