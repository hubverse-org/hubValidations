test_that("validate_target_submission works on single time-series target data file", {
  hub_path <- hubutils_target_file_hub()

  res_ts <- validate_target_submission(
    hub_path,
    file_path = "time-series.csv",
    target_type = "time-series"
  )
  expect_s3_class(res_ts, c("target_validations", "hub_validations"))
  expect_named(
    res_ts,
    c(
      "valid_config",
      "target_file_exists",
      "target_partition_file_name",
      "target_file_ext",
      "target_file_read",
      "target_tbl_colnames",
      "target_tbl_coltypes",
      "target_tbl_ts_targets",
      "target_tbl_rows_unique",
      "target_tbl_values",
      "target_tbl_output_type_ids",
      "target_tbl_oracle_value"
    )
  )
  expect_message(
    check_for_errors(res_ts),
    "All validation checks have been successful."
  )
  # Check print out
  expect_snapshot(res_ts)
})

test_that("validate_target_submission works on single oracle-output target data file", {
  hub_path <- hubutils_target_file_hub()

  res_oo <- validate_target_submission(
    hub_path,
    file_path = "oracle-output.csv",
    target_type = "oracle-output"
  )
  expect_s3_class(res_oo, c("target_validations", "hub_validations"))
  expect_named(
    res_oo,
    c(
      "valid_config",
      "target_file_exists",
      "target_partition_file_name",
      "target_file_ext",
      "target_file_read",
      "target_tbl_colnames",
      "target_tbl_coltypes",
      "target_tbl_ts_targets",
      "target_tbl_rows_unique",
      "target_tbl_values",
      "target_tbl_output_type_ids",
      "target_tbl_oracle_value"
    )
  )
  expect_message(
    check_for_errors(res_oo),
    "All validation checks have been successful."
  )
  # Check print out
  expect_snapshot(res_oo)
})

test_that("validate_target_submission works on multi-file time-series target data file", {
  hub_path <- hubutils_target_dir_hub()

  res_ts <- validate_target_submission(
    hub_path,
    file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
    target_type = "time-series"
  )
  expect_s3_class(res_ts, c("target_validations", "hub_validations"))
  expect_named(
    res_ts,
    c(
      "valid_config",
      "target_file_exists",
      "target_partition_file_name",
      "target_file_ext",
      "target_file_read",
      "target_tbl_colnames",
      "target_tbl_coltypes",
      "target_tbl_ts_targets",
      "target_tbl_rows_unique",
      "target_tbl_values",
      "target_tbl_output_type_ids",
      "target_tbl_oracle_value"
    )
  )
  expect_message(
    check_for_errors(res_ts),
    "All validation checks have been successful."
  )
})

test_that("validate_target_submission works on  multi-file oracle-output target data file", {
  hub_path <- hubutils_target_dir_hub()

  res_oo <- validate_target_submission(
    hub_path,
    file_path = "oracle-output/output_type=cdf/part-0.parquet",
    target_type = "oracle-output"
  )
  expect_s3_class(res_oo, c("target_validations", "hub_validations"))
  expect_named(
    res_oo,
    c(
      "valid_config",
      "target_file_exists",
      "target_partition_file_name",
      "target_file_ext",
      "target_file_read",
      "target_tbl_colnames",
      "target_tbl_coltypes",
      "target_tbl_ts_targets",
      "target_tbl_rows_unique",
      "target_tbl_values",
      "target_tbl_output_type_ids",
      "target_tbl_oracle_value"
    )
  )
  expect_message(
    check_for_errors(res_oo),
    "All validation checks have been successful."
  )
})

test_that("validate_target_submission returns early as expected", {
  hub_path <- hubutils_target_file_hub()
  early_return_ts <- validate_target_submission(
    hub_path,
    # Use non-existent file to trigger early return file existence check
    file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
    target_type = "time-series"
  )
  expect_s3_class(early_return_ts, c("target_validations", "hub_validations"))
  expect_named(
    early_return_ts,
    c(
      "valid_config",
      "target_file_exists"
    )
  )
  expect_error(
    suppressMessages(check_for_errors(early_return_ts)),
    "The validation checks produced some failures/errors reported above."
  )
  # Check print out
  expect_snapshot(early_return_ts)
})
