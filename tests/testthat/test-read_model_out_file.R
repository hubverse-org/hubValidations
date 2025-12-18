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
        hub_path = system.file("testhubs/simple", package = "hubValidations")
      )
    )
  )
})

test_that("read_model_out_file correctly uses hub schema to read character cols in csvs", {
  expect_snapshot(
    str(
      read_model_out_file(
        hub_path = test_path("testdata/hub"),
        "hub-baseline/2023-04-24-hub-baseline.csv"
      )
    )
  )
})
test_that("read_model_out_file errors when file contents cannot be coerced to hub schema.", {
  expect_error(
    read_model_out_file(
      hub_path = test_path("testdata/hub"),
      "hub-baseline/2023-05-01-hub-baseline.csv"
    ),
    regexp = "* CSV conversion error to int32: invalid value 'horizon 1'"
  )
})
