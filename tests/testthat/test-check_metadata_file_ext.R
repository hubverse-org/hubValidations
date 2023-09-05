test_that("check_metadata_file_ext works", {
  expect_s3_class(
    check_metadata_file_ext("model-metadata/hub-baseline.yml"),
    c("check_success", "rlang_message", "message", "condition")
  )

  expect_s3_class(
    check_metadata_file_ext("model-metadata/hub-baseline.yaml"),
    c("check_success", "rlang_message", "message", "condition")
  )

  expect_s3_class(
    check_metadata_file_ext("model-metadata/hub-baseline.txt"),
    c("check_error", "rlang_error", "error", "condition")
  )
})
