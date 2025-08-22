test_that("check_target_dataset_exists works on single file target datasets", {
  hub_path <- hubutils_target_file_hub()
  res_ts <- check_target_dataset_exists(
    hub_path = hub_path,
    target_type = "time-series"
  )
  expect_s3_class(res_ts, "check_success")
  expect_equal(res_ts$where, "time-series.csv")
  expect_equal(
    cli::ansi_strip(res_ts$message) |> stringr::str_squish(),
    "time-series dataset detected."
  )

  res_oo <- check_target_dataset_exists(
    hub_path = hub_path,
    target_type = "oracle-output"
  )
  expect_s3_class(res_oo, "check_success")
  expect_equal(res_oo$where, "oracle-output.csv")
  expect_equal(
    cli::ansi_strip(res_oo$message) |> stringr::str_squish(),
    "oracle-output dataset detected."
  )
})

test_that("check_target_dataset_exists works on multi file target datasets", {
  hub_path <- hubutils_target_dir_hub()
  res_ts <- check_target_dataset_exists(
    hub_path = hub_path,
    target_type = "time-series"
  )
  expect_s3_class(res_ts, "check_success")
  expect_equal(res_ts$where, "time-series")
  expect_equal(
    cli::ansi_strip(res_ts$message) |> stringr::str_squish(),
    "time-series dataset detected."
  )

  res_oo <- check_target_dataset_exists(
    hub_path = hub_path,
    target_type = "oracle-output"
  )
  expect_s3_class(res_oo, "check_success")
  expect_equal(res_oo$where, "oracle-output")
  expect_equal(
    cli::ansi_strip(res_oo$message) |> stringr::str_squish(),
    "oracle-output dataset detected."
  )
})


test_that("check_target_dataset_exists detects missing datasets", {
  hub_path <- use_example_hub_editable()
  fs::file_delete(
    test_target_file_path(hub_path, "time-series")
  )
  # Test missing time-series data
  res_ts <- check_target_dataset_exists(
    hub_path = hub_path,
    target_type = "time-series"
  )
  expect_s3_class(res_ts, "check_error")
  expect_equal(res_ts$where, "time-series")
  expect_equal(
    cli::ansi_strip(res_ts$message) |> stringr::str_squish(),
    "time-series dataset not detected."
  )

  # Test multiple target data sets
  hub_path <- use_example_hub_editable()
  fs::dir_copy(
    test_target_dir_path(hubutils_target_dir_hub(), "time-series"),
    test_target_dir_path(hub_path, "time-series")
  )

  res_ts <- check_target_dataset_exists(
    hub_path = hub_path,
    target_type = "time-series"
  )
  # Check succeeds because datasets identified but target type returned as
  # `where` instead of the file path to one or the other dataset
  expect_s3_class(res_ts, "check_success")
  expect_equal(res_ts$where, "time-series")
  expect_equal(
    cli::ansi_strip(res_ts$message) |> stringr::str_squish(),
    "time-series dataset detected."
  )
})
