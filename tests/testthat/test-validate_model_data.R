test_that("validate_model_data works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  expect_snapshot(
    str(
      validate_model_data(hub_path, file_path)
    )
  )
  expect_s3_class(
    validate_model_data(hub_path, file_path),
    c("hub_validations", "list")
  )

  expect_snapshot(
    str(
      validate_model_data(hub_path, file_path = "2020-10-06-random-path.csv")
    )
  )

  expect_snapshot(
    str(
      validate_model_data(hub_path, file_path, round_id_col = "random_col")
    )
  )



  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  expect_snapshot(
    str(
      validate_model_data(hub_path, file_path)
    )
  )
})


test_that("validate_model_data with config function works", {
  hub_path <- system.file("testhubs/flusight", package = "hubValidations")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  expect_snapshot(
    validate_model_data(hub_path, file_path)[["horizon_timediff"]]
  )
  expect_snapshot(
    validate_model_data(
      hub_path, file_path,
      validations_cfg_path = system.file(
        "testhubs/flusight/hub-config/validations.yml",
        package = "hubValidations"
      )
    )[["horizon_timediff"]]
  )
})


cli::test_that_cli("validate_model_data print method work", {
  mockery::stub(
    octolog:::signal_github_condition,
    "get_location_string",
    "file=test-validate_model_data.R,line=57,endLine=61,col=3,endCol=3",
    2
  )
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  withr::local_envvar(GITHUB_ACTIONS = "false")

  # File that passes validation
  expect_snapshot(
    validate_model_data(hub_path, file_path)
  )
  # File with validation error
  validate_model_data(hub_path, file_path, round_id_col = "random_col")

  withr::local_envvar(GITHUB_ACTIONS = "true")
  # File that passes validation
  expect_snapshot(
    validate_model_data(hub_path, file_path)
  )
  # File with validation error
  validate_model_data(hub_path, file_path, round_id_col = "random_col")
})


test_that("validate_model_data errors correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  expect_snapshot(
    validate_model_data(hub_path, file_path = "random-path.csv"),
    error = TRUE
  )
})

test_that("validate_model_data with v3 sample data works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
  expect_snapshot(
    str(
      validate_model_data(
        hub_path, file_path,
        validations_cfg_path = system.file(
          "testhubs/flusight/hub-config/validations.yml",
          package = "hubValidations"
        )
      )
    )
  )
})
