#' Capture a condition of the result of validation check.
#'
#' @param check logical, the result of a validation check. If `check` is `FALSE`,
#' validation has failed. If `check` is `TRUE`, validation has succeeded.
#' @param file_path character string. Path to the file being validated.
#' @param msg_subject character string. The subject of the validation.
#' @param msg_attribute character string. The attribute of subject being validated.
#' @param msg_verbs character vector of length 2. The verbs describing the state
#' of the attribute in relation to the validation subject. The first element describes
#' the state when validation succeeds, the second element, when validation fails.
#' @param error logical. In the case of validation failure, whether the function
#' should return an object of class `<error/check_error>` (`TRUE`) or
#' `<warning/check_failure>` (`FALSE`, default).
#' @param details further details to be appended to the output message.
#'
#' @details
#' Arguments `msg_subject`, `msg_attribute`, `msg_verbs` and `details`
#' accept text that can interpreted and formatted by [cli::format_inline()].
#'
#' @return A list containing one of:
#' - `<message/check_success>` condition class object
#' - `<warning/check_failure>` condition class object
#' - `<error/check_error>` condition class object
#'
#' depending on whether validation has succeeded and the value of the `error` argument.
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
capture_check_cnd <- function(check, file_path, msg_subject, msg_attribute,
                              msg_verbs = c("is", "must be"), error = FALSE,
                              details = NULL) {
  if (!rlang::is_character(msg_verbs, 2L)) {
    cli::cli_abort("{.arg msg_verbs} must be a character vector of length 2,
                       not class {.cls {class(msg_verbs)}}
                       of length {length(msg_verbs)}")
  }

  if (check) {
    msg <- cli::format_inline(
      paste(msg_subject, msg_verbs[1], msg_attribute, "\n", details)
    )
    res <- rlang::message_cnd(
      c("check_success", "hub_check"),
      where = file_path,
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
        message = msg,
        use_cli_format = TRUE
      )
    } else {
      res <- rlang::warning_cnd(
        c("check_failure", "hub_check"),
        where = file_path,
        message = msg,
        use_cli_format = TRUE
      )
    }
  }
  return(res)
}
