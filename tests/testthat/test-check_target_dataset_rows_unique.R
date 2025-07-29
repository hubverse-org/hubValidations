test_that("check_target_dataset_rows_unique works time-series data", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  #  cloned in `setup.R`
  hub_path <- fs::path(tmp_dir, "test")
  fs::dir_copy(
    example_complex_forecasting_hub_path,
    hub_path
  )

  valid_ts <- check_target_dataset_rows_unique(
    target_type = "time-series",
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "time-series target dataset rows are unique."
  )
  expect_null(valid_ts$duplicate_df)
  expect_equal(
    valid_ts$where,
    "time-series.csv"
  )

  # Test with valid versioned data with two as_of dates
  ts_path <- test_target_file_path(hub_path, "time-series")
  ts_dat <- read_target_file("time-series.csv", hub_path)

  ts_dat_versioned <- rbind(ts_dat, ts_dat)
  ts_dat_versioned$as_of <- Sys.Date()
  ts_dat_versioned$as_of[
    duplicated(ts_dat_versioned)
  ] <- Sys.Date() - 7L
  arrow::write_csv_arrow(
    ts_dat_versioned,
    ts_path
  )

  valid_ts_versioned <- check_target_dataset_rows_unique(
    target_type = "time-series",
    hub_path = hub_path
  )
  expect_s3_class(valid_ts_versioned, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts_versioned$message) |> stringr::str_squish(),
    "time-series target dataset rows are unique."
  )
  expect_null(valid_ts_versioned$duplicate_df)

  # Check with invalid time-series data. ----
  # -- Non-versioned --
  # Add duplicate rows to the target table.
  # Change the `observation` column value in one of the
  # duplicates to demonstrate it's not being taken into account.
  ts_dat[2:3, ] <- ts_dat[1, ]
  ts_dat[2, "observation"] <- 1 # original was 0.
  arrow::write_csv_arrow(
    ts_dat,
    ts_path
  )

  invalid_ts <- check_target_dataset_rows_unique(
    target_type = "time-series",
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "time-series target dataset rows must be unique. Rows containing duplicate observations detected." # nolint: line_length_linter
  )
  expect_equal(
    invalid_ts$duplicate_df,
    structure(
      list(
        date = structure(18272, class = "Date"),
        target = "wk inc flu hosp",
        location = "01",
        count = 3L
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )

  # Check with invalid time-series data. ----
  # -- Versioned --
  # Add duplicate rows to the target table.
  # Change the `observation` column value in one of the
  # duplicates to demonstrate it's not being taken into account
  # (i.e. should be flagged as duplicate).
  # Also change the `as_of` date for one duplicate row to show it
  # is being taken into account (i.e. not flagged as duplicate).
  ts_dat_versioned[2:4, ] <- ts_dat_versioned[1, ]
  ts_dat_versioned[2, "observation"] <- 1 # original was 0.
  ts_dat_versioned[3, "as_of"] <- Sys.Date() - 14L
  arrow::write_csv_arrow(
    ts_dat_versioned,
    ts_path
  )

  invalid_ts_versioned <- check_target_dataset_rows_unique(
    target_type = "time-series",
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts_versioned, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts_versioned$message) |> stringr::str_squish(),
    "time-series target dataset rows must be unique. Rows containing duplicate observations detected." # nolint: line_length_linter
  )
  expect_equal(
    invalid_ts_versioned$duplicate_df,
    structure(
      list(
        date = structure(18272, class = "Date"),
        target = "wk inc flu hosp",
        location = "01",
        as_of = structure(20298, class = "Date"),
        count = 3L
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )
})

test_that("check_target_dataset_rows_unique works with hive partitioned parquet time-series data", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  #  cloned in `setup.R`
  hub_path <- example_dir_hub_path
  source_hub_path <- example_file_hub_path
  target_type <- "time-series"

  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )
  ts_dat <- test_read_target_data(source_hub_path, target_type)

  test_partition_target_data(
    data = ts_dat,
    hub_path = hub_path,
    target_type = target_type
  )

  valid_ts <- check_target_dataset_rows_unique(
    target_type = target_type,
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "time-series target dataset rows are unique."
  )
  expect_null(valid_ts$duplicate_df)
  expect_equal(
    valid_ts$where,
    "time-series"
  )

  # Test with valid versioned data with two as_of dates ----
  # Reset test hub
  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )

  # Test with valid versioned data with two as_of dates
  ts_dat_versioned <- rbind(ts_dat, ts_dat)
  ts_dat_versioned$as_of <- Sys.Date()
  ts_dat_versioned$as_of[
    duplicated(ts_dat_versioned)
  ] <- Sys.Date() - 7L

  test_partition_target_data(
    data = ts_dat_versioned,
    hub_path = hub_path,
    target_type = target_type
  )

  valid_ts_versioned <- check_target_dataset_rows_unique(
    target_type = target_type,
    hub_path = hub_path
  )
  expect_s3_class(valid_ts_versioned, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts_versioned$message) |> stringr::str_squish(),
    "time-series target dataset rows are unique."
  )
  expect_null(valid_ts_versioned$duplicate_df)

  # Check with invalid time-series data. ----
  # -- Non-versioned --
  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )
  # Add duplicate rows to the target table.
  # Change the `observation` column value in one of the
  # duplicates to demonstrate it's not being taken into account.
  ts_dat[2:3, ] <- ts_dat[1, ]
  ts_dat[2, "observation"] <- 1 # original was 0.

  test_partition_target_data(
    data = ts_dat,
    hub_path = hub_path,
    target_type = target_type
  )

  invalid_ts <- check_target_dataset_rows_unique(
    target_type = target_type,
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "time-series target dataset rows must be unique. Rows containing duplicate observations detected." # nolint: line_length_linter
  )
  expect_equal(
    invalid_ts$duplicate_df,
    structure(
      list(
        date = structure(18272, class = "Date"),
        location = "01",
        target = "wk inc flu hosp",
        count = 3L
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )

  # Check with invalid time-series data. ----
  # -- Versioned --
  # Reset test hub
  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )
  # Add duplicate rows to the target table.
  # Change the `observation` column value in one of the
  # duplicates to demonstrate it's not being taken into account
  # (i.e. should be flagged as duplicate).
  # Also change the `as_of` date for one duplicate row to show it
  # is being taken into account (i.e. not flagged as duplicate).
  ts_dat_versioned[2:4, ] <- ts_dat_versioned[1, ]
  ts_dat_versioned[2, "observation"] <- 1 # original was 0.
  ts_dat_versioned[3, "as_of"] <- Sys.Date() - 14L
  test_partition_target_data(
    data = ts_dat_versioned,
    hub_path = hub_path,
    target_type = target_type
  )

  invalid_ts_versioned <- check_target_dataset_rows_unique(
    target_type = target_type,
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts_versioned, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts_versioned$message) |> stringr::str_squish(),
    "time-series target dataset rows must be unique. Rows containing duplicate observations detected." # nolint: line_length_linter
  )
  expect_equal(
    invalid_ts_versioned$duplicate_df,
    structure(
      list(
        date = structure(18272, class = "Date"),
        location = "01",
        as_of = structure(20298, class = "Date"),
        target = "wk inc flu hosp",
        count = 3L
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )
})

test_that("check_target_dataset_rows_unique works on oracle-output data", {
  hub_path <- fs::path(tmp_dir, "test")
  fs::dir_copy(
    example_complex_forecasting_hub_path,
    hub_path
  )
  oo_dat <- read_target_file("oracle-output.csv", hub_path)
  oo_path <- test_target_file_path(hub_path, "oracle-output")

  valid_oo <- check_target_dataset_rows_unique(
    target_type = "oracle-output",
    hub_path = hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "oracle-output target dataset rows are unique."
  )
  expect_null(valid_oo$duplicate_df)
  expect_equal(
    valid_oo$where,
    "oracle-output.csv"
  )

  oo_dat_versioned <- oo_dat
  oo_dat_versioned$as_of <- Sys.Date()
  arrow::write_csv_arrow(
    oo_dat_versioned,
    oo_path
  )

  valid_oo_versioned <- check_target_dataset_rows_unique(
    target_type = "oracle-output",
    hub_path = hub_path
  )
  expect_s3_class(valid_oo_versioned, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo_versioned$message) |> stringr::str_squish(),
    "oracle-output target dataset rows are unique."
  )
  expect_null(valid_oo_versioned$duplicate_df)

  # Check with invalid time-series data. ----
  # -- Non-versioned --
  # Add duplicate rows to the target table.
  # Change the `oracle_value` column value in one of the
  # duplicates to demonstrate it's not being taken into account.
  oo_dat[2:3, ] <- oo_dat[1, ]
  oo_dat[2, "oracle_value"] <- 100 # original was 2380.
  arrow::write_csv_arrow(
    oo_dat,
    oo_path
  )

  invalid_oo <- check_target_dataset_rows_unique(
    target_type = "oracle-output",
    hub_path = hub_path
  )
  expect_s3_class(invalid_oo, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "oracle-output target dataset rows must be unique. Rows containing duplicate observations detected." # nolint: line_length_linter
  )
  expect_equal(
    invalid_oo$duplicate_df,
    structure(
      list(
        location = "US",
        target_end_date = structure(19287, class = "Date"),
        target = "wk inc flu hosp",
        output_type = "quantile",
        output_type_id = NA_character_,
        count = 3L
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )

  # -- Versioned --
  # Add duplicate rows to the target table.
  # Change the `oracle_value` column value in one of the
  # duplicates to demonstrate it's not being taken into account
  # (i.e. should be flagged as duplicate).
  # Also change the `as_of` date for one duplicate row to show it's
  # NOT being taken into account (i.e. still flagged as duplicate).
  oo_dat_versioned[2:4, ] <- oo_dat_versioned[1, ]
  oo_dat_versioned[2, "oracle_value"] <- 100 # original was 2380.
  oo_dat_versioned[3, "as_of"] <- Sys.Date() - 7L
  arrow::write_csv_arrow(
    oo_dat_versioned,
    oo_path
  )

  invalid_oo_versioned <- check_target_dataset_rows_unique(
    target_type = "oracle-output",
    hub_path = hub_path
  )
  expect_s3_class(invalid_oo_versioned, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo_versioned$message) |> stringr::str_squish(),
    "oracle-output target dataset rows must be unique. Rows containing duplicate observations detected." # nolint: line_length_linter
  )
  expect_equal(
    invalid_oo_versioned$duplicate_df,
    structure(
      list(
        location = "US",
        target_end_date = structure(19287, class = "Date"),
        target = "wk inc flu hosp",
        output_type = "quantile",
        output_type_id = NA_character_,
        count = 4L
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )
})

test_that("check_target_dataset_rows_unique works with hive partitioned parquet oracle-output data", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  #  cloned in `setup.R`
  hub_path <- example_dir_hub_path
  source_hub_path <- example_file_hub_path
  target_type <- "oracle-output"

  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )
  oo_dat <- test_read_target_data(source_hub_path, target_type)

  test_partition_target_data(
    data = oo_dat,
    hub_path = hub_path,
    target_type = target_type
  )

  valid_oo <- check_target_dataset_rows_unique(
    target_type = target_type,
    hub_path = hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "oracle-output target dataset rows are unique."
  )
  expect_null(valid_oo$duplicate_df)
  expect_equal(
    valid_oo$where,
    "oracle-output"
  )

  # Test with valid versioned data with two as_of dates ----
  # Reset test hub
  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )

  # Test with valid versioned data with two as_of dates
  oo_dat_versioned <- oo_dat
  oo_dat_versioned$as_of <- Sys.Date()

  test_partition_target_data(
    data = oo_dat_versioned,
    hub_path = hub_path,
    target_type = target_type
  )

  valid_oo_versioned <- check_target_dataset_rows_unique(
    target_type = target_type,
    hub_path = hub_path
  )
  expect_s3_class(valid_oo_versioned, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo_versioned$message) |> stringr::str_squish(),
    "oracle-output target dataset rows are unique."
  )
  expect_null(valid_oo_versioned$duplicate_df)

  # Check with invalid oracle-output data. ----
  # -- Non-versioned --
  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )
  # Add duplicate rows to the dataset.
  # Change the `oracle_value` column value in one of the
  # duplicates to demonstrate it's not being taken into account.
  oo_dat[2:3, ] <- oo_dat[1, ]
  oo_dat[2, "oracle_value"] <- 100 # original was 2380.

  test_partition_target_data(
    data = oo_dat,
    hub_path = hub_path,
    target_type = target_type
  )

  invalid_oo <- check_target_dataset_rows_unique(
    target_type = target_type,
    hub_path = hub_path
  )
  expect_s3_class(invalid_oo, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "oracle-output target dataset rows must be unique. Rows containing duplicate observations detected." # nolint: line_length_linter
  )
  expect_equal(
    invalid_oo$duplicate_df,
    structure(
      list(
        location = "US",
        target_end_date = structure(19287, class = "Date"),
        output_type = "quantile",
        output_type_id = NA_character_,
        target = "wk inc flu hosp",
        count = 3L
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )

  # Check with invalid oracle-output data. ----
  # -- Versioned --
  # Reset test hub
  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )
  # Add duplicate rows to the target table.
  # Change the `oracle_value` column value in one of the
  # duplicates to demonstrate it's not being taken into account
  # (i.e. should be flagged as duplicate).
  # Also change the `as_of` date for one duplicate row to show it's
  # NOT being taken into account (i.e. still flagged as duplicate).
  oo_dat_versioned[2:4, ] <- oo_dat_versioned[1, ]
  oo_dat_versioned[2, "oracle_value"] <- 100 # original was 2380.
  oo_dat_versioned[3, "as_of"] <- Sys.Date() - 7L

  test_partition_target_data(
    data = oo_dat_versioned,
    hub_path = hub_path,
    target_type = target_type
  )

  invalid_oo_versioned <- check_target_dataset_rows_unique(
    target_type = target_type,
    hub_path = hub_path
  )
  expect_s3_class(invalid_oo_versioned, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo_versioned$message) |> stringr::str_squish(),
    "oracle-output target dataset rows must be unique. Rows containing duplicate observations detected." # nolint: line_length_linter
  )
  expect_equal(
    invalid_oo_versioned$duplicate_df,
    structure(
      list(
        location = "US",
        target_end_date = structure(19287, class = "Date"),
        output_type = "quantile",
        output_type_id = NA_character_,
        target = "wk inc flu hosp",
        count = 4L
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -1L)
    )
  )
})
