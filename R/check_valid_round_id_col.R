#' Check that any round_id_col name provided or extracted from the hub config is
#' valid.
#'
#' @inherit check_tbl_unique_round_id params details
#' @return
#' Depending on whether validation has succeeded, one of:
#' - `<message/check_success>` condition class object.
#' - `<warning/check_warning>` condition class object.
#'
#' If `round_id_from_variable: false` and no `round_id_col` name is provided,
#' check is skipped and a `<message/check_info>` condition class object is
#' returned.
#' Returned object also inherits from subclass `<hub_check>`.
#' @export
check_valid_round_id_col <- function(tbl, file_path, hub_path, round_id_col = NULL) {
  if (is.null(round_id_col)) {
    if (is_round_id_from_variable(file_path, hub_path)) {
      round_id_col <- get_file_round_id_col(file_path, hub_path)
    } else {
      # If round IDs not configured as values in variable and no round_id_col
      # skip check.
      return(
        capture_check_info(
          file_path,
          msg = "Check {.code check_tbl_unique_round_id} only applicable when
          {.var round_id_col} provided. Check skipped."
        )
      )
    }
  }

  if (is.null(round_id_col)) {
    # First check whether a round_id_col has successfully been identified from
    # the config file. If not check fails.
    check <- FALSE
    details <- cli::format_inline(
      "{.val {round_id_col}} name could not be parsed from config."
    )
  } else {
    check <- round_id_col %in% names(tbl)
    if (check) {
      details <- NULL
    } else {
      task_id_vars <- names(tbl)[!names(tbl) %in% hubUtils::std_colnames]
      details <- cli::format_inline("Must be one of
                                      {.val {task_id_vars}} not
                                      {.val {round_id_col}}.")
    }
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var round_id_col} name",
    msg_attribute = "valid.",
    details = details
  )
}
