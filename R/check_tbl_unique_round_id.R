#' Check model output data tbl contains a single unique round ID.
#'
#' @param tbl A tibble. The contents of model output data file being validated.
#' @param round_id_col Character string. The name of the column containing
#' `round_id`s. Usually, the value of round property `round_id` in hub `tasks.json`
#' config file.
#' @inheritParams check_tbl_colnames
#' @return
#' #' Depending on whether validation has succeeded, one of:
#' - `<message/check_success>` condition class object.
#' - `<warning/check_error>` condition class object.
#'
#' If `round_id_from_variable: false`, check is skipped and a
#' `<message/check_info>` condition class object is returned.
#' Returned object also inherits from subclass `<hub_check>`.
#' @details
#' This check only applies to files being submitted to rounds where
#' `round_id_from_variable: true` and is skipped otherwise.
#' @export
check_tbl_unique_round_id <- function(tbl, round_id_col, file_path, hub_path) {
  if (!is_round_id_from_variable(file_path, hub_path)) {
    return(
      capture_check_info(
        file_path,
        msg =  "Check {.code check_tbl_unique_round_id} only applicable to rounds
        where {.code round_id_from_variable} is {.code TRUE}. Check skipped."
      )
    )
  }
  round_id_col <- rlang::arg_match(round_id_col, values = names(tbl))

  unique_round_ids <- unique(tbl[[round_id_col]])
  check <- length(unique_round_ids) == 1L

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "Column actually contains {.val {length(unique_round_ids)}}
            round ID values, {.val {unique_round_ids}}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline("{.var round_id} column
                                                       {.val {round_id_col}}"),
    msg_attribute = "a single, unique round ID value.",
    msg_verbs = c("contains", "must contain"),
    error = TRUE,
    details = details
  )
}
