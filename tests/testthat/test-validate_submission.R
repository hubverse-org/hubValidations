test_that("validate_submission works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  # File that passes validation
  expect_snapshot(
    str(
      validate_submission(hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
      )
    )
  )
  expect_s3_class(
    validate_submission(hub_path,
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    ),
    c("hub_validations", "list")
  )

  # File with validation error
  expect_snapshot(
    str(
      validate_submission(hub_path,
        file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
      )
    )
  )
  expect_s3_class(
    validate_submission(hub_path,
      file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
    ),
    c("hub_validations", "list")
  )

  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        round_id_col = "random_col"
      )
    )
  )
})
