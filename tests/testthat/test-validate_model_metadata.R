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
  # Model output and metadata files share the file exists check.
  expect_check(
    res$metadata_file_exists,
    error_class,
    where = "2020-10-06-random-path.csv",
    call = "check_file_exists"
  )
})
