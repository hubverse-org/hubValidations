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
    hub_path,
    allow_extra_dates = FALSE
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
    hub_path,
    allow_extra_dates = FALSE
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
    hub_path,
    allow_extra_dates = FALSE
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
    hub_path,
    allow_extra_dates = FALSE
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
    hub_path,
    allow_extra_dates = FALSE
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
    hub_path,
    allow_extra_dates = FALSE
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

# Date relaxation tests ----
test_that("allow_extra_dates = TRUE allows future dates in time-series", {
  hub_path <- use_example_hub_readonly("file", v = 5)
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Add a future date that's not in tasks.json
  target_tbl_chr$target_end_date[1] <- "2099-12-31"

  # With allow_extra_dates = TRUE and explicit date_col, this should succeed
  # (v5 hub has no config, so date_col must be provided explicitly)
  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path,
    date_col = "target_end_date",
    allow_extra_dates = TRUE
  )

  expect_s3_class(result, "check_success")
  expect_match(
    cli::ansi_strip(result$message),
    "`target_tbl_chr` contains valid values/value combinations"
  )
  expect_match(
    cli::ansi_strip(result$message),
    "Date column \"target_end_date\" excluded from validation"
  )
})

test_that("allow_extra_dates = FALSE rejects future dates in time-series", {
  hub_path <- use_example_hub_readonly("file", v = 5)
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Add a future date that's not in tasks.json
  target_tbl_chr$target_end_date[1] <- "2099-12-31"

  # With allow_extra_dates = FALSE, this should fail
  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path,
    date_col = "target_end_date",
    allow_extra_dates = FALSE
  )

  expect_s3_class(result, "check_error")
  expect_match(
    cli::ansi_strip(result$message),
    "contains invalid values/value combinations"
  )
  expect_s3_class(result$error_tbl, "tbl_df")
})

test_that("allow_extra_dates still validates non-date columns in time-series", {
  hub_path <- use_example_hub_readonly("file", v = 5)
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Add a future date (should be allowed) AND invalid location (should fail)
  target_tbl_chr$target_end_date[1] <- "2099-12-31"
  target_tbl_chr$location[1] <- "invalid_location"

  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path,
    date_col = "target_end_date",
    allow_extra_dates = TRUE
  )

  # Should fail due to invalid location, not the date
  expect_s3_class(result, "check_error")
  expect_match(
    cli::ansi_strip(result$message),
    "invalid_location"
  )
  expect_s3_class(result$error_tbl, "tbl_df")
  expect_true("invalid_location" %in% result$error_tbl$location)
})

test_that("allow_extra_dates is ignored for oracle-output (always strict)", {
  hub_path <- use_example_hub_readonly("file", v = 5)
  target_tbl_chr <- read_target_file("oracle-output.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "oracle-output.csv"

  # Add a date that's not in tasks.json
  target_tbl_chr$target_end_date[1] <- "2099-12-31"

  # Even with allow_extra_dates = TRUE and date_col provided, oracle-output should fail
  # because date relaxation is only for time-series
  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "oracle-output",
    file_path,
    hub_path,
    date_col = "target_end_date",
    allow_extra_dates = TRUE
  )

  expect_s3_class(result, "check_error")
  expect_match(
    cli::ansi_strip(result$message),
    "contains invalid values/value combinations"
  )
})

test_that("explicit date_col parameter works for hubs without config", {
  hub_path <- use_example_hub_readonly("file", v = 5)
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Add a future date
  target_tbl_chr$target_end_date[1] <- "2099-12-31"

  # Explicitly provide date_col (in real usage this would be for hubs without target-data.json)
  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path,
    date_col = "target_end_date",
    allow_extra_dates = TRUE
  )

  # Should succeed because date relaxation is enabled
  expect_s3_class(result, "check_success")
  expect_match(
    cli::ansi_strip(result$message),
    "Date column \"target_end_date\" excluded from validation"
  )
})

test_that("date column extracted from target-data.json config in v6 hubs", {
  hub_path <- use_example_hub_readonly("file", v = 6)
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Add a future date
  target_tbl_chr$target_end_date[1] <- "2099-12-31"

  # Read config for v6 hub
  config_target_data <- hubUtils::read_config(hub_path, "target-data")

  # With v6 hub, date column should be extracted from config
  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path,
    allow_extra_dates = TRUE,
    config_target_data = config_target_data
  )

  # Should succeed because date relaxation is enabled and date column is from config
  expect_s3_class(result, "check_success")
  expect_match(
    cli::ansi_strip(result$message),
    "Date column \"target_end_date\" excluded from validation"
  )
})

test_that("allow_extra_dates = FALSE still catches invalid location values", {
  hub_path <- use_example_hub_readonly("file", v = 5)
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Add invalid location
  target_tbl_chr$location[1] <- "invalid_location"

  # With allow_extra_dates = FALSE (strict validation), should catch the invalid location
  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path,
    allow_extra_dates = FALSE
  )

  expect_s3_class(result, "check_error")
  expect_match(
    cli::ansi_strip(result$message),
    "invalid_location"
  )
  expect_s3_class(result$error_tbl, "tbl_df")
  expect_true("invalid_location" %in% result$error_tbl$location)
})

test_that("allow_extra_dates = FALSE catches all invalid values including dates", {
  hub_path <- use_example_hub_readonly("file", v = 5)
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Add invalid date, location, and target
  target_tbl_chr$target_end_date[1] <- "2099-12-31"
  target_tbl_chr$location[2] <- "invalid_location"
  target_tbl_chr$target[3] <- "invalid_target"

  # With allow_extra_dates = FALSE, should catch ALL invalid values
  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path,
    allow_extra_dates = FALSE
  )

  expect_s3_class(result, "check_error")
  expect_match(
    cli::ansi_strip(result$message),
    "contains invalid values/value combinations"
  )
  expect_s3_class(result$error_tbl, "tbl_df")
  # Should have caught at least 3 rows with errors
  expect_gte(nrow(result$error_tbl), 3)
})

# Default behavior tests ----
test_that("default behavior is strict (allow_extra_dates = FALSE)", {
  hub_path <- use_example_hub_readonly("file", v = 5)
  target_tbl_chr <- read_target_file("time-series.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "time-series.csv"

  # Add a future date that's not in tasks.json
  target_tbl_chr$target_end_date[1] <- "2099-12-31"

  # Default behavior (no allow_extra_dates specified) should be strict
  # and reject the invalid date
  result <- check_target_tbl_values(
    target_tbl_chr,
    target_type = "time-series",
    file_path,
    hub_path
  )

  # Should fail because default is strict validation

  expect_s3_class(result, "check_error")
  expect_match(
    cli::ansi_strip(result$message),
    "contains invalid values/value combinations"
  )
})
