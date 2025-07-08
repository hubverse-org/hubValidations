test_custom_checks_caller <- function(
    # nolint start
    hub_path = system.file("testhubs/flusight", package = "hubValidations"),
    file_path = "hub-ensemble/2023-05-08-hub-ensemble.parquet",
    validations_cfg_path = NULL) {
  round_id <- parse_file_name(file_path)$round_id
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )
  # nolint end
  execute_custom_checks(validations_cfg_path = validations_cfg_path)
}

stand_up_custom_check_hub <- function(
    # nolint start
    hub_path = system.file("testhubs/flusight", package = "hubValidations"),
    new_path = NULL,
    check_dir = testthat::test_path("testdata/src/R/"),
    yaml_path = testthat::test_path("testdata/config/validations-src.yml")) {
  if (is.null(new_path)) {
    return()
  }
  # make a copy of the hub
  fs::dir_copy(hub_path, new_path)

  # create the script path
  new_path <- fs::path(new_path, fs::path_file(hub_path))
  script_path <- fs::path(new_path, "src/validations/R")
  # NOTE: this creates the `src/validatons` directory because if the `R/` dir
  # exists, `dir_copy()` will place the copied directory _inside_ it, which is
  # not what we want.
  fs::dir_create(fs::path_dir(script_path))

  # Copy the directory of the existing files to the new script path
  fs::dir_copy(check_dir, script_path)

  # Copy the provided yaml file to the config folder
  new_yaml <- fs::path(new_path, "hub-config", "validations.yml")
  fs::file_copy(yaml_path, new_yaml, overwrite = TRUE)
  # nolint end
  return(new_path)
}

mock_inferred_target_config <- function(categorical = FALSE, config_tasks = NULL) {
  # Supplying config_tasks allows us to override any mocking that might be applied to
  # read_config() in the tests.
  if (is.null(config_tasks)) {
    config_tasks <- read_config(example_file_hub_path) # nolint: object_usage_linter
  }

  if (categorical) {
    # restrict to first round and model task 1 (target "wk flu hosp rate category")
    config_tasks$rounds[[1]]$model_tasks <- config_tasks$rounds[[1]]$model_tasks[1]
  } else {
    # restrict to first round and model task 3 ("wk inc flu hosp" target)
    config_tasks$rounds[[1]]$model_tasks <- config_tasks$rounds[[1]]$model_tasks[3]
  }
  # Assing NULL to target_keys
  config_tasks <- purrr::assign_in(
    config_tasks,
    list(
      "rounds", 1, "model_tasks", 1,
      "target_metadata", 1, "target_keys"
    ),
    NULL
  )
  # Remove target task ID
  config_tasks$rounds[[1]]$model_tasks[[1]]$task_ids[["target"]] <- NULL

  config_tasks
}
