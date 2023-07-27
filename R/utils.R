get_hub_file_formats <- function(hub_path, round_id) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  round_idx <- hubUtils::get_round_idx(config_tasks, round_id)
  file_formats <- config_tasks[["rounds"]][[round_idx]]$file_format
  if (!is.null(file_formats)) {
    return(file_formats)
  }

  config_admin <- hubUtils::read_config(hub_path, "admin")
  config_admin$file_format
}

get_hub_timezone <- function(hub_path) {
  config_admin <- hubUtils::read_config(hub_path, "admin")
  config_admin$timezone
}

get_hub_model_output_dir <- function(hub_path) {
  config_admin <- hubUtils::read_config(hub_path, "admin")
  model_output_dir <- config_admin$model_output_dir
  if (is.null(model_output_dir)) "model-output" else model_output_dir
}

abs_file_path <- function(file_path, hub_path) {
  fs::path(
    hub_path,
    get_hub_model_output_dir(hub_path),
    file_path
  )
}

get_file_round_id <- function(file_path) {
    parse_file_name(file_path)$round_id
}


get_file_round_idx <- function(file_path, hub_path) {
    round_id <- get_file_round_id(file_path)
    config_tasks <- hubUtils::read_config(hub_path, "tasks")
    hubUtils::get_round_idx(config_tasks, round_id)
}

get_file_round_config <- function(file_path, hub_path) {
    config_tasks <- hubUtils::read_config(hub_path, "tasks")
    round_idx <- get_file_round_idx(file_path, hub_path)
    config_tasks[["rounds"]][[round_idx]]
}

is_round_id_from_variable <- function(file_path, hub_path) {
    get_file_round_config(file_path, hub_path)[["round_id_from_variable"]]
}
