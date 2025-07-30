test_that("check_target_file_read works with csv data", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  # cloned in `setup.R`
  hub_path <- fs::path(tmp_dir, "test")
  fs::dir_copy(
    example_complex_forecasting_hub_path,
    hub_path,
    overwrite = TRUE
  )

  target_path <- hubData::get_target_path(
    hub_path = hub_path
  )

  file_path <- fs::path_rel(
    target_path,
    fs::path(hub_path, "target-data")
  )

  # Should read successfully
  valid_csv <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_csv, "check_success")
  expect_equal(
    cli::ansi_strip(valid_csv$message) |> stringr::str_squish(),
    "target file could be read successfully."
  )

  # Modify the file to make it invalid. First create path to source file
  source_hub_path <- example_file_hub_path
  source_target_path <- hubData::get_target_path(
    hub_path = source_hub_path
  )

  # Break the structure (uneven columns) ----
  lines <- readLines(source_target_path)
  lines[3] <- "only_one_column"

  writeLines(lines, target_path)
  invalid_csv <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(invalid_csv, "check_error")
  expect_match(
    cli::ansi_strip(invalid_csv$message) |> stringr::str_squish(),
    "target file could not be read successfully.*Could not open CSV input source.*Expected 4 columns, got 1"
  )

  # Break quoting (unclosed quote) ----
  lines <- readLines(source_target_path)
  lines[3] <- '"2020-01-11,wk inc flu hosp,15,0' # missing closing quote
  writeLines(lines, target_path)

  unclosed_quote_csv <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(unclosed_quote_csv, "check_error")
  expect_match(
    cli::ansi_strip(unclosed_quote_csv$message) |> stringr::str_squish(),
    "target file could not be read successfully.*CSV parse error: Row #3: Expected 4 columns, got 1"
  )

  # Corrupted binary content ----
  writeBin(as.raw(c(0x42, 0xAD, 0xFF)), target_path) # write non-UTF-8 binary junk

  binary_junk_csv <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(binary_junk_csv, "check_error")
  expect_match(
    cli::ansi_strip(binary_junk_csv$message) |> stringr::str_squish(),
    "target file could not be read successfully.*Invalid: CSV parse error: Empty CSV file or block|Invalid or incomplete multibyte|parsing failure" # nolint: line_length_linter
  )

  # Empty file ----
  file.create(target_path) # overwrite with 0-byte file

  empty_csv <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(empty_csv, "check_error")
  expect_match(
    cli::ansi_strip(empty_csv$message) |> stringr::str_squish(),
    "target file could not be read successfully.*Invalid: CSV parse error: Empty CSV file or block*"
  )
})

test_that("check_target_file_read works with parquet data", {
  # Setup: clone and modify hub
  hub_path <- fs::path(tmp_dir, "test-parquet")
  fs::dir_copy(
    example_complex_forecasting_hub_path,
    hub_path
  )

  # Overwrite CSV with Parquet version
  source_hub_path <- example_file_hub_path
  source_target_path <- hubData::get_target_path(hub_path = source_hub_path)

  df <- readr::read_csv(source_target_path, show_col_types = FALSE)
  parquet_path <- fs::path_ext_set(
    hubData::get_target_path(hub_path = hub_path),
    "parquet"
  )
  # Remove original .csv file to avoid ambiguity
  fs::file_delete(hubData::get_target_path(hub_path = hub_path))

  arrow::write_parquet(df, parquet_path)

  # Construct relative path
  file_path <- fs::path_rel(
    parquet_path,
    fs::path(hub_path, "target-data")
  )

  # Should read successfully
  valid_parquet <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_parquet, "check_success")
  expect_equal(
    cli::ansi_strip(valid_parquet$message) |> stringr::str_squish(),
    "target file could be read successfully."
  )

  # Empty parquet file ----
  file.create(parquet_path)

  empty_parquet <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(empty_parquet, "check_error")
  expect_match(
    cli::ansi_strip(empty_parquet$message) |> stringr::str_squish(),
    "target file could not be read successfully.*Invalid: Parquet file size is 0 bytes"
  )

  # Corrupted parquet file ----
  writeBin(as.raw(c(0x50, 0x51, 0x00, 0xFF)), parquet_path) # random binary junk

  corrupt_parquet <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(corrupt_parquet, "check_error")
  expect_match(
    cli::ansi_strip(corrupt_parquet$message) |> stringr::str_squish(),
    "target file could not be read successfully.*Invalid: Parquet file size is 4 bytes, smaller than the minimum file footer" # nolint: line_length_linter
  )

  # Wrong file type ----
  writeLines(c("<html>", "<body>not parquet</body>", "</html>"), parquet_path)

  html_parquet <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(html_parquet, "check_error")
  expect_match(
    cli::ansi_strip(html_parquet$message) |> stringr::str_squish(),
    "target file could not be read successfully.*Invalid: Parquet magic bytes not found in footer"
  )
})

test_that("check_target_file_read works on partitioned data", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  # cloned in `setup.R`
  target_type <- "time-series"
  hub_path <- fs::path(tmp_dir, "test")
  fs::dir_create(hub_path)

  source_hub_path <- example_file_hub_path
  source_target_path <- hubData::get_target_path(
    hub_path = source_hub_path
  )

  test_setup_blank_target_dir(
    hub_path = hub_path,
    source_hub_path = source_hub_path,
    target_type = target_type
  )
  # Read target data from single source hub file. We use a separate source
  # hub file here to avoid I/O lock issues on Windows.
  ts_dat <- test_read_target_data(source_hub_path, target_type)

  test_partition_target_data(
    data = ts_dat,
    hub_path = hub_path,
    target_type = target_type
  )

  # Should read successfully
  file_path <- "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"
  valid_partitioned <- check_target_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_partitioned, "check_success")
  expect_equal(
    cli::ansi_strip(valid_partitioned$message) |> stringr::str_squish(),
    "target file could be read successfully."
  )
  expect_equal(valid_partitioned$where, file_path)
})
