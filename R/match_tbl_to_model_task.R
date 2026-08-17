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
#' for none. A derived task ID's value follows from the values of other task
#' IDs. A derived task ID cannot therefore further distinguish a row beyond the
#' values of the task IDs it is derived from. Derived task ID columns are
#' skipped, and returned unchanged.
#' @param order_by_config Logical. How to order each modeling task's rows.
#' `FALSE`, the default, leaves them in the order they were submitted in. `TRUE`
#' sorts them into the order the config lists their values in: on `output_type`
#' first, so rows of one output type sit together, then on `output_type_id`, so
#' they ascend within each, then on the task IDs to break ties.
#'
#' What is sorted on is each value's position in the config, not the value
#' itself. `pmf` categories show why that matters: `"low"`, `"moderate"` and
#' `"high"` have no useful alphabetical order, but the config lists them in the
#' order they belong in. `check_tbl_value_col_ascending()` asks for this order,
#' because it reads values in the order the rows arrive in.
#'
#' In the config a task ID's values are split into `required` and `optional`.
#' Extracting them collapses the two into a single order, `required` values
#' first, then `optional` ones, and that is the order sorted on.
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
