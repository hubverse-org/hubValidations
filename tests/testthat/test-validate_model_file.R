test_that("validate_model_file works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  # File that passes validation
  expect_snapshot(
    validate_model_file(hub_path,
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    )
  )
  expect_snapshot(
    str(
      validate_model_file(hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
      )
    )
  )
  expect_s3_class(
    validate_model_file(hub_path,
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    ),
    c("hub_validations", "list")
  )

  # File with validation error
  expect_snapshot(
    validate_model_file(hub_path,
      file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
    )
  )
  expect_s3_class(
    validate_model_file(hub_path,
      file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
    ),
    c("hub_validations", "list")
  )

  expect_snapshot(
    validate_model_file(hub_path,
      file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv"
    )
  )
})
