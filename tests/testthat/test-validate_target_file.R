test_that("validate_target_file works with single CSV target data file", {
  hub_path <- system.file("testhubs/v5/target_file", package = "hubValidations")

  # time-series CSV file
  res_ts <- validate_target_file(hub_path, file_path = "time-series.csv")
  expect_s3_class(res_ts, "hub_validations")
  expect_named(
    res_ts,
    c("target_file_exists", "target_partition_file_name", "target_file_ext")
  )
  expect_message(
    check_for_errors(res_ts),
    "All validation checks have been successful."
  )
  expect_snapshot(res_ts)

  # oracle-output CSV file
  res_oo <- validate_target_file(hub_path, file_path = "oracle-output.csv")
  expect_s3_class(res_oo, "hub_validations")
  expect_named(
    res_oo,
    c("target_file_exists", "target_partition_file_name", "target_file_ext")
  )
  expect_message(
    check_for_errors(res_oo),
    "All validation checks have been successful."
  )
  expect_snapshot(res_oo)
})


test_that("validate_target_file works with partitioned parquet target data file", {
  hub_path <- system.file("testhubs/v5/target_dir", package = "hubValidations")

  # time-series CSV file
  res_ts <- validate_target_file(
    hub_path,
    file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"
  )
  expect_s3_class(res_ts, "hub_validations")
  expect_named(
    res_ts,
    c("target_file_exists", "target_partition_file_name", "target_file_ext")
  )
  expect_message(
    check_for_errors(res_ts),
    "All validation checks have been successful."
  )
  expect_snapshot(res_ts)

  # oracle-output CSV file
  res_oo <- validate_target_file(
    hub_path,
    file_path = "oracle-output/output_type=pmf/part-0.parquet"
  )
  expect_s3_class(res_oo, "hub_validations")
  expect_named(
    res_oo,
    c("target_file_exists", "target_partition_file_name", "target_file_ext")
  )
  expect_message(
    check_for_errors(res_oo),
    "All validation checks have been successful."
  )
  expect_snapshot(res_oo)
})
