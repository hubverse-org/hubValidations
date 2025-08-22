test_that("check_target_tbl_values works with time-series data", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path
  )

  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "`target_tbl_chr` contains valid values/value combinations."
  )
  expect_null(valid_ts$error_tbl)

  # Introducing invalid values causes check to fail
  target_tbl_chr$location[1] <- "random_location"
  target_tbl_chr$target[2] <- "random_target"

  invalid_ts <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path
  )

  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "`target_tbl_chr` contains invalid values/value combinations. Column `target` contains invalid value \"random_target\"; Column `location` contains invalid value \"random_location\". See `error_tbl` for details." # nolint: line_length_linter
  )
  expect_s3_class(invalid_ts$error_tbl, "tbl_df")
  expect_named(
    invalid_ts$error_tbl,
    c("target_end_date", "target", "location", "observation")
  )
  expect_equal(
    invalid_ts$error_tbl$location,
    c("random_location", "01")
  )
  expect_equal(
    invalid_ts$error_tbl$target,
    c("wk inc flu hosp", "random_target")
  )

  # Check that function still works when `target_tbl_chr` has errors in every row and
  # therefore no model task intersect with config values. Tests situation where a zero
  # row `valid_tbl` is created internally.
  target_tbl_chr <- target_tbl_chr[1:2, ]
  target_tbl_chr$target[1] <- "random_target"
  invalid_ts <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "`target_tbl_chr` contains invalid values/value combinations. Column `target` contains invalid value \"random_target\"; Column `location` contains invalid value \"random_location\". See `error_tbl` for details." # nolint: line_length_linter
  )
  expect_s3_class(invalid_ts$error_tbl, "tbl_df")
  expect_equal(
    invalid_ts$error_tbl$location,
    c("random_location", "01")
  )
  expect_equal(
    invalid_ts$error_tbl$target,
    c("random_target", "random_target")
  )
  expect_named(
    invalid_ts$error_tbl,
    c("target_end_date", "target", "location", "observation")
  )
})

test_that("check_target_tbl_values skips when necessary", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Remove all task IDs from the target_tbl_chr
  target_tbl_chr[c("target", "location", "target_end_date")] <- NULL
  skipped_ts <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path
  )

  expect_s3_class(skipped_ts, "check_info")
  expect_equal(
    cli::ansi_strip(skipped_ts$message) |> stringr::str_squish(),
    "`target_tbl_chr` contains no task ID or output type columns, skipping check."
  )
})


test_that("check_target_tbl_values works with oracle-output data", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl_chr <- read_target_file("oracle-output.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "oracle-output.csv"

  valid_oracle <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "oracle-output",
    file_path,
    hub_path
  )

  expect_s3_class(valid_oracle, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oracle$message) |> stringr::str_squish(),
    "`target_tbl_chr` contains valid values/value combinations."
  )
  expect_null(valid_oracle$error_tbl)

  # Introducing invalid values causes check to fail
  target_tbl_chr$location[1] <- "random_location"
  target_tbl_chr$target[2] <- "random_target"

  invalid_oracle <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "oracle-output",
    file_path,
    hub_path
  )

  expect_s3_class(invalid_oracle, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_oracle$message) |> stringr::str_squish(),
    "`target_tbl_chr` contains invalid values/value combinations. Column `location` contains invalid value \"random_location\"; Column `target` contains invalid value \"random_target\". See `error_tbl` for details." # nolint: line_length_linter
  )
  expect_s3_class(invalid_oracle$error_tbl, "tbl_df")
  expect_equal(
    invalid_oracle$error_tbl$location,
    c("random_location", "US")
  )
  expect_equal(
    invalid_oracle$error_tbl$target,
    c("wk flu hosp rate", "random_target")
  )
  expect_named(
    invalid_oracle$error_tbl,
    c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
})
