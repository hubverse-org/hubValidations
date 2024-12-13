test_that("check_metadata_file_ext works", {
  expect_s3_class(
    check_metadata_file_ext("hub-baseline.yml"),
    c("check_success")
  )
  expect_snapshot(
    check_metadata_file_ext("hub-baseline.yml")
  )

  expect_s3_class(
    check_metadata_file_ext("hub-baseline.yaml"),
    c("check_success")
  )
  expect_snapshot(
    check_metadata_file_ext("hub-baseline.yaml")
  )

  expect_s3_class(
    check_metadata_file_ext("hub-baseline.txt"),
    c("check_error")
  )
  expect_snapshot(
    check_metadata_file_ext("hub-baseline.txt")
  )
})
