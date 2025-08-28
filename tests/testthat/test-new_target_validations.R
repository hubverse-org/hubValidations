test_that("new_target_validations works", {
  expect_snapshot(str(new_target_validations()))
  expect_s3_class(
    new_target_validations(),
    c("target_validations", "hub_validations")
  )

  hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
  file_path <- "time-series.csv"

  expect_snapshot(
    str(
      new_target_validations(
        target_file_name = check_target_file_name(file_path),
        target_file_ext_valid = check_target_file_ext_valid(file_path)
      )
    )
  )

  expect_s3_class(
    new_target_validations(
      target_file_name = check_target_file_name(file_path),
      target_file_ext_valid = check_target_file_ext_valid(file_path)
    ),
    c("target_validations", "hub_validations")
  )
})

test_that("new_target_validations works with hive partitioned target files", {
  file_path <- "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"

  expect_snapshot(
    str(
      new_target_validations(
        target_file_name = check_target_file_name(file_path),
        target_file_ext_valid = check_target_file_ext_valid(file_path)
      )
    )
  )

  expect_s3_class(
    new_target_validations(
      target_file_name = check_target_file_name(file_path),
      target_file_ext_valid = check_target_file_ext_valid(file_path)
    ),
    c("target_validations", "hub_validations")
  )
})

test_that("get_filenames shows full path for target_validations", {
  file_path <- "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"

  target_val <- new_target_validations(
    target_file_name = check_target_file_name(file_path)
  )

  hub_val <- new_hub_validations(
    target_file_name = check_target_file_name(file_path)
  )

  # target_validations should show full path
  expect_equal(
    get_filenames(target_val),
    file_path
  )

  # hub_validations should show basename only
  expect_equal(
    get_filenames(hub_val),
    basename(file_path)
  )
})
