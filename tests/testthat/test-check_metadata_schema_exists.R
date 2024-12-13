test_that("check_metadata_schema_exists works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  expect_s3_class(
    check_metadata_schema_exists(hub_path),
    c("check_success")
  )
  expect_snapshot(
    check_metadata_schema_exists(hub_path)
  )

  expect_s3_class(
    check_metadata_schema_exists(hub_path = "random_path"),
    c("check_error")
  )
  expect_snapshot(
    check_metadata_schema_exists(hub_path = "random_path")
  )
})
