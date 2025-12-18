#' Check that `quantile` and `cdf` output type values of model output data
#' are non-descending
#'
#' Checks that values in the `value` column for `quantile` and `cdf` output type
#' data for each unique task ID/output type combination
#' are non-descending when arranged by increasing `output_type_id` order.
#' Check only performed if `tbl` contains `quantile` or `cdf` output type data.
#' If not, the check is skipped and a `<message/check_info>` condition class
#' object is returned.
#'
#' @inherit check_tbl_values params
#' @inherit check_tbl_col_types return
#' @export
check_tbl_value_col_ascending <- function(
  tbl,
  file_path,
  hub_path,
  round_id,
  derived_task_ids = get_hub_derived_task_ids(hub_path)
) {
  check_output_types <- intersect(
    c("cdf", "quantile"),
    unique(tbl[["output_type"]])
  )

  # Exit early if there are no values to check
  if (length(check_output_types) == 0L) {
    return(
      capture_check_info(
        file_path,
        "No quantile or cdf output types to check for non-descending values.
        Check skipped."
      )
    )
  }

  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  if (!is.null(derived_task_ids)) {
    tbl[derived_task_ids] <- NA_character_
  }

  # Check that values are non-decreasing for each output type separately to reduce
  # memory pressure
  error_tbl <- purrr::map(
    check_output_types,
    \(.x) {
      check_values_ascending_by_output_type(
        .x,
        tbl,
        config_tasks,
        round_id,
        derived_task_ids
      )
    }
  ) %>%
    purrr::list_rbind()

  check <- nrow(error_tbl) == 0L

  if (check) {
    details <- NULL
    error_tbl <- NULL
  } else {
    details <- cli::format_inline("See {.var error_tbl} attribute for details.")
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Quantile or cdf {.var value} values",
    msg_verbs = c("increase", "do not all increase"),
    msg_attribute = "when ordered by {.var output_type_id}.",
    details = details,
    error_tbl = error_tbl
  )
}

#' Check that values for each model task in specific output types are ascending
#'
#' This function allows us to map over individual output types one at a time to
#' reduce memory pressure.
#' @param output_type the output type(s) to check. Must be a character vector
#' @noRd
check_values_ascending_by_output_type <- function(
  output_type,
  tbl,
  config_tasks,
  round_id,
  derived_task_ids
) {
  # FIX for <https://github.com/hubverse-org/hubValidations/issues/78>
  # This function splits the table by model task (via
  # `expand_model_out_grid(bind_model_tasks = FALSE)`) and then performs an
  # inner join to auto-sort for this particular output type regardless if the
  # output type is inherently sortable.
  model_task_tbls <- match_tbl_to_model_task(
    tbl,
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = output_type,
    derived_task_ids = derived_task_ids
  ) %>%
    purrr::compact()

  purrr::map(model_task_tbls, check_values_ascending) %>%
    purrr::list_rbind()
}

#' Check that values for each model task are ascending
#'
#' @param tbl an all character table with a single output type
#' @return
#'  - If the check succeeds, and all values are non-decreasing: NULL
#'  - If the check fails, a summary table showing the model tasks that
#'    had decreasing values for this output type
#' @noRd
check_values_ascending <- function(tbl) {
  group_cols <- names(tbl)[!names(tbl) %in% hubUtils::std_colnames]
  tbl[["value"]] <- as.numeric(tbl[["value"]])

  # group by all of the target columns
  check_tbl <- dplyr::group_by(
    tbl,
    dplyr::across(dplyr::all_of(group_cols))
  ) %>%
    dplyr::summarise(non_asc = any(diff(.data[["value"]]) < 0))

  if (!any(check_tbl$non_asc)) {
    return(NULL)
  }

  output_type <- unique(tbl["output_type"]) # nolint: object_usage_linter

  dplyr::filter(check_tbl, .data[["non_asc"]]) %>%
    dplyr::select(-dplyr::all_of("non_asc")) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(.env$output_type)
}
