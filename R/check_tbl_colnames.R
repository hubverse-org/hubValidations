#' Check column names of model output data
#'
#' Checks that a tibble/data.frame of data read in from the file being validated
#' contains the expected task ID and standard column names according the round
#' configuration being validated against.
#' @param tbl a tibble/data.frame of the contents of the file being validated.
#' @param round_id character string. The round identifier.
#' @param file_path character string. Path to the file being validated relative to
#' the hub's model-output directory.
#' @inheritParams hubUtils::connect_hub
#' @return
#' Depending on whether validation has succeeded, one of:
#' - `<message/check_success>` condition class object.
#' - `<error/check_error>` condition class object.
#'
#' Returned object also inherits from subclass `<hub_check>`.
#' @export
check_tbl_colnames <- function(tbl, round_id, file_path, hub_path = ".") {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  round_cols <- unname(c(
    hubUtils::get_round_task_id_names(config_tasks, round_id),
    hubUtils::std_colnames[names(hubUtils::std_colnames) != "model_id"]
  ))
  tbl_cols <- names(tbl)

  check <- setequal(round_cols, tbl_cols)

  details <- NULL

  if (!check && any(!round_cols %in% tbl_cols)) {
    details <- cli::format_inline(
      "Expected column{?s} {.val {round_cols[!round_cols %in% tbl_cols]}}
            not present in file."
    )
  }
  if (!check && any(!tbl_cols %in% round_cols)) {
    details <- paste(
      details,
      cli::format_inline(
        "Unexpected column{?s} {.val {tbl_cols[!tbl_cols %in% round_cols]}}
            present in file."
      )
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Column names",
    msg_attribute = "consistent with expected round task IDs and std column names.",
    msg_verbs = c("are", "must be"),
    details = details,
    error = TRUE
  )
}
