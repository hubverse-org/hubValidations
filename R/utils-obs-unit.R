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
