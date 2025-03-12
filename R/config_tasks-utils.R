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

# get all task_ids values
get_round_config_values <- function(config_tasks, round_id,
                                    derived_task_ids = get_config_derived_task_ids(
                                      config_tasks, round_id
                                    )) {
  model_tasks <- hubUtils::get_round_model_tasks(config_tasks, round_id)
  task_id_names <- setdiff(
    hubUtils::get_round_task_id_names(config_tasks, round_id),
    derived_task_ids
  )
  task_id_values <- purrr::map(
    purrr::set_names(task_id_names),
    \(.x) get_task_id_values(.x, model_tasks)
  )
  if (!is.null(derived_task_ids)) {
    task_id_values <- c(
      task_id_values,
      purrr::map(
        purrr::set_names(derived_task_ids),
        ~NA_character_
      )
    )
  }

  output_type_names <- get_round_output_type_names(config_tasks, round_id)
  output_type_id_values <- purrr::map(
    output_type_names,
    \(.x) get_output_type_id_values(.x, model_tasks)
  ) %>% purrr::flatten_chr()

  output_types <- list(
    output_type = output_type_names,
    output_type_id = output_type_id_values
  )

  c(task_id_values, output_types)
}
get_task_id_values <- function(task_id, model_tasks) {
  purrr::map(
    model_tasks,
    ~ .x[["task_ids"]][[task_id]]
  ) %>%
    unlist(use.names = FALSE) %>%
    unique() %>%
    as.character()
}

get_output_type_id_values <- function(output_type, model_tasks) {
  out <- purrr::map(
    model_tasks,
    ~ .x[["output_type"]][[output_type]][["output_type_id"]]
  ) %>%
    unlist(use.names = FALSE) %>%
    unique() %>%
    as.character()

  if (length(out) == 0L) {
    NA_character_
  } else {
    out
  }
}
