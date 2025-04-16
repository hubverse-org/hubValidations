test_that("check_target_dataset_file_ext_unique works", {
  hub_path <- withr::local_tempdir()
  fs::dir_create(fs::path(hub_path, "target-data"))

  # Create multiple time-series dataset (single and directory) files
  # with same extension to show test works with multiple datasets.
  # Ensuring single datasets per target type is achieved by
  # check_target_dataset_unique().
  fs::file_create(fs::path(hub_path, "target-data", "time-series.csv"))
  fs::dir_create(fs::path(hub_path, "target-data", "time-series"))
  fs::file_create(fs::path(hub_path, "target-data", "time-series", "file_1.csv"))


  valid_check <- check_target_dataset_file_ext_unique(
    hub_path,
    target_type = "time-series"
  )
  expect_s3_class(valid_check, "check_success")
  expect_equal(
    cli::ansi_strip(valid_check$message) |> stringr::str_squish(),
    "time-series dataset files share single unique file format."
  )
  skip_check <- check_target_dataset_file_ext_unique(
    hub_path,
    target_type = "oracle-output"
  )
  expect_s3_class(skip_check, "check_info")
  expect_equal(
    cli::ansi_strip(skip_check$message) |> stringr::str_squish(),
    "No oracle-output target type files detected in `target-data` directory. Check skipped."
  )

  fs::dir_create(fs::path(hub_path, "target-data", "oracle-output"))
  fs::file_create(fs::path(hub_path, "target-data", "oracle-output", "file_1.csv"))
  fs::file_create(fs::path(hub_path, "target-data", "oracle-output", "file_2.csv"))

  valid_check_oo <- check_target_dataset_file_ext_unique(
    hub_path,
    target_type = "oracle-output"
  )
  expect_s3_class(valid_check_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_check_oo$message) |> stringr::str_squish(),
    "oracle-output dataset files share single unique file format."
  )


  fs::file_create(fs::path(hub_path, "target-data", "time-series", "file_2.parquet"))
  fs::file_create(fs::path(hub_path, "target-data", "time-series", "README"))

  error_check <- check_target_dataset_file_ext_unique(
    hub_path,
    target_type = "time-series"
  )
  expect_s3_class(error_check, "check_failure")
  expect_equal(
    cli::ansi_strip(error_check$message) |> stringr::str_squish(),
    "time-series dataset files must share single unique file format. Multiple time-series file extensions found: \"\", \"csv\", and \"parquet\"." # nolint: line_length_linter
  )
})
