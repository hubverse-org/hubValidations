#' Print results of `validate_...()` function as a bullet list
#'
#' @param x An object of class `hub_validations`
#' @param ... Unused argument present for class consistency
#'
#'
#' @export
print.hub_validations <- function(x, ...) {

    msg <- stats::setNames(
        paste(
            fs::path_file(purrr::map_chr(x, "where")),
            purrr::map_chr(x, "message"),
            sep = ": "
        ),
        dplyr::case_when(
            purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_success")) ~ "v",
            purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_failure")) ~ "!",
            purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_exec_warn")) ~ "!",
            purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_error")) ~ "x",
            purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_exec_error")) ~ "x",
            purrr::map_lgl(x, ~ rlang::inherits_any(.x, "check_info")) ~ "i",
            TRUE ~ "*"
        )
    )

    octolog::octo_inform(msg)

}

summary.hub_validations <- function(x, ...) {

    # TODO
    NULL

}

# TODO: Code to consider implementing more hierarchical printing of messages.
# Currently not implemented as pr_hub_validations class not implemented.
#' Print results of `validate_pr()` function as a bullet list
#'
#' @param x An object of class `pr_hub_validations`
#' @param ... Unused argument present for class consistency
#'
#'
#' @export
print.pr_hub_validations <- function(x, ...) {
    purrr::map(x, print)
}
