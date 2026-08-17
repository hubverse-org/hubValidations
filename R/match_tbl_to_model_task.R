#' Match model output data to their model tasks in `config_tasks`.
#'
#' Split and match model output data to their corresponding model tasks in
#' `config_tasks`. Useful for performing model task specific checks on model output.
#' For v3 samples, the `output_type_id` column is set to `NA` for `sample` outputs.
#' @inheritParams expand_model_out_grid
#' @inheritParams check_tbl_colnames
#' @param tbl a tibble/data.frame of the contents of the file being validated.
#' Column types must **all be character**: the config's values are converted to
#' character when they are extracted, and are compared against this table as it
#' stands. Every task ID column the round defines must be present.
#' @param derived_task_ids Character vector of derived task ID names, or `NULL`
#' for none. A derived task ID's value is worked out from other task IDs, and
#' those are matched on, so it adds nothing to deciding where a row belongs.
#' These columns are not matched on and come back holding whatever they held.
#' @param order_by_config Logical. Whether to sort each modeling task's rows by
#' where each of their values sits in the config, rather than leaving them in the
#' order they were submitted in. Rows are sorted on `output_type` first, so rows of
#' one output type sit together, then on `output_type_id` so they ascend within
#' each, then on the task IDs to break ties. What is compared is each value's
#' position in the config's list for its column, not the value itself, so a column
#' whose values do not sort meaningfully still comes back in the order the config
#' gives them. That is what a check reading values in sequence needs, such as the
#' non-descending check on `quantile` and `cdf` values.
#'
#' @return A list containing a `tbl_df` of model output data matched to a model
#' task with one element per round model task.
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/samples", package = "hubValidations")
#' tbl <- read_model_out_file(
#'   file_path = "flu-base/2022-10-22-flu-base.csv",
#'   hub_path, coerce_types = "chr"
#' )
#' config_tasks <- read_config(hub_path, "tasks")
#' match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22")
#' match_tbl_to_model_task(tbl, config_tasks,
#'   round_id = "2022-10-22",
#'   output_types = "sample"
#' )
match_tbl_to_model_task <- function(
  tbl,
  config_tasks,
  round_id,
  output_types = NULL,
  derived_task_ids = get_config_derived_task_ids(
    config_tasks,
    round_id
  ),
  order_by_config = FALSE
) {
  if (hubUtils::is_v3_config(config_tasks)) {
    tbl[tbl$output_type == "sample", "output_type_id"] <- NA
  }

  assign_tbl_to_model_task(
    tbl,
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = output_types,
    derived_task_ids = derived_task_ids,
    subset_to_tbl_cols = FALSE,
    order_by_config = order_by_config
  )
}

join_tbl_to_model_task <- function(full, tbl, subset_to_tbl_cols = TRUE) {
  cols <- names(tbl)
  join_cols <- cols[cols != "value"]
  purrr::map(
    full,
    \(.x, join_cols) {
      # If expanded grid is zero tbl, return NULL
      if (is_zero_tbl(.x)) {
        return(NULL)
      }
      # Otherwise join tbl to model task full expanded grids, splitting the
      # submitted tbl across modeling task. Keep only column present in the tbl
      match_tbl <- dplyr::inner_join(.x, tbl, by = join_cols)
      if (subset_to_tbl_cols) {
        match_tbl <- match_tbl[, join_cols]
      }
      match_tbl
    },
    join_cols = join_cols
  )
}
