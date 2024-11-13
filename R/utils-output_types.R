get_rnd_required_output_type_names <- function(config_tasks, round_id) {
  is_required <- get_round_output_types(config_tasks, round_id) |>
    purrr::flatten() |>
    purrr::map_lgl(~ is_required_output_type(.x))

  names(is_required)[is_required] |> unique()
}

get_submission_required_output_types <- function(tbl, config_tasks,
                                                 round_id) {
  tbl_output_types <- get_tbl_output_types(tbl)
  required_output_types <- get_rnd_required_output_type_names(
    config_tasks,
    round_id
  )
  unique(c(tbl_output_types, required_output_types))
}

get_tbl_output_types <- function(tbl) {
  unique(tbl[["output_type"]])
}
