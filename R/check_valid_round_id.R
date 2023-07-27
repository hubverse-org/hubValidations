#' Check whether the `round_id` determined for the submission is valid
#'
#' @inheritParams check_tbl_colnames
#' @return
#' Depending on whether validation has succeeded, one of:
#' - `<message/check_success>` condition class object.
#' - `<error/check_error>` condition class object.
#'
#' Returned object also inherits from subclass `<hub_check>`.
#' @export
check_valid_round_id <- function(round_id, file_path, hub_path = ".") {
    config_tasks <- hubUtils::read_config(hub_path, "tasks")
    round_ids <- hubUtils::get_round_ids(config_tasks = config_tasks)
    check <- round_id %in% round_ids
    if (!check) {
        details <- cli::format_inline("Must be one of {.val {round_ids}},
                                  NOT {.val {round_id}}")
    } else {
        details <- NULL
    }

    capture_check_cnd(
        check = check,
        file_path = file_path,
        msg_subject = "{.var round_id}",
        msg_attribute = "valid.",
        error = TRUE,
        details = details)
}

