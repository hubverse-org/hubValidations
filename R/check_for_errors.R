#' Raise conditions stored in a `hub_validations` object
#'
#' This is meant to be used in CI workflows to raise conditions from
#' `hub_validations` objects.
#'
#' @param x A `hub_validations` object
#'
#' @return An error if one of the elements of `x` is of class `check_failure`,
#' `check_error`, `check_exec_error` or `check_exec_warning`.
#' `TRUE` invisibly otherwise.
#'
#' @export
check_for_errors <- function(x) {
    flag_checks <- x[purrr::map_lgl(x, ~not_pass(.x))]

    class(flag_checks) <- c("hub_validations", "list")

    if (length(flag_checks) > 0) {
        print(flag_checks)
        rlang::abort(
            "\nThe validation checks produced some failures/errors reported above."
        )
    }

    cli::cli_alert_success("All validation checks have been successful.")
    return(invisible(TRUE))
}
