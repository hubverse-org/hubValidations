test_that("check_target_tbl_coltypes works time-series data", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl <- read_target_file("time-series.csv", hub_path)
  target_type <- "time-series"
  file_path <- "time-series.csv"

  valid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = target_type,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_ts, "check_success")
  expect_equal(
    cli::ansi_strip(valid_ts$message) |> stringr::str_squish(),
    "Column data types match time-series target schema."
  )

  target_tbl$target_end_date <- as.character(target_tbl$target_end_date)

  invalid_ts <- check_target_tbl_coltypes(
    target_tbl,
    target_type = target_type,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(invalid_ts, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column data types do not match time-series target schema. `target_end_date` should be <Date> not <character>." # nolint: line_length_linter
  )
})

test_that("check_target_tbl_coltypes works oracle-output data", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl <- read_target_file("oracle-output.csv", hub_path)
  file_path <- "oracle-output.csv"
  target_type <- "oracle-output"

  valid_oo <- check_target_tbl_coltypes(
    target_tbl,
    target_type = target_type,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "Column data types match oracle-output target schema."
  )

  target_tbl$target_end_date <- as.character(target_tbl$target_end_date)

  invalid_oo <- check_target_tbl_coltypes(
    target_tbl,
    target_type = target_type,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(invalid_oo, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "Column data types do not match oracle-output target schema. `target_end_date` should be <Date> not <character>." # nolint: line_length_linter
  )
})
