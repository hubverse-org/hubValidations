#' Capture an execution error condition
#'
#' Capture an execution error condition. Useful for communicating when a check
#' execution has failed. Usually used in conjunction with [`try`].
#' @inheritParams capture_check_cnd
#' @param msg Character string.
#' @return A `<error/check_exec_error>` condition class object. Returned object also
#' inherits from subclass `<hub_check>`.
#' @export
capture_exec_error <- function(file_path, msg, call = NULL) {
  if (is.null(call)) {
    call <- rlang::caller_call()
    if (!is.null(call)) {
        call <- rlang::call_name(call)
    }
  }

  rlang::error_cnd(
    c("check_exec_error", "hub_check"),
    where = file_path,
    call = call,
    message = msg,
    use_cli_format = TRUE
  )
}


#' Capture an execution warning condition
#'
#' Capture an execution warning condition. Useful for communicating when a check
#' execution has failed. Usually used in conjunction with [`try`].
#' @inheritParams capture_check_cnd
#' @param msg Character string.
#'
#' @return A `<warning/check_exec_warn>` condition class object. Returned object also
#' inherits from subclass `<hub_check>`.
#' @export
capture_exec_warning <- function(file_path, msg, call = NULL) {
    if (is.null(call)) {
        call <- rlang::caller_call()
    }
    if (!is.null(call)) {
        call <- rlang::call_name(call)
    }

    rlang::warning_cnd(
        c("check_exec_warn", "hub_check"),
        where = file_path,
        call = call,
        message = msg,
        use_cli_format = TRUE
    )
}
