test_that("opt_check_tbl_col_timediff works", {
  hub_path <- system.file("testhubs/flusight", package = "hubValidations")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl$target_end_date <- tbl$forecast_date + lubridate::weeks(2)


  expect_snapshot(
    opt_check_tbl_col_timediff(tbl, file_path, hub_path,
      t0_colname = "forecast_date",
      t1_colname = "target_end_date",
      timediff = lubridate::weeks(2)
    )
  )

  tbl_chr <- hubUtils::coerce_to_character(tbl)
  expect_snapshot(
    opt_check_tbl_col_timediff(tbl_chr, file_path, hub_path,
      t0_colname = "forecast_date",
      t1_colname = "target_end_date",
      timediff = lubridate::weeks(2)
    )
  )

  tbl$target_end_date[1] <- tbl$forecast_date[1] + lubridate::weeks(1)
  expect_snapshot(
    opt_check_tbl_col_timediff(tbl, file_path, hub_path,
      t0_colname = "forecast_date",
      t1_colname = "target_end_date",
      timediff = lubridate::weeks(2)
    )
  )
})


test_that("opt_check_tbl_col_timediff fails correctly", {
  hub_path <- system.file("testhubs/flusight", package = "hubValidations")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl$target_end_date <- tbl$forecast_date + lubridate::weeks(2)

  expect_snapshot(
    opt_check_tbl_col_timediff(tbl, file_path, hub_path,
      t0_colname = "forecast_date",
      t1_colname = "target_end_dates",
      timediff = lubridate::weeks(2)
    ),
    error = TRUE
  )

  expect_snapshot(
    opt_check_tbl_col_timediff(tbl, file_path, hub_path,
      t0_colname = "forecast_date",
      t1_colname = c("target_end_date", "forecast_date"),
      timediff = lubridate::weeks(2)
    ),
    error = TRUE
  )

  expect_snapshot(
    opt_check_tbl_col_timediff(tbl, file_path, hub_path,
      t0_colname = "forecast_date",
      t1_colname = "target_end_date",
      timediff = 14L
    ),
    error = TRUE
  )

  schema <- c(
    forecast_date = "Date", target = "character", horizon = "integer",
    location = "character", output_type = "character", output_type_id = "character",
    value = "double", target_end_date = "character"
  )
  mockery::stub(
    opt_check_tbl_col_timediff,
    "hubUtils::create_hub_schema",
    schema,
    2
  )
  expect_snapshot(
    opt_check_tbl_col_timediff(tbl, file_path, hub_path,
      t0_colname = "forecast_date",
      t1_colname = "target_end_date",
      timediff = lubridate::weeks(2)
    ),
    error = TRUE
  )
})
