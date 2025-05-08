test_that("check_target_tbl_colnames works on time-series data", {
  target_tbl <- read_target_file("time-series.csv", example_file_hub_path)
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column names are consistent with expected column names for time-series target type data."
  )

  # Providing a time-series target tbl will throw errors when checking for oracle-output
  # expectations.
  invalid_oo <- check_target_tbl_colnames(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_oo, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for oracle-output target type data. Required column \"oracle_value\" is missing. | Invalid columns \"date\" and \"observation\" detected." # nolint: line_length_linter
  )

  target_tbl <- cbind(target_tbl, value = 0L) |>
    dplyr::select(-"target")

  invalid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for time-series target type data. Required column \"target\" is missing. | Invalid column \"value\" detected." # nolint: line_length_linter
  )
})

test_that("check_target_tbl_colnames works on oracle data", {
  target_tbl <- read_target_file("oracle-output.csv", example_file_hub_path)
  file_path <- "oracle-output.csv"

  valid_oo <- check_target_tbl_colnames(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    example_file_hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "Column names are consistent with expected column names for oracle-output target type data."
  )

  # Providing a oracle-output target tbl will throw errors when checking for
  # time-series expectations.
  invalid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for time-series target type data. Required column \"observation\" is missing. | Invalid columns \"output_type\", \"output_type_id\", and \"oracle_value\" detected." # nolint: line_length_linter
  )

  target_tbl <- cbind(target_tbl, value = 0L) |>
    dplyr::select(-"target", -"output_type_id")

  invalid_oo <- check_target_tbl_colnames(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_oo, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for oracle-output target type data. Required columns \"target\" and \"output_type_id\" are missing. | Invalid column \"value\" detected." # nolint: line_length_linter
  )
})

test_that("check_target_tbl_colnames works with null target keys", {
  target_tbl <- read_target_file("time-series.csv", example_file_hub_path)

  ## Modify the config to have null target keys
  config_tasks <- hubUtils::read_config(example_file_hub_path)
  # restrict to first round and model task
  config_tasks$rounds[[1]]$model_tasks <- config_tasks$rounds[[1]]$model_tasks[1]
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

  local_mocked_bindings(
    read_config = function(hub_path) {
      config_tasks
    }
  )

  # In time-series output, the allowance of additional columns means the target
  #  column is not flagged as invalid
  valid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column names are consistent with expected column names for time-series target type data."
  )

  target_tbl$target <- NULL
  valid_ts_sans_target <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_equal(valid_ts_sans_target, valid_ts)

  # Oracle output
  target_tbl <- read_target_file("oracle-output.csv", example_file_hub_path)

  # In oracle output, the target column is now flagged as invalid
  invalid_oo <- check_target_tbl_colnames(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_oo, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for oracle-output target type data. Invalid column \"target\" detected." # nolint: line_length_linter
  )

  # Once the target column is removed, the check passes
  target_tbl$target <- NULL
  valid_oo <- check_target_tbl_colnames(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    example_file_hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "Column names are consistent with expected column names for oracle-output target type data."
  )
})

test_that("check_target_tbl_colnames minimum column n check works", {
  target_tbl <- read_target_file("time-series.csv", example_file_hub_path)
  target_tbl$location <- NULL

  # With 3 columns & named target keys, check passes
  valid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column names are consistent with expected column names for time-series target type data."
  )

  target_tbl$target <- NULL
  # With 2 columns & named target keys, check fails
  invalid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for time-series target type data. Required column \"target\" is missing. | Fewer columns (2) than the required number of columns (3) detected." # nolint: line_length_linter
  )

  # With 2 columns & NULL target keys check passes
  ## Modify the config to have null target keys
  config_tasks <- hubUtils::read_config(example_file_hub_path)
  # restrict to first round and model task
  config_tasks$rounds[[1]]$model_tasks <- config_tasks$rounds[[1]]$model_tasks[1]
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

  local_mocked_bindings(
    read_config = function(hub_path) {
      config_tasks
    }
  )

  # In time-series output, the allowance of additional columns means the target
  #  column is not flagged as invalid
  valid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column names are consistent with expected column names for time-series target type data."
  )

  target_tbl$date <- NULL
  # With 1 column & NULL target keys, check fails
  invalid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for time-series target type data. Fewer columns (1) than the required number of columns (2) detected." # nolint: line_length_linter
  )
})
