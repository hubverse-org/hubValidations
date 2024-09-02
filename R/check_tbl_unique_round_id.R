#' Check model output data tbl contains a single unique round ID.
#'
#' @param round_id_col Character string. The name of the column containing
#' `round_id`s. Usually, the value of round property `round_id` in hub `tasks.json`
#' config file.
#' @inheritParams check_tbl_colnames
#' @return
#' Depending on whether validation has succeeded, one of:
#' - `<message/check_success>` condition class object.
#' - `<error/check_error>` condition class object.
#'
#' If `round_id_from_variable: false` and no `round_id_col` name is provided,
#' check is skipped and a `<message/check_info>` condition class object is
#' returned. If no valid `round_id_col` name is provided or can extracted from
#' config (check through `check_valid_round_id_col`), a `<message/check_error>`
#' condition class object is returned and the rest of the check skipped.
#' @details
#' This check only applies to files being submitted to rounds where
#' `round_id_from_variable: true` or where a `round_id_col` name is explicitly
#' provided. Skipped otherwise.
#' @export
check_tbl_unique_round_id <- function(tbl, file_path, hub_path,
                                      round_id_col = NULL) {
  check_round_id_col <- check_valid_round_id_col(
    tbl, file_path, hub_path, round_id_col
  )

  if (is_info(check_round_id_col)) {
    return(check_round_id_col)
  }
  if (is_failure(check_round_id_col) || is_exec_error(check_round_id_col)) {
    class(check_round_id_col)[1] <- "check_error"
    check_round_id_col$call <- rlang::call_name(rlang::current_call())
    return(check_round_id_col)
  }

  if (is.null(round_id_col)) {
    round_id_col <- get_file_round_id_col(file_path, hub_path)
  }
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
    msg_subject = cli::format_inline(
      "{.var round_id} column {.val {round_id_col}}"
    ),
    msg_attribute = "a single, unique round ID value.",
    msg_verbs = c("contains", "must contain"),
    error = TRUE,
    details = details
  )
}
