test_that("check_target_tbl_ts_targets works with a target column", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  #  cloned in `setup.R`
  hub_path <- example_file_hub_path
  target_tbl <- read_target_file("time-series.csv", example_file_hub_path)
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_ts_targets(target_tbl,
    target_type = "time-series",
    file_path, example_file_hub_path
  )

  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "time-series targets are all valid."
  )

  target_tbl$target[1] <- "wk flu hosp rate category"
  invalid_ts <- check_target_tbl_ts_targets(target_tbl,
    target_type = "time-series",
    file_path, example_file_hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "time-series targets are not all valid. `target_tbl` column \"target\" contains data for invalid target \"wk flu hosp rate category\". Valid time-series targets must be step-ahead and their target type must be one of \"continuous\", \"discrete\", \"binary\", and \"compositional\"." # nolint: line_length_linter
  )

  # Check that appropriate error returned when target column is missing
  target_tbl$target <- NULL
  invalid_target_col <- check_target_tbl_ts_targets(target_tbl,
    target_type = "time-series",
    file_path, example_file_hub_path
  )
  expect_s3_class(invalid_target_col, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_target_col$message) |> stringr::str_squish(),
    "time-series targets could not be validated. Target task ID column \"target\" not present in `target_tbl`." # nolint: line_length_linter
  )
})

test_that("check_target_tbl_ts_targets works with NULL target_keys", {
  file_path <- "time-series.csv"
  hub_path <- example_file_hub_path
  # restrict to first round and model task 3 ("wk inc flu hosp" target)
  valid_inf_config_tasks <- mock_global_target_config(categorical = FALSE,
                                                        hub_path = hub_path)
  # restrict to first round and model task 1 (target "wk flu hosp rate category")
  invalid_inf_config_tasks <- mock_global_target_config(categorical = TRUE,
                                                          hub_path = hub_path)

  local_mocked_bindings(
    read_config = function(hub_path) {
      valid_inf_config_tasks
    }
  )

  valid_null <- check_target_tbl_ts_targets(
    target_tbl = NULL,
    target_type = "time-series",
    file_path, example_file_hub_path
  )
  expect_s3_class(valid_null, "check_success")
  expect_equal(
    cli::ansi_strip(valid_null$message) |> stringr::str_squish(),
    "time-series target is valid."
  )

  local_mocked_bindings(
    read_config = function(hub_path) {
      invalid_inf_config_tasks
    }
  )
  invalid_null <- check_target_tbl_ts_targets(
    target_tbl = NULL,
    target_type = "time-series",
    file_path, example_file_hub_path
  )
  expect_s3_class(invalid_null, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_null$message) |> stringr::str_squish(),
    "time-series target is not valid. Global target \"wk flu hosp rate category\" inferred from hub config is invalid. Time-series target data not appropriate. Valid time-series targets must be step-ahead and their target type must be one of \"continuous\", \"discrete\", \"binary\", and \"compositional\"." # nolint: line_length_linter
  )
})


test_that("check_target_tbl_ts_targets skipped for oracle-output", {
  skip <- check_target_tbl_ts_targets(
    target_tbl = NULL,
    target_type = "oracle-output",
    file_path = "oracle-output.csv", example_file_hub_path
  )
  expect_s3_class(skip, "check_info")
  expect_equal(
    cli::ansi_strip(skip$message) |> stringr::str_squish(),
    "Check not applicable to oracle-output target data. Skipped."
  )
})
