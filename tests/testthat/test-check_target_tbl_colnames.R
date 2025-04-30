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

  # Providing a time-series target tbl will throw errors when checking for oracle-output
  # expectations.
  invalid_oo <- check_target_tbl_colnames(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_oo, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for oracle-output target type data. Required column \"oracle_value\" is missing. | Invalid columns \"date\" and \"observation\" detected." # nolint: line_length_linter
  )

  target_tbl <- cbind(target_tbl, value = 0L) |>
    dplyr::select(-"target")

  invalid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for time-series target type data. Required column \"target\" is missing. | Invalid column \"value\" detected." # nolint: line_length_linter
  )
})

test_that("check_target_tbl_colnames works on oracle data", {
  target_tbl <- read_target_file("oracle-output.csv", example_file_hub_path)
  file_path <- "oracle-output.csv"

  valid_oo <- check_target_tbl_colnames(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    example_file_hub_path
  )
  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "Column names are consistent with expected column names for oracle-output target type data."
  )

  # Providing a oracle-output target tbl will throw errors when checking for
  # time-series expectations.
  invalid_ts <- check_target_tbl_colnames(
    target_tbl,
    target_type = "time-series",
    file_path = "time-series.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_ts, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_ts$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for time-series target type data. Required column \"observation\" is missing. | Invalid columns \"output_type\", \"output_type_id\", and \"oracle_value\" detected." # nolint: line_length_linter
  )

  target_tbl <- cbind(target_tbl, value = 0L) |>
    dplyr::select(-"target", -"output_type_id")

  invalid_oo <- check_target_tbl_colnames(
    target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    example_file_hub_path
  )
  expect_s3_class(invalid_oo, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "Column names must be consistent with expected column names for oracle-output target type data. Required columns \"target\" and \"output_type_id\" are missing. | Invalid column \"value\" detected." # nolint: line_length_linter
  )
})
