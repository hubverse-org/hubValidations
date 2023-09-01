test_that("validate_model_data works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  expect_snapshot(
    validate_model_data(hub_path, file_path)
  )

  expect_snapshot(
    validate_model_data(hub_path, file_path = "2020-10-06-random-path.csv")
  )

  expect_snapshot(
      validate_model_data(hub_path, file_path, round_id_col = "random_col")
  )

  expect_snapshot(
      validate_model_data(hub_path, file_path)
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  expect_snapshot(
      validate_model_data(hub_path, file_path)
  )
})


test_that("validate_model_data errors correctly", {
    hub_path <- system.file("testhubs/simple", package = "hubValidations")
    file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

    expect_snapshot(
        validate_model_data(hub_path, file_path = "random-path.csv"),
        error = TRUE
    )
})
