# –– Non-hive paths ––
test_that("non-hive valid extensions return check_success", {
  csv_ok <- check_target_file_ext_valid("time-series.csv")
  expect_s3_class(csv_ok, "check_success")
  expect_equal(
    stringr::str_squish(csv_ok$message),
    "Target data file extension is valid."
  )

  csv_multi_ok <- check_target_file_ext_valid("time-series/file_1.csv")
  expect_s3_class(csv_multi_ok, "check_success")
  expect_equal(
    stringr::str_squish(csv_ok$message),
    "Target data file extension is valid."
  )


  parquet_ok <- check_target_file_ext_valid("time-series.parquet")
  expect_s3_class(parquet_ok, "check_success")
  expect_equal(
    stringr::str_squish(parquet_ok$message),
    "Target data file extension is valid."
  )
})

test_that("non-hive invalid extension returns check_error with correct message", {
  error_txt <- check_target_file_ext_valid("time-series.txt")
  expect_s3_class(error_txt, "check_error")
  expect_equal(
    cli::ansi_strip(error_txt$message) |> stringr::str_squish(),
    "Target data file extension must be valid. Extension \"txt\" is not. Must be one of \"csv\" and \"parquet\"."
  )
})

# –– Hive-partitioned paths ––
test_that("hive-partitioned valid extension returns check_success", {
  hive_ok <- check_target_file_ext_valid(
    "time-series/date=2025-01-01/part-0.parquet"
  )
  expect_s3_class(hive_ok, "check_success")
  expect_equal(
    stringr::str_squish(hive_ok$message),
    "Hive-partitioned target data file extension is valid."
  )
})

test_that("hive-partitioned invalid extension returns check_error with correct message", {
  hive_err <- check_target_file_ext_valid(
    "time-series/date=2025-01-01/part-0.csv"
  )
  expect_s3_class(hive_err, "check_error")
  expect_equal(
    cli::ansi_strip(hive_err$message) |> stringr::str_squish(),
    "Hive-partitioned target data file extension must be valid. Extension \"csv\" is not. Must be \"parquet\"."
  )
})

# –– Edge cases ––
test_that("file without extension returns check_error", {
  no_ext <- check_target_file_ext_valid("README")
  expect_s3_class(no_ext, "check_error")

  expect_match(
    cli::ansi_strip(no_ext$message) |> stringr::str_squish(),
    "Extension \"\" is not"
  )
})

test_that("uppercase extension is treated literally and returns check_error", {
  upper <- check_target_file_ext_valid("time-series.CSV")
  expect_s3_class(upper, "check_error")

  expect_match(
    cli::ansi_strip(upper$message) |> stringr::str_squish(),
    "Extension \"CSV\" is not"
  )
})
