get_round_config <- function(config_tasks, round_id) {
  round_idx <- hubUtils::get_round_idx(config_tasks, round_id)
  purrr::pluck(
    config_tasks,
    "rounds",
    round_idx
  )
}

get_round_output_types <- function(config_tasks, round_id) {
  round_config <- get_round_config(config_tasks, round_id)
  purrr::map(
    round_config[["model_tasks"]],
    ~ .x[["output_type"]]
  )
}

#' Values any modeling task in a round allows in each column
#'
#' Pools the per-modeling-task value sets of `get_config_mt_value_sets()`
#' across the round's modeling tasks.
#'
#' @inheritParams expand_model_out_grid
#'
#' @returns A named list with one character vector per task ID, then
#' `output_type` (the round's output type names) and `output_type_id` (the
#' values of all its output types).
#' @noRd
get_round_pooled_values <- function(config_tasks, round_id) {
  value_sets <- get_config_mt_value_sets(config_tasks, round_id)
  task_id_values <- purrr::map(value_sets, "task_ids") |>
    purrr::list_transpose() |>
    purrr::map(\(values) unique(unlist(values, use.names = FALSE)))

  c(
    task_id_values,
    list(
      output_type = hubUtils::get_round_output_type_names(
        config_tasks,
        round_id
      ),
      output_type_id = purrr::map(value_sets, "output_type_ids") |>
        unlist(use.names = FALSE) |>
        unique()
    )
  )
}
