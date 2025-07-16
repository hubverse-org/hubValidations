#' Identify task identifier columns present in a data table.
#'
#' Extracts the set of task identifier columns (e.g., location, horizon) defined
#' in the hub's task configuration that are also present in the provided table.
#' This supports flexible validation across both target data and model output tables.
#'
#' @param tbl A data frame (e.g., target data or model output).
#' @param config_tasks A list of task configurations from the hub config.
#' @return A character vector of column names used to identify tasks.
#' @noRd
task_id_cols_to_validate <- function(tbl, config_tasks) {
  intersect(
    colnames(tbl),
    hubUtils::get_task_id_names(config_tasks)
  )
}

#' Determine observation unit columns for a data table.
#'
#' Combines task identifier columns from the hub config with `"as_of"` (if present)
#' to define observation units in the given data table. Works for both target and
#' model output data structures.
#'
#' @param tbl A data frame (e.g., target data or model output).
#' @param config_tasks A list of task configurations from the hub config.
#' @return A character vector of columns that define the observation unit.
#' @noRd
get_tbl_obs_unit <- function(tbl, config_tasks) {
  obs_unit <- task_id_cols_to_validate(tbl, config_tasks)
  if ("as_of" %in% colnames(tbl)) {
    obs_unit <- c(obs_unit, "as_of")
  }
  obs_unit
}

#' Group a data table by observation unit columns.
#'
#' Uses `get_tbl_obs_unit()` to determine grouping columns based on task
#' configuration and the presence of `"as_of"`. Returns the input table grouped
#' by those columns, suitable for downstream validation or summarisation.
#'
#' @param tbl A data frame (e.g., target data or model output).
#' @param config_tasks A list of task configurations from the hub config.
#' @return A grouped tibble, grouped by observation unit.
#' @noRd
group_by_obs_unit <- function(tbl, config_tasks) {
  obs_unit <- get_tbl_obs_unit(tbl, config_tasks)
  group_by(tbl, across(all_of(obs_unit)))
}
