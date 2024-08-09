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

get_round_output_type_names <- function(config_tasks, round_id,
                                        collapse = TRUE) {
  out <- get_round_output_types(config_tasks, round_id) %>%
    purrr::map(names)

  if (collapse) {
    purrr::flatten_chr(out) %>%
      unique()
  } else {
    out
  }
}
