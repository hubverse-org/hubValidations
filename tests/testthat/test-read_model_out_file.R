test_that("read_model_out_file works", {
  expect_snapshot(
    str(
      read_model_out_file(
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        hub_path = system.file("testhubs/simple", package = "hubValidations")
      )
    )
  )
  expect_snapshot(
    str(
      read_model_out_file(
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        hub_path = system.file("testhubs/simple", package = "hubValidations"),
        use_hub_schema = TRUE
      )
    )
  )
})
