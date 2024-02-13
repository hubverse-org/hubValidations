#' Check time difference between values in two date columns equal a defined period.
#'
#' @param t0_colname Character string. The name of the time zero date column.
#' @param t1_colname Character string. The name of the time zero + 1 time step date column.
#' @param timediff an object of class `lubridate` [`Period-class`] and length 1.
#' @details
#' Should be deployed as part of `validate_model_data` optional checks.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
opt_check_tbl_col_timediff <- function(tbl, file_path, hub_path,
                                       t0_colname, t1_colname,
                                       timediff = lubridate::weeks(2)) {
  checkmate::assert_class(timediff, "Period")
  checkmate::assert_scalar(timediff)
  checkmate::assert_character(t0_colname, len = 1L)
  checkmate::assert_character(t1_colname, len = 1L)
  checkmate::assert_choice(t0_colname, choices = names(tbl))
  checkmate::assert_choice(t1_colname, choices = names(tbl))

  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  schema <- hubUtils::create_hub_schema(config_tasks,
    partitions = NULL,
    r_schema = TRUE
  )
  assert_column_date(t0_colname, schema)
  assert_column_date(t1_colname, schema)

  if (!lubridate::is.Date(tbl[[t0_colname]])) {
    tbl[, t0_colname] <- as.Date(tbl[[t0_colname]])
  }
  if (!lubridate::is.Date(tbl[[t1_colname]])) {
    tbl[, t1_colname] <- as.Date(tbl[[t1_colname]])
  }

  compare <- tbl[[t1_colname]] - tbl[[t0_colname]] == timediff
  check <- all(compare)
  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "t1 var value{?s} {.val {tbl[[t1_colname]][!compare]}} invalid."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "Time differences between t0 var {.var {t0_colname}} and t1 var
        {.var {t1_colname}}"
    ),
    msg_verbs = c("all match", "do not all match"),
    msg_attribute = cli::format_inline("expected period of {.val {timediff}}."),
    details = details
  )
}

assert_column_date <- function(colname, schema) {
  if (schema[colname] != "Date") {
    cli::cli_abort(
      "Column {.arg colname} must be configured as {.cls Date} not
      {.cls {schema[colname]}}.",
      call = rlang::caller_call()
    )
  }
}
