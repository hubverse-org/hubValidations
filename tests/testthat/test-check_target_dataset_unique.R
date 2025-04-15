test_that("check_target_dataset_unique works", {
  hub_path <- withr::local_tempdir()
  fs::dir_create(fs::path(hub_path, "target-data"))
  fs::file_create(fs::path(hub_path, "target-data", "time-series.csv"))

  valid_check <- check_target_dataset_unique(hub_path, target_type = "time-series")
  expect_s3_class(valid_check, "check_success")
  expect_equal(
    cli::ansi_strip(valid_check$message) |> stringr::str_squish(),
    "'target-data' directory contains single unique time-series dataset."
  )

  skip_check <- check_target_dataset_unique(hub_path, target_type = "oracle-output")
  expect_s3_class(skip_check, "check_info")
  expect_equal(
    cli::ansi_strip(skip_check$message) |> stringr::str_squish(),
    "No oracle-output target type files detected in 'target-data' directory. Check skipped."
  )

  fs::dir_create(fs::path(hub_path, "target-data", "time-series"))
  error_check <- check_target_dataset_unique(hub_path, target_type = "time-series")
  expect_s3_class(error_check, "check_error")
  expect_equal(
    cli::ansi_strip(error_check$message) |> stringr::str_squish(),
    "'target-data' directory must contain single unique time-series dataset. Multiple time-series datasets found: 'time-series' and 'time-series.csv'" # nolint: line_length_linter
  )
})
