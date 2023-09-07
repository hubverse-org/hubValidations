test_that("validate_model_metadata works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  file_path <- "team1-goodmodel.yaml"
  expect_snapshot(
    str(
      validate_model_metadata(hub_path, file_path)
    )
  )
  expect_s3_class(
    validate_model_metadata(hub_path, file_path),
    c("hub_validations", "list")
  )

  file_path <- "hub-baseline.yml"
  expect_snapshot(
    str(
      validate_model_metadata(hub_path, file_path)
    )
  )
  expect_s3_class(
    validate_model_metadata(hub_path, file_path),
    c("hub_validations", "list")
  )

  file_path <- "hub-baseline-no-abbrs-or-model_id.yml"
  expect_snapshot(
    str(
      validate_model_metadata(hub_path, file_path)
    )
  )
  expect_s3_class(
    validate_model_metadata(hub_path, file_path),
    c("hub_validations", "list")
  )

  file_path <- "2020-10-06-random-path.csv"
  expect_snapshot(
    str(
      validate_model_metadata(hub_path, file_path)
    )
  )
  expect_s3_class(
    validate_model_metadata(hub_path, file_path),
    c("hub_validations", "list")
  )
})
