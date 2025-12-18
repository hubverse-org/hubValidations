#' Match model output `tbl` data to their model tasks in `config_tasks`.
#'
#' Split and match model output `tbl` data to their corresponding model tasks in
#' `config_tasks`. Useful for performing model task specific checks on model output.
#' For v3 samples, the `output_type_id` column is set to `NA` for `sample` outputs.
#' @inheritParams expand_model_out_grid
#' @inheritParams check_tbl_colnames
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
  all_character = TRUE
) {
  if (hubUtils::is_v3_config(config_tasks)) {
    tbl[tbl$output_type == "sample", "output_type_id"] <- NA
  }

  expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    required_vals_only = FALSE,
    all_character = all_character,
    as_arrow_table = FALSE,
    bind_model_tasks = FALSE,
    output_types = output_types,
    derived_task_ids = derived_task_ids
  ) %>%
    join_tbl_to_model_task(tbl, subset_to_tbl_cols = FALSE)
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
