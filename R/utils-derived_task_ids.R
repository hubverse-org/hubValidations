#' Set derived task_ids to have `NA` values when creating expanded grids of valid
#' values
#'
#' @param model_task A single `model_task` object.
#' @param derived_task_ids character vector of derived task ID names.
#'
#' @returns If `derived_task_ids` is not `NULL`, a modified `model_task` object
#' with the `required` values of any derived task IDs set to `NULL` and the
#' `optional` values set to `NA`. Otherwise, the original `model_task` object
#' is returned.
#' @noRd
derived_taskids_to_na <- function(model_task, derived_task_ids) {
  if (is.null(derived_task_ids)) {
    return(model_task)
  }
  purrr::modify_at(
    model_task,
    .at = derived_task_ids,
    .f = ~ list(
      required = NULL,
      optional = NA
    )
  )
}

#' Ensure that derived task IDs are valid task IDs and do not have required values.
#'
#' @param derived_task_ids character vector of derived task ID names.
#' @param config_tasks A `config_tasks` object.
#' @param round_id character string. The round ID.
#'
#' @returns If `derived_task_ids` is `NULL`, `NULL` is returned. Otherwise, a
#' character vector of valid task IDs is returned.
#' If any `derived_task_ids` are not valid task IDs, a warning is thrown.
#' If any `derived_task_ids` have required values, an error is thrown.
#' @noRd
validate_derived_task_ids <- function(derived_task_ids, config_tasks, round_id) {
  checkmate::assert_character(derived_task_ids, null.ok = TRUE)
  if (is.null(derived_task_ids)) {
    return(NULL)
  }
  round_task_ids <- hubUtils::get_round_task_id_names(config_tasks, round_id)
  valid_task_ids <- intersect(derived_task_ids, round_task_ids)
  if (length(valid_task_ids) < length(derived_task_ids)) {
    cli::cli_warn(
      c(
        "x" = "{.val {setdiff(derived_task_ids, round_task_ids)}}
        {?is/are} not valid task ID{?s}. Ignored.",
        "i" = "{.arg derived_task_ids} must be a member of: {.val {round_task_ids}}"
      ),
      call = rlang::caller_call()
    )
  }
  model_tasks <- hubUtils::get_round_model_tasks(config_tasks, round_id)
  has_required <- purrr::map(
    model_tasks,
    ~ .x[["task_ids"]][valid_task_ids] %>%
      purrr::map_lgl(
        ~ !is.null(.x$required)
      )
  ) %>%
    purrr::reduce(`|`)
  if (any(has_required)) {
    cli::cli_abort(
      c(
        "x" = "Derived task IDs cannot have required task ID values.",
        "!" = "{.val {names(has_required)[has_required]}} ha{?s/ve}
          required task ID values. Ignored."
      ),
      call = rlang::caller_call()
    )
  }
  valid_task_ids <- intersect(
    valid_task_ids,
    names(has_required)[!has_required]
  )
  if (length(valid_task_ids) == 0L) {
    return(NULL)
  }
  valid_task_ids
}
