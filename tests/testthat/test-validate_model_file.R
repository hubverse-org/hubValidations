test_that("validate_model_file works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  # File that passes validation
  res <- validate_model_file(
    hub_path,
    file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  )
  expect_validations(
    res,
    c("hub_validations", "list"),
    file_checks,
    where = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  )
  expect_check(
    res$file_exists,
    success_class,
    where = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
    call = "check_file_exists"
  )
  expect_check(
    res$metadata_exists,
    success_class,
    where = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
    call = "check_submission_metadata_file_exists"
  )

  # File with validation error
  res <- validate_model_file(
    hub_path,
    file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
  )
  expect_validations(
    res,
    c("hub_validations", "list"),
    c(file_exists = "check_error"),
    where = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
  )
})

cli::test_that_cli("validate_model_file print method work", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  # File that passes validation
  expect_snapshot(
    validate_model_file(
      hub_path,
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    )
  )
  # File with validation error
  expect_snapshot(
    validate_model_file(
      hub_path,
      file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
    )
  )
  expect_snapshot(
    validate_model_file(
      hub_path,
      file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv"
    )
  )
})
