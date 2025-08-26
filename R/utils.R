get_file_target_metadata <- function(hub_path, file_path) {
  round_config <- get_file_round_config(file_path, hub_path)

  purrr::map(
    round_config[["model_tasks"]],
    ~ .x[["target_metadata"]] %>%
      purrr::map(~ .x[["target_keys"]])
  ) %>%
    unlist(recursive = FALSE) %>%
    unique()
}

abs_file_path <- function(
  file_path,
  hub_path,
  subdir = c("model-output", "model-metadata", "hub-config", "target-data")
) {
  subdir <- match.arg(subdir)
  if (subdir == "model-output") {
    subdir <- get_hub_model_output_dir(hub_path)
  }
  fs::path(
    hub_path,
    subdir,
    file_path
  )
}

rel_file_path <- function(
  file_path,
  hub_path,
  subdir = c("model-output", "model-metadata", "hub-config", "target-data")
) {
  subdir <- match.arg(subdir)
  if (subdir == "model-output") {
    subdir <- get_hub_model_output_dir(hub_path)
  }
  fs::path(
    subdir,
    file_path
  )
}

get_file_round_id <- function(file_path) {
  parse_file_name(file_path)$round_id
}


get_file_round_idx <- function(file_path, hub_path) {
  round_id <- get_file_round_id(file_path)
  config_tasks <- read_config(hub_path, "tasks")
  hubUtils::get_round_idx(config_tasks, round_id)
}

get_file_round_config <- function(file_path, hub_path) {
  config_tasks <- read_config(hub_path, "tasks")
  round_idx <- get_file_round_idx(file_path, hub_path)
  config_tasks[["rounds"]][[round_idx]]
}

is_round_id_from_variable <- function(file_path, hub_path) {
  get_file_round_config(file_path, hub_path)[["round_id_from_variable"]]
}

get_file_round_id_col <- function(file_path, hub_path) {
  if (is_round_id_from_variable(file_path, hub_path)) {
    get_file_round_config(file_path, hub_path)[["round_id"]]
  } else {
    NULL
  }
}

# Get metadata dile name from submission file path
get_metadata_file_name <- function(
  hub_path,
  file_path,
  ext = c("yml", "yaml", "auto", "both")
) {
  ext <- rlang::arg_match(ext)
  model_id <- parse_file_name(file_path)$model_id

  if (ext == "both") {
    return(fs::path(c(
      fs::path(model_id, ext = "yml"),
      fs::path(model_id, ext = "yaml")
    )))
  }

  if (ext == "auto") {
    meta_file_names <- fs::path(c(
      fs::path(model_id, ext = "yml"),
      fs::path(model_id, ext = "yaml")
    ))
    meta_file_paths <- abs_file_path(
      meta_file_names,
      hub_path,
      subdir = "model-metadata"
    )
    exist <- fs::file_exists(meta_file_paths)
    if (any(exist)) {
      return(meta_file_names[exist][1])
    } else {
      cli::cli_abort(
        "Model metadata file name could not be automatically detected for file {.path {file_path}}"
      )
    }
  }
  fs::path(model_id, ext = ext)
}
