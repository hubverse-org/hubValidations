test_that("check_metadata_file_exists works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  expect_s3_class(
    check_submission_metadata_file_exists(
      hub_path = hub_path,
      file_path = "hub-baseline/2022-10-01-hub-baseline.csv"
    ),
    c("check_success")
  )
  expect_snapshot(
    check_submission_metadata_file_exists(
      hub_path = hub_path,
      file_path = "hub-baseline/2022-10-01-hub-baseline.csv"
    )
  )

  expect_s3_class(
    check_submission_metadata_file_exists(
      hub_path = hub_path,
      file_path = "random-model/2022-10-01-random-model.csv"
    ),
    c("check_failure")
  )
  expect_snapshot(
    check_submission_metadata_file_exists(
      hub_path = hub_path,
      file_path = "random-model/2022-10-01-random-model.csv"
    )
  )
})
