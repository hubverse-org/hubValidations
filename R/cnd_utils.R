#' Get status of a hub check
#'
#' @param x an object that inherits from class `<hub_check>` to test.
#'
#' @return Logical. Is given status of check TRUE?
#' @describeIn is_success Is check success?
#' @export
is_success <- function(x) {
  inherits(x, "check_success")
}
#' @describeIn is_success Is check failure?
#' @export
is_failure <- function(x) {
  inherits(x, "check_failure")
}
#' @describeIn is_success Is check error?
#' @export
is_error <- function(x) {
  inherits(x, "check_error")
}
#' @describeIn is_success Is check info?
#' @export
is_info <- function(x) {
  inherits(x, "check_info")
}
#' @export
#' @describeIn is_success Did check not pass?
not_pass <- function(x) {
  !inherits(x, "check_success") & !inherits(x, "check_info")
}

#' @describeIn is_success Is exec error?
#' @export
is_exec_error <- function(x) {
  inherits(x, "check_exec_error")
}

#' @describeIn is_success Is exec warning?
#' @export
is_exec_warn <- function(x) {
  inherits(x, "check_exec_warn")
}

#' @describeIn is_success Is error or exec error?
#' @export
is_any_error <- function(x) {
  inherits(x, "check_error") | inherits(x, "check_exec_error")
}
