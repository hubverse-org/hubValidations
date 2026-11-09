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
    ),
    unchecked = "value"
  )
  expect_equal(
    x[c(1, 23, 24, 47), c("location", "output_type", "output_type_id")],
    tibble::tibble(
      location = c("US", "US", "02", "02"),
      output_type = c("quantile", "quantile", "quantile", "mean"),
      output_type_id = c(0.01, 0.99, 0.01, NA)
    )
  )
  # fmt: skip
  expect_equal(x$value, c(
    135L, 137L, 139L, 140L, 141L, 141L, 142L, 143L, 144L, 145L, 147L, 148L,
    149L, 150L, 152L, 155L, 161L, 165L, 170L, 175L, 176L, 176L, 205L, 123L,
    130L, 135L, 141L, 146L, 149L, 152L, 154L, 157L, 159L, 161L, 163L, 165L,
    168L, 170L, 172L, 175L, 178L, 181L, 185L, 191L, 197L, 203L, 173L
  ))
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
      target = "wk ahead inc flu hosp",
      location = "06",
      output_type_id = c(as.character(hub_quantiles), NA)
    ),
    counts = tibble::tibble(
      horizon = c(1L, 1L, 2L, 2L),
      target_end_date = as.Date(
        c("2023-05-01", "2023-05-01", "2023-05-08", "2023-05-08")
      ),
      output_type = c("mean", "quantile", "mean", "quantile"),
      n = c(1L, 23L, 1L, 23L)
    ),
    unchecked = "value"
  )
  expect_equal(x$output_type_id[1:4], c(NA, NA, "0.01", "0.025"))
  # fmt: skip
  expect_equal(x$value, c(
    1033, 1033, 0, 0, 0, 281, 600, 717, 817, 877, 913, 965, 1011, 1033, 1055,
    1101, 1153, 1189, 1249, 1349, 1466, 1785, 3443, 5183, 7490, 0, 0, 0, 0, 0,
    378, 579, 706, 806, 887, 963, 1033, 1102, 1179, 1262, 1363, 1489, 1690,
    2387, 3348, 5048, 7471, 8402
  ))
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
