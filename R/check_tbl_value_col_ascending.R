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
#' @inherit check_tbl_value_col params
#' @inherit check_tbl_col_types return
#' @export
check_tbl_value_col_ascending <- function(tbl, file_path, hub_path, round_id,
                                          derived_task_ids = get_hub_derived_task_ids(hub_path)) {

  # Exit early if there are no values to check
  no_values_to_check <- all(!c("cdf", "quantile") %in% tbl[["output_type"]])
  if (no_values_to_check) {
    return(
      capture_check_info(
        file_path,
        "No quantile or cdf output types to check for non-descending values.
        Check skipped."
      )
    )
  }

  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  not_value <- names(tbl) != "value"
  tbl[not_value] <- hubData::coerce_to_character(tbl[not_value])
  if (!is.null(derived_task_ids)) {
    tbl[derived_task_ids] <- NA_character_
  }
  round_output_types <- get_round_output_type_names(config_tasks, round_id)
  only_cdf_or_quantile <- intersect(c("cdf", "quantile"), round_output_types)
  # FIX for <https://github.com/hubverse-org/hubValidations/issues/78>
  # This function uses an inner join to auto-sort the table by model task,
  # splitting by output type. We can use that to loop through the check.
  output_type_tbls <- match_tbl_to_model_task(
    tbl,
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = only_cdf_or_quantile,
    derived_task_ids = derived_task_ids
  ) %>%
    purrr::compact()
  error_tbl <- purrr::map(output_type_tbls, check_values_ascending) %>%
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
    msg_subject = "Values in {.var value} column",
    msg_verbs = c("are non-decreasing", "are not non-decreasing"),
    msg_attribute = "as output_type_ids increase for all unique task ID
    value/output type combinations of quantile or cdf output types.",
    details = details,
    error_tbl = error_tbl
  )
}

#' Check that values for each model task are ascending
#'
#' @param tbl a table with a single output type
#' @return
#'  - If the check succeeds, and all values are non-decreasing: NULL
#'  - If the check fails, a summary table showing the model tasks that
#'    had decreasing values for this output type
#' @noRd
check_values_ascending <- function(tbl) {
  group_cols <- names(tbl)[!names(tbl) %in% hubUtils::std_colnames]
  tbl[["value"]] <- as.numeric(tbl[["value"]])

  # group by all of the target columns
  check_tbl <- dplyr::group_by(tbl, dplyr::across(dplyr::all_of(group_cols))) %>%
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
