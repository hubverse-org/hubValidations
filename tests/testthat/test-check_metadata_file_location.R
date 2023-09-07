test_that("check_metadata_file_location works", {
  expect_s3_class(
    check_metadata_file_location("hub-baseline.yml"),
    c("check_success", "rlang_message", "message", "condition")
  )
  expect_snapshot(
    check_metadata_file_location("hub-baseline.yml")
  )

  expect_s3_class(
    check_metadata_file_location("random_folder/hub-baseline.yml"),
    c("check_error", "rlang_error", "error", "condition")
  )
  expect_snapshot(
    check_metadata_file_location("random_folder/hub-baseline.yml")
  )
})
