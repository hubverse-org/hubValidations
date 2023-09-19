test_that("check_metadata_file_exists works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  expect_s3_class(
    check_metadata_file_exists(hub_path, "hub-baseline.yml"),
    c("check_success", "rlang_message", "message", "condition")
  )
  expect_snapshot(
    check_metadata_file_exists(hub_path, "hub-baseline.yml")
  )

  expect_s3_class(
    check_metadata_file_exists(hub_path = "random_path", "hub-baseline.yml"),
    c("check_error", "rlang_error", "error", "condition")
  )
  expect_snapshot(
    check_metadata_file_exists(hub_path = "random_path", "hub-baseline.yml")
  )

  expect_s3_class(
    check_metadata_file_exists(hub_path = hub_path, "random_path"),
    c("check_error", "rlang_error", "error", "condition")
  )
  expect_snapshot(
    check_metadata_file_exists(hub_path = hub_path, "random_path")
  )
})
