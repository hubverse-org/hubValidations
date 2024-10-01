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
