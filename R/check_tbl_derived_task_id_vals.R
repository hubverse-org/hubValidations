#' Check derived task ID columns contain valid values
#'
#' `r lifecycle::badge("superseded")`
#'
#' `check_tbl_values()` validates derived task ID columns like any other task
#' ID column, so `validate_model_data()` no longer runs this check. It remains
#' available as a custom check.
#'
#' This check is used to validate that values in any derived task ID columns
#' matches accepted values for each derived task ID in the config.
#' Given the dependence of derived task IDs on the values of other values,
#' it ignores the combinations of derived task ID values with those of other task IDs
#' and focuses only on identifying values that do not match the accepted values.
#' @inherit check_tbl_colnames params
#' @inheritParams check_tbl_values
#' @param derived_task_ids Character vector of derived task ID names (task IDs
#' whose values depend on other task IDs) to validate. Defaults to extracting
#' derived task IDs from hub `task.json`. See [get_hub_derived_task_ids()] for
#' more details.
#' @return
#' Depending on whether validation has succeeded, one of:
#' - `<message/check_success>` condition class object.
#' - `<error/check_failure>` condition class object.
#'
#' If no `derived_task_ids` are specified, the check is skipped and a
#' `<message/check_info>` condition class object is retuned.
#'
#' Returned object also inherits from subclass `<hub_check>`.
#' @export
check_tbl_derived_task_id_vals <- function(
  tbl_chr,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(
    hub_path,
    round_id
  )
) {
  assert_tbl_chr(tbl_chr)
  if (is.null(derived_task_ids)) {
    return(
      capture_check_info(
        file_path = file_path,
        msg = "No derived task IDs to check. Skipping derived task ID value check."
      )
    )
  }
  config_tasks <- read_config(hub_path, "tasks")

  derived_task_id_vals <- get_round_config_values(
    config_tasks = config_tasks,
    round_id = round_id
  )[derived_task_ids]

  setdiff_vals <- purrr::map2(
    tbl_chr[derived_task_ids],
    derived_task_id_vals,
    setdiff
  )

  invalid_derived_task_ids <- lengths(setdiff_vals) > 0L

  check <- !any(invalid_derived_task_ids)

  if (check) {
    details <- NULL
    errors <- NULL
  } else {
    invalid_vals <- setdiff_vals[invalid_derived_task_ids]
    invalid_vals_msg <- purrr::map_chr(
      seq_along(invalid_vals),
      \(.x) {
        paste0(
          "{.arg {names(invalid_vals)[",
          .x,
          "]}}: {.val {invalid_vals[[",
          .x,
          "]]}}"
        )
      }
    )
    details <- c(
      invalid_vals_msg,
      "see {.code errors} for more details."
    ) |>
      paste(collapse = ", ") |>
      cli::format_inline()
    errors <- invalid_vals
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var tbl}",
    msg_attribute = "",
    msg_verbs = c(
      "contains valid derived task ID values.",
      "contains invalid derived task ID values."
    ),
    errors = errors,
    error = FALSE,
    details = details
  )
}
