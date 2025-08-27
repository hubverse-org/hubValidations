test_that("validate_target_data works on single time-series target data file", {
  hub_path <- hubutils_target_file_hub()

  res_ts <- validate_target_data(
    hub_path,
    file_path = "time-series.csv",
    target_type = "time-series"
  )
  expect_s3_class(res_ts, "hub_validations")
  expect_named(
    res_ts,
    c(
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
  expect_snapshot(res_ts)
})

test_that("validate_target_data works on single oracle-output target data file", {
  hub_path <- hubutils_target_file_hub()

  res_oo <- validate_target_data(
    hub_path,
    file_path = "oracle-output.csv",
    target_type = "oracle-output"
  )
  expect_s3_class(res_oo, "hub_validations")
  expect_named(
    res_oo,
    c(
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
  expect_snapshot(res_oo)
})

test_that("validate_target_data works on multi-file time-series target data file", {
  hub_path <- hubutils_target_dir_hub()

  res_ts <- validate_target_data(
    hub_path,
    file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
    target_type = "time-series"
  )
  expect_s3_class(res_ts, "hub_validations")
  expect_named(
    res_ts,
    c(
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
  expect_snapshot(res_ts)
})

test_that("validate_target_data works on  multi-file oracle-output target data file", {
  hub_path <- hubutils_target_dir_hub()

  res_oo <- validate_target_data(
    hub_path,
    file_path = "oracle-output/output_type=cdf/part-0.parquet",
    target_type = "oracle-output"
  )
  expect_s3_class(res_oo, "hub_validations")
  expect_named(
    res_oo,
    c(
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
  expect_snapshot(res_oo)
})

test_that("validate_target_data fails on invalid target_type", {
  # Uses helper function test_early_return_val_target_data in helper-early-returns.R to
  # mock an execution error in each check function and ensure that
  # validate_target_data returns early as expected
  # Checking specific errors not required as this is done in each check's
  # own unit tests
  all_check_names <- c(
    "target_file_read",
    "target_tbl_colnames",
    "target_tbl_coltypes",
    "target_tbl_ts_targets",
    "target_tbl_rows_unique",
    "target_tbl_values",
    "target_tbl_output_type_ids",
    "target_tbl_oracle_value"
  )

  test_early_return_val_target_data("target_file_read")
  test_early_return_val_target_data("target_tbl_colnames")
  test_early_return_val_target_data("target_tbl_coltypes")
  test_early_return_val_target_data("target_tbl_ts_targets")
  # target_tbl_rows_unique does not return early so all checks should proceed
  test_early_return_val_target_data(
    "target_tbl_rows_unique",
    expected_check_names = all_check_names
  )
  test_early_return_val_target_data("target_tbl_values")
  test_early_return_val_target_data("target_tbl_output_type_ids")
})
