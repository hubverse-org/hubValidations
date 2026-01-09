#' Capture a condition of the result of validation check.
#'
#' @param check logical, the result of a validation check. If `check` is `FALSE`,
#' validation has failed. If `check` is `TRUE`, validation has succeeded.
#' @param file_path character string. Path to the file being validated. Must be
#' the relative path to the hub's `model-output` (or equivalent) directory.
#' @param msg_subject character string. The subject of the validation.
#' @param msg_attribute character string. The attribute of subject being validated.
#' @param msg_verbs character vector of length 2. The verbs describing the state
#' of the attribute in relation to the validation subject. The first element describes
#' the state when validation succeeds, the second element, when validation fails.
#' @param error logical. In the case of validation failure, whether the function
#' should return an object of class `<error/check_error>` (`TRUE`) or
#' `<error/check_failure>` (`FALSE`, default).
#' @param details further details to be appended to the output message.
#' @inheritParams rlang::error_cnd
#'
#' @details
#' Arguments `msg_subject`, `msg_attribute`, `msg_verbs` and `details`
#' accept text that can interpreted and formatted by [cli::format_inline()].
#'
#' @return Depending on whether validation has succeeded and the value
#' of the `error` argument, one of:
#' - `<message/check_success>` condition class object.
#' - `<error/check_failure>` condition class object.
#' - `<error/check_error>` condition class object.
#'
#' Returned object also inherits from subclass `<hub_check>`.
#' @export
#'
#' @examples
#' capture_check_cnd(
#'   check = TRUE, file_path = "test/file.csv",
#'   msg_subject = "{.var round_id}", msg_attribute = "valid.", error = FALSE
#' )
#' capture_check_cnd(
#'   check = FALSE, file_path = "test/file.csv",
#'   msg_subject = "{.var round_id}", msg_attribute = "valid.", error = FALSE,
#'   details = "Must be one of 'A' or 'B', not 'C'"
#' )
#' capture_check_cnd(
#'   check = FALSE, file_path = "test/file.csv",
#'   msg_subject = "{.var round_id}", msg_attribute = "valid.", error = TRUE,
#'   details = "Must be one of {.val {c('A', 'B')}}, not {.val C}"
#' )
capture_check_cnd <- function(
  check,
  file_path,
  msg_subject,
  msg_attribute,
  msg_verbs = c("is", "must be"),
  error = FALSE,
  details = NULL,
  ...
) {
  if (!rlang::is_character(msg_verbs, 2L)) {
    cli::cli_abort(
      "{.arg msg_verbs} must be a character vector of length 2,
                       not class {.cls {class(msg_verbs)}}
                       of length {length(msg_verbs)}"
    )
  }
  call <- rlang::caller_call()
  if (!is.null(call)) {
    call <- rlang::call_name(call)
  }
  details <- paste(details, collapse = " | ")

  if (check) {
    msg <- cli::format_inline(
      paste(msg_subject, msg_verbs[1], msg_attribute, "\n", details)
    )
    res <- rlang::message_cnd(
      c("check_success", "hub_check"),
      where = file_path,
      ...,
      call = call,
      message = msg,
      use_cli_format = TRUE
    )
  } else {
    msg <- cli::format_inline(
      paste(msg_subject, msg_verbs[2], msg_attribute, "\n", details)
    )
    if (error) {
      res <- rlang::error_cnd(
        c("check_error", "hub_check"),
        where = file_path,
        ...,
        call = call,
        message = msg,
        use_cli_format = TRUE
      )
    } else {
      res <- rlang::error_cnd(
        c("check_failure", "hub_check"),
        where = file_path,
        ...,
        call = call,
        message = msg,
        use_cli_format = TRUE
      )
    }
  }
  res
}

#' Capture a simple info message condition
#'
#' Capture a simple info message condition. Useful for communicating when a check
#' is ignored or skipped.
#' @inheritParams capture_check_cnd
#' @param msg Character string. Accepts text that can interpreted and
#' formatted by [cli::format_inline()].
#' @param call The defused call of the function that generated the message.
#' Use to override default which uses the caller call. See [rlang::stack]
#' for more details.
#'
#' @return A `<message/check_info>` condition class object. Returned object also
#' inherits from subclass `<hub_check>`.
#' @export
capture_check_info <- function(file_path, msg, call = rlang::caller_call()) {
  if (!is.null(call)) {
    call <- rlang::call_name(call)
  }

  rlang::message_cnd(
    c("check_info", "hub_check"),
    where = file_path,
    call = call,
    message = cli::format_inline(msg),
    use_cli_format = TRUE
  )
}

#' Capture a validation warning condition
#'
#' Capture a warning about the validation process. Unlike check results
#' (success/failure/error), validation warnings are informational messages
#' about the validation process itself rather than validation outcomes.
#'
#' Validation warnings can be attached at two levels:
#' - **Validation-level**: Stored as an attribute on `hub_validations` objects,
#'   printed prominently by default.
#' - **Check-level**: Stored in a `warnings` field on individual check results,
#'   printed only when `verbose = TRUE`.
#'
#' @param msg Character string. The warning message. Accepts text that can be
#'   interpreted and formatted by [cli::format_inline()].
#' @param where Optional. Character string indicating the location or context
#'   of the warning (e.g., file path, `"hub-config"`). Used as metadata.
#' @param call The defused call of the function that generated the warning.
#'   Use to override default which uses the caller call. See [rlang::stack]
#'   for more details.
#' @param ... Additional named fields to include in the warning condition object.
#'   Useful for attaching structured data (e.g., `config_files = c("tasks.json")`).
#'
#' @return A `<warning/validation_warning>` condition class object.
#' @export
#'
#' @examples
#' # Simple warning
#' capture_validation_warning(
#'   msg = "Configuration files were modified"
#' )
#'
#' # Warning with location and additional structured data
#' config_files <- c("tasks.json", "admin.json")
#' capture_validation_warning(
#'   msg = "Config files modified: {.path {config_files}}",
#'   where = "hub-config",
#'   config_files = config_files
#' )
capture_validation_warning <- function(
  msg,
  where = NULL,
  call = rlang::caller_call(),
  ...
) {
  if (!is.null(call)) {
    call <- rlang::call_name(call)
  }

  rlang::warning_cnd(
    "validation_warning",
    where = where,
    call = call,
    message = cli::format_inline(msg),
    use_cli_format = TRUE,
    ...
  )
}
