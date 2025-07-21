test_that("check_target_tbl_coltypes works on csv time-series data", {
  hub_path <- example_file_hub_path
  target_tbl <- read_target_file("time-series.csv", example_file_hub_path)
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column data types match time-series target schema."
  )

  target_tbl$date <- as.character(target_tbl$date)

  invalid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column data types do not match time-series target schema. `date` should be <Date> not <character>." # nolint: line_length_linter
  )
})

test_that("check_target_tbl_coltypes works on csv time-series data", {
  hub_path <- fs::path(tmp_dir, "parquet")
  fs::dir_copy(example_file_hub_path, hub_path)
  valid_ts <- read_target_file("time-series.csv", hub_path)
  arrow::write_parquet(
    valid_ts,
    fs::path(hub_path, "target-data", "time-series.parquet")
  )
  fs::file_delete(fs::path(hub_path, "target-data", "time-series.csv"))

  target_tbl <- read_target_file(
    "time-series.parquet",
    hub_path,
    coerce_types = "none"
  )
  file_path <- "time-series.parquet"

  valid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column data types match time-series target schema."
  )

  invalid_ts <- read_target_file("time-series.parquet", hub_path)
  invalid_ts$observation <- as.character(target_tbl$observation)
  arrow::write_parquet(
    invalid_ts,
    fs::path(hub_path, "target-data", "time-series.parquet")
  )

  target_tbl <- read_target_file(
    "time-series.parquet",
    hub_path,
    # To validate parquet data types we read the parquet file without coercing
    # types to the target schema
    coerce_types = "none"
  )
  invalid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column data types do not match time-series target schema. `observation` should be <double> not <character>." # nolint: line_length_linter
  )
})
