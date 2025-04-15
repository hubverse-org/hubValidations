test_that("check_target_file_name on valid hive-partitions paths works", {
  valid_check <- check_target_file_name(
    file_path = "time-series/location=US/partition=valid/good-file.csv"
  )
  expect_s3_class(valid_check, "check_success")
  expect_equal(
    valid_check$message,
    "Hive-style partition file path segments are valid. \n "
  )
})

test_that("check_target_file_name on invalid hive-partitions paths works", {
  error_check <- check_target_file_name(file_path = "time-series/=/=error/good-file.csv")
  expect_s3_class(error_check, "check_error")
  expect_equal(
    cli::ansi_strip(error_check$message),
    "Hive-style partition file path segments must be valid. \n File path segments \"=\" and \"=error\" malformed."
  )
})

test_that("check_target_file_name on non hive-partitions paths is skipped", {
  skip_check <- check_target_file_name(
    file_path = "time-series/good-file.csv"
  )
  expect_s3_class(skip_check, "check_info")
  expect_equal(
    skip_check$message,
    "Target file path not hive-partitioned. Check skipped."
  )
})
