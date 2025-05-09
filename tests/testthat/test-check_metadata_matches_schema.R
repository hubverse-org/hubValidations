test_that("check_metadata_matches_schema works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  expect_s3_class(
    check_metadata_matches_schema(
      file_path = "hub-baseline.yml",
      hub_path = hub_path
    ),
    c("check_success")
  )
  expect_snapshot(
    check_metadata_matches_schema(
      file_path = "hub-baseline.yml",
      hub_path = hub_path
    )
  )

  expect_s3_class(
    check_metadata_matches_schema(
      file_path = "team1-goodmodel.yaml",
      hub_path = hub_path
    ),
    c("check_error")
  )
  expect_snapshot(
    check_metadata_matches_schema(
      file_path = "team1-goodmodel.yaml",
      hub_path = hub_path
    )
  )
})
