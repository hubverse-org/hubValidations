# Expected results of the metadata checks that run before the schema check
# on a metadata file in the simple test hub.
metadata_checks <- c(
  metadata_schema_exists = "check_success",
  metadata_file_exists = "check_success",
  metadata_file_ext = "check_success",
  metadata_file_location = "check_success"
)

test_that("validate_model_metadata works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  file_path <- "team1-goodmodel.yaml"
  res <- validate_model_metadata(hub_path, file_path)
  expect_s3_class(res, "hub_validations")
  expect_equal(
    first_classes(res),
    c(
      metadata_checks,
      metadata_matches_schema = "check_error"
    )
  )
  expect_snapshot(res$metadata_matches_schema)

  file_path <- "hub-baseline.yml"
  res <- validate_model_metadata(hub_path, file_path)
  expect_s3_class(res, "hub_validations")
  expect_equal(
    first_classes(res),
    c(
      metadata_checks,
      metadata_matches_schema = "check_success",
      metadata_file_name = "check_success"
    )
  )

  file_path <- "hub-baseline-no-abbrs-or-model_id.yml"
  res <- validate_model_metadata(hub_path, file_path)
  expect_s3_class(res, "hub_validations")
  expect_equal(
    first_classes(res),
    c(
      metadata_checks,
      metadata_matches_schema = "check_error"
    )
  )
  expect_snapshot(res$metadata_matches_schema)

  file_path <- "2020-10-06-random-path.csv"
  res <- validate_model_metadata(hub_path, file_path)
  expect_s3_class(res, "hub_validations")
  expect_equal(
    first_classes(res),
    c(
      metadata_checks["metadata_schema_exists"],
      metadata_file_exists = "check_error"
    )
  )
  expect_snapshot(res$metadata_file_exists)
})
