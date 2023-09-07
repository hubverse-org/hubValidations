test_that("check_metadata_file_exists works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  expect_s3_class(
    check_metadata_file_exists_for_output_submission(
      hub_path = hub_path,
      file_path = "hub-baseline/2022-10-01-hub-baseline.csv"),
    c("check_success", "rlang_message", "message", "condition")
  )
  expect_snapshot(
    check_metadata_file_exists_for_output_submission(
      hub_path = hub_path,
      file_path = "hub-baseline/2022-10-01-hub-baseline.csv")
  )

  expect_s3_class(
    check_metadata_file_exists_for_output_submission(
      hub_path = hub_path,
      file_path = "random-model/2022-10-01-random-model.csv"),
    c("check_error", "rlang_error", "error", "condition")
  )
  expect_snapshot(
    check_metadata_file_exists_for_output_submission(
      hub_path = hub_path,
      file_path = "random-model/2022-10-01-random-model.csv")
  )
})
