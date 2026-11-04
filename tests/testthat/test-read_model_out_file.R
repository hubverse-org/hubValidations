test_that("read_model_out_file works", {
  x <- read_model_out_file(
    file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
    hub_path = system.file("testhubs/simple", package = "hubValidations")
  )
  expect_tbl(
    x,
    n_rows = 47L,
    types = c(
      origin_date = "Date",
      target = "character",
      horizon = "integer",
      location = "character",
      output_type = "character",
      output_type_id = "numeric",
      value = "integer"
    ),
    values = list(
      origin_date = as.Date("2022-10-08"),
      target = "wk inc flu hosp",
      horizon = 1L,
      location = c("02", "US"),
      output_type = c("mean", "quantile"),
      output_type_id = c(hub_quantiles, NA)
    )
  )
  expect_equal(head(x$value), c(135L, 137L, 139L, 140L, 141L, 141L))
})

test_that("read_model_out_file correctly uses hub schema to read character cols in csvs", {
  x <- read_model_out_file(
    hub_path = test_path("testdata/hub"),
    "hub-baseline/2023-04-24-hub-baseline.csv"
  )
  expect_tbl(
    x,
    n_rows = 48L,
    types = c(
      forecast_date = "Date",
      target_end_date = "Date",
      horizon = "integer",
      target = "character",
      location = "character",
      output_type = "character",
      output_type_id = "character",
      value = "numeric"
    ),
    values = list(
      forecast_date = as.Date("2023-04-24"),
      target_end_date = as.Date(c("2023-05-01", "2023-05-08")),
      horizon = 1:2,
      target = "wk ahead inc flu hosp",
      location = "06",
      output_type = c("mean", "quantile"),
      output_type_id = c(as.character(hub_quantiles), NA)
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
