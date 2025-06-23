test_that("check_target_tbl_colnames works on time-series data", {
  target_tbl <- read_target_file("time-series.csv", example_file_hub_path)
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column names are consistent with expected column names for time-series target type data."
  )


})
