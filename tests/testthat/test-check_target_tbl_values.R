test_that("check_target_tbl_values works with time-series data", {
  target_tbl <- read_target_file("time-series.csv", example_file_hub_path)
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_values(target_tbl,
    target_type = "time-series",
    file_path, example_file_hub_path
  )

  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "`target_tbl` contains valid values/value combinations."
  )

  # Introducing invalid values causes check to fail
  target_tbl$location[1] <- "random_location"
  target_tbl$target[2] <- "random_target"

  invalid_ts <- check_target_tbl_values(target_tbl,
    target_type = "time-series",
    file_path, example_file_hub_path
  )

  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "`target_tbl` contains invalid values/value combinations. Column `target` contains invalid value \"random_target\"; Column `location` contains invalid value \"random_location\". See `error_tbl` for details." # nolint: line_length_linter
  )

  # Check that function still works when `target_tbl` has errors in every row and
  # therefore no model task intersect with config values. Tests situation where a zero
  # row `valid_tbl` is created internally.
  target_tbl <- target_tbl[1:2, ]
  target_tbl$target[1] <- "random_target"
  invalid_ts <- check_target_tbl_values(target_tbl,
    target_type = "time-series",
    file_path, example_file_hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "`target_tbl` contains invalid values/value combinations. Column `target` contains invalid value \"random_target\"; Column `location` contains invalid value \"random_location\". See `error_tbl` for details." # nolint: line_length_linter
  )
})

test_that("check_target_tbl_values skips when necessary", {
  target_tbl <- read_target_file("time-series.csv", example_file_hub_path)
  file_path <- "time-series.csv"

  # Remove all task IDs from the target_tbl
  target_tbl[c("target", "location")] <- NULL
  skipped_ts <- check_target_tbl_values(target_tbl,
    target_type = "time-series",
    file_path, example_file_hub_path
  )

  expect_s3_class(skipped_ts, "check_info")
  expect_equal(
    cli::ansi_strip(skipped_ts$message) |> stringr::str_squish(),
    "`target_tbl` contains no task ID columns, skipping check."
  )
})
