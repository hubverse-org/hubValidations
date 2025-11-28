test_that("check_target_tbl_coltypes works time-series data", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl <- read_target_file("time-series.csv", hub_path)
  target_type <- "time-series"
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = target_type,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column data types match time-series target schema."
  )

  target_tbl$target_end_date <- as.character(target_tbl$target_end_date)

  invalid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = target_type,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column data types do not match time-series target schema. `target_end_date` should be <Date> not <character>. | Target data does not contain a <Date> column (excluding \"as_of\")." # nolint: line_length_linter
  )
})

test_that("check_target_tbl_coltypes works oracle-output data", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl <- read_target_file("oracle-output.csv", hub_path)
  file_path <- "oracle-output.csv"
  target_type <- "oracle-output"

  valid_oo <- check_target_tbl_coltypes(
    target_tbl,
    target_type = target_type,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "Column data types match oracle-output target schema."
  )

  target_tbl$target_end_date <- as.character(target_tbl$target_end_date)

  invalid_oo <- check_target_tbl_coltypes(
    target_tbl,
    target_type = target_type,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(invalid_oo, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "Column data types do not match oracle-output target schema. `target_end_date` should be <Date> not <character>. | Target data does not contain a <Date> column (excluding \"as_of\")." # nolint: line_length_linter
  )
})

# v6 config-based validation ----
test_that("check_target_tbl_coltypes works with valid v6 schema", {
  skip_if_not_installed("hubUtils", minimum_version = "0.1.0")

  hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")

  # Valid time-series passes
  target_tbl <- read_target_file("time-series.csv", hub_path)
  valid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_match(
    cli::ansi_strip(valid_ts$message),
    "target-data\\.json"
  )

  # Valid oracle-output passes
  target_tbl <- read_target_file("oracle-output.csv", hub_path)
  valid_oo <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_match(
    cli::ansi_strip(valid_oo$message),
    "target-data\\.json"
  )
})

test_that("check_target_tbl_coltypes errors with invalid v6 schema", {
  skip_if_not_installed("hubUtils", minimum_version = "0.1.0")

  hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")
  target_tbl <- read_target_file("time-series.csv", hub_path)

  # Force a type mismatch - make observation character instead of numeric
  target_tbl$observation <- as.character(target_tbl$observation)

  invalid_types <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )

  expect_s3_class(invalid_types, "check_failure")
  expect_match(
    cli::ansi_strip(invalid_types$message),
    "target-data\\.json.*`observation` should be <double> not <character>."
  )
})

test_that("check_target_tbl_coltypes works with partitioned v6 hub", {
  skip_if_not_installed("hubUtils", minimum_version = "0.1.0")

  hub_path <- system.file("testhubs/v6/target_dir", package = "hubUtils")
  target_tbl <- read_target_file(
    "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
    hub_path
  )

  valid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_match(
    cli::ansi_strip(valid_ts$message),
    "target-data\\.json"
  )

  # Force a type mismatch
  target_tbl$observation <- as.character(target_tbl$observation)

  invalid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
    hub_path = hub_path
  )

  expect_s3_class(invalid_ts, "check_failure")
  expect_match(
    cli::ansi_strip(invalid_ts$message),
    "target-data\\.json.*`observation` should be <double> not <character>."
  )
})

# Inference mode tests with modified hub ----
test_that("check_target_tbl_coltypes detects missing date column in inference mode", {
  hub_path <- use_example_hub_editable("file")

  # Modify tasks.json to remove target_end_date as a task ID
  config <- hubUtils::read_config(hub_path)
  config$rounds[[1]]$model_tasks[[1]]$task_ids$target_end_date <- NULL
  hubAdmin::write_config(config, hub_path, overwrite = TRUE, silent = TRUE)

  target_tbl <- read_target_file("time-series.csv", hub_path)

  # Remove date column - should fail with only date column error
  target_tbl$target_end_date <- NULL

  invalid_no_date <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )

  expect_s3_class(invalid_no_date, "check_failure")
  expect_match(
    cli::ansi_strip(invalid_no_date$message),
    "Target data does not contain a <Date> column"
  )
  # Should not have type mismatch error
  expect_no_match(
    cli::ansi_strip(invalid_no_date$message),
    "should be"
  )
})

test_that("check_target_tbl_coltypes reports both type error and missing date column", {
  hub_path <- use_example_hub_editable("file")

  # Modify tasks.json to remove target_end_date as a task ID
  config <- hubUtils::read_config(hub_path)
  config$rounds[[1]]$model_tasks[[1]]$task_ids$target_end_date <- NULL
  hubAdmin::write_config(config, hub_path, overwrite = TRUE, silent = TRUE)

  target_tbl <- read_target_file("time-series.csv", hub_path)

  # Make observation wrong type AND remove date column
  target_tbl$observation <- as.character(target_tbl$observation)
  target_tbl$target_end_date <- NULL

  invalid_both <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )

  expect_s3_class(invalid_both, "check_failure")
  # Should have both errors
  expect_match(
    cli::ansi_strip(invalid_both$message),
    "`observation` should be <double> not <character>"
  )
  expect_match(
    cli::ansi_strip(invalid_both$message),
    "Target data does not contain a <Date> column"
  )
})

test_that("check_target_tbl_coltypes works with date_col parameter", {
  hub_path <- use_example_hub_editable("file")

  # Modify tasks.json to remove target_end_date as a task ID
  config <- hubUtils::read_config(hub_path)
  config$rounds[[1]]$model_tasks[[1]]$task_ids$target_end_date <- NULL
  hubAdmin::write_config(config, hub_path, overwrite = TRUE, silent = TRUE)

  target_tbl <- read_target_file("time-series.csv", hub_path)

  # With date_col specified and correct type - should pass
  valid_with_date_col <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    date_col = "target_end_date",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_with_date_col, "check_success")

  # Without date_col but date column exists - should also pass
  valid_without_date_col <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_without_date_col, "check_success")

  # With date_col but column is wrong type - should fail with both errors
  target_tbl$target_end_date <- as.character(target_tbl$target_end_date)

  invalid_wrong_type <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    date_col = "target_end_date",
    file_path = "time-series.csv",
    hub_path = hub_path
  )

  expect_s3_class(invalid_wrong_type, "check_failure")
  expect_match(
    cli::ansi_strip(invalid_wrong_type$message),
    "`target_end_date` should be <Date> not <character>"
  )
  expect_match(
    cli::ansi_strip(invalid_wrong_type$message),
    "Target data does not contain a <Date> column"
  )

  # Without date_col in data but with date_col specified - should fail with missing date col error
  target_tbl$target_end_date <- NULL
  invalid_missing_date_col <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    date_col = "target_end_date",
    file_path = "time-series.csv",
    hub_path = hub_path
  )

  expect_s3_class(invalid_missing_date_col, "check_failure")
  expect_match(
    cli::ansi_strip(invalid_missing_date_col$message),
    "Target data does not contain a <Date> column"
  )
})
