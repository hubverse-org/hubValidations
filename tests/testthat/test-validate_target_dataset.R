# Tests use hubUtils example hubs
# Requires helper-v5-hubs.R with:
# - hubutils_target_file_hub()
# - hubutils_target_dir_hub()
# - use_example_hub_editable()

test_that("validate_target_dataset works on single file target data", {
  hub_path <- hubutils_target_file_hub()

  # Validate time-series data
  res_ts <- validate_target_dataset(
    hub_path = hub_path,
    target_type = "time-series"
  )
  expect_s3_class(res_ts, "hub_validations")
  expect_named(
    res_ts,
    c(
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )
  expect_equal(
    unique(purrr::map_chr(res_ts, ~ .x$where)),
    "time-series.csv"
  )
  expect_message(
    check_for_errors(res_ts),
    "All validation checks have been successful."
  )
  expect_snapshot(res_ts)

  # Validate oracle-output data
  res_oo <- validate_target_dataset(
    hub_path = hub_path,
    target_type = "oracle-output"
  )
  expect_s3_class(res_oo, "hub_validations")
  expect_named(
    res_oo,
    c(
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )
  expect_equal(
    unique(purrr::map_chr(res_oo, ~ .x$where)),
    "oracle-output.csv"
  )
  expect_message(
    check_for_errors(res_oo),
    "All validation checks have been successful."
  )
  expect_snapshot(res_oo)
})


test_that("validate_target_dataset works on muli-file target data", {
  hub_path <- hubutils_target_dir_hub()

  # Validate time-series data
  res_ts <- validate_target_dataset(
    hub_path = hub_path,
    target_type = "time-series"
  )
  expect_s3_class(res_ts, "hub_validations")
  expect_named(
    res_ts,
    c(
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )
  expect_equal(
    unique(purrr::map_chr(res_ts, ~ .x$where)),
    "time-series"
  )
  expect_message(
    check_for_errors(res_ts),
    "All validation checks have been successful."
  )
  expect_snapshot(res_ts)

  # Validate oracle-output data
  res_oo <- validate_target_dataset(
    hub_path = hub_path,
    target_type = "oracle-output"
  )
  expect_s3_class(res_oo, "hub_validations")
  expect_named(
    res_oo,
    c(
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )
  expect_equal(
    unique(purrr::map_chr(res_oo, ~ .x$where)),
    "oracle-output"
  )
  expect_message(
    check_for_errors(res_oo),
    "All validation checks have been successful."
  )
  expect_snapshot(res_oo)
})

test_that("validate_target_dataset returns appropriately when detecting errors", {
  hub_path <- use_example_hub_editable()
  fs::file_delete(
    test_target_file_path(hub_path, "time-series")
  )
  # Test missing time-series data
  mussing_res_ts <- validate_target_dataset(
    hub_path = hub_path,
    target_type = "time-series"
  )
  expect_s3_class(mussing_res_ts, "hub_validations")
  expect_named(mussing_res_ts, "target_dataset_exists")
  expect_error(
    suppressMessages(check_for_errors(mussing_res_ts)),
    "The validation checks produced some failures/errors reported above."
  )
  expect_snapshot(mussing_res_ts)

  # Test multiple target data sets
  hub_path <- use_example_hub_editable()
  fs::dir_copy(
    test_target_dir_path(hubutils_target_dir_hub(), "time-series"),
    test_target_dir_path(hub_path, "time-series")
  )
  dup_res_ts <- validate_target_dataset(
    hub_path = hub_path,
    target_type = "time-series"
  )
  expect_s3_class(dup_res_ts, "hub_validations")
  expect_named(dup_res_ts, c("target_dataset_exists", "target_dataset_unique"))
  expect_error(
    suppressMessages(check_for_errors(dup_res_ts)),
    "The validation checks produced some failures/errors reported above."
  )
  expect_snapshot(dup_res_ts)
})
