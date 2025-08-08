test_that("check_target_tbl_rows_unique works time-series data", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl <- read_target_file("time-series.csv", hub_path)
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_rows_unique(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "time-series target data rows are unique."
  )
  expect_null(valid_ts$duplicate_rows)

  # Test with valid versioned data with two as_of dates
  target_tbl_versioned <- rbind(target_tbl, target_tbl)
  target_tbl_versioned$as_of <- Sys.Date()
  target_tbl_versioned$as_of[
    duplicated(target_tbl_versioned)
  ] <- Sys.Date() - 7L

  valid_ts_versioned <- check_target_tbl_rows_unique(
    target_tbl_versioned,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_ts_versioned, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts_versioned$message) |> stringr::str_squish(),
    "time-series target data rows are unique."
  )
  expect_null(valid_ts_versioned$duplicate_rows)

  # Check with invalid time-series data. ----
  # -- Non-versioned --
  # Add duplicate rows to the target table.
  # Change the `observation` column value in one of the
  # duplicates to demonstrate it's not being taken into account.
  target_tbl[2:3, ] <- target_tbl[1, ]
  target_tbl[2, "observation"] <- 1 # original was 0.

  invalid_ts <- check_target_tbl_rows_unique(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "time-series target data rows must be unique. Rows containing duplicate combinations: 2 and 3" # nolint: line_length_linter
  )
  expect_equal(invalid_ts$duplicate_rows, 2:3)

  # Check with invalid time-series data. ----
  # -- Versioned --
  # Add duplicate rows to the target table.
  # Change the `observation` column value in one of the
  # duplicates to demonstrate it's not being taken into account
  # (i.e. should be flagged as duplicate).
  # Also change the `as_of` date for one duplicate row to show it
  # is being taken into account (i.e. not flagged as duplicate).
  target_tbl_versioned[2:4, ] <- target_tbl_versioned[1, ]
  target_tbl_versioned[2, "observation"] <- 1 # original was 0.
  target_tbl_versioned[3, "as_of"] <- Sys.Date() - 14L

  invalid_ts_versioned <- check_target_tbl_rows_unique(
    target_tbl_versioned,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts_versioned, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts_versioned$message) |> stringr::str_squish(),
    "time-series target data rows must be unique. Rows containing duplicate combinations: 2 and 4" # nolint: line_length_linter
  )
  expect_equal(invalid_ts_versioned$duplicate_rows, c(2L, 4L))
})

test_that("check_target_tbl_rows_unique works oracle-output data", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl <- read_target_file("oracle-output.csv", hub_path)
  file_path <- "oracle-output.csv"

  valid_oo <- check_target_tbl_rows_unique(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "oracle-output target data rows are unique."
  )
  expect_null(valid_oo$duplicate_rows)

  target_tbl_versioned <- target_tbl
  target_tbl_versioned$as_of <- Sys.Date()

  valid_oo_versioned <- check_target_tbl_rows_unique(
    target_tbl_versioned,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path = hub_path
  )
  expect_s3_class(valid_oo_versioned, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo_versioned$message) |> stringr::str_squish(),
    "oracle-output target data rows are unique."
  )
  expect_null(valid_oo_versioned$duplicate_rows)

  # Check with invalid time-series data. ----
  # -- Non-versioned --
  # Add duplicate rows to the target table.
  # Change the `oracle_value` column value in one of the
  # duplicates to demonstrate it's not being taken into account.
  target_tbl[2:3, ] <- target_tbl[1, ]
  target_tbl[2, "oracle_value"] <- 100 # original was 2380.

  invalid_oo <- check_target_tbl_rows_unique(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path = hub_path
  )
  expect_s3_class(invalid_oo, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "oracle-output target data rows must be unique. Rows containing duplicate combinations: 2 and 3" # nolint: line_length_linter
  )
  expect_equal(invalid_oo$duplicate_rows, 2:3)

  # -- Versioned --
  # Add duplicate rows to the target table.
  # Change the `oracle_value` column value in one of the
  # duplicates to demonstrate it's not being taken into account
  # (i.e. should be flagged as duplicate).
  # Also change the `as_of` date for one duplicate row to show it's
  # NOT being taken into account (i.e. still flagged as duplicate).
  target_tbl_versioned[2:4, ] <- target_tbl_versioned[1, ]
  target_tbl_versioned[2, "oracle_value"] <- 100 # original was 2380.
  target_tbl_versioned[3, "as_of"] <- Sys.Date() - 7L

  invalid_oo_versioned <- check_target_tbl_rows_unique(
    target_tbl_versioned,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path = hub_path
  )
  expect_s3_class(invalid_oo_versioned, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo_versioned$message) |> stringr::str_squish(),
    "oracle-output target data rows must be unique. Rows containing duplicate combinations: 2, 3, and 4" # nolint: line_length_linter
  )
  expect_equal(invalid_oo_versioned$duplicate_rows, 2:4)
})
