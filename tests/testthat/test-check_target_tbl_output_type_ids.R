test_that("check_target_tbl_output_type_ids works", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  #  cloned in `setup.R`
  hub_path <- example_file_hub_path
  target_tbl_chr <- read_target_file("oracle-output.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "oracle-output.csv"
  # ---- Check valid data ----
  valid_oo <- check_target_tbl_output_type_ids(
    target_tbl_chr,
    file_path, hub_path
  )

  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` contains valid complete output_type_id values."
  )
  expect_null(valid_oo$error_tbl)

  # Introducing invalid values causes check to fail ----
  # Add random output type ID to pmf output type
  target_tbl_chr$output_type_id[target_tbl_chr$output_type == "pmf"][1] <- "random"
  # Add non-NAs to quantile output type
  target_tbl_chr$output_type_id[target_tbl_chr$output_type == "quantile"][1] <- "random"
  invalid_oo <- check_target_tbl_output_type_ids(
    target_tbl_chr,
    file_path, hub_path
  )

  expect_s3_class(invalid_oo, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` does not contain valid complete output_type_id values. Non-`NA` output type ID values detected for output type \"quantile\". | Missing output type ID values detected for output type \"pmf\". See `missing` for details." # nolint: line_length_linter
  )
  expect_s3_class(invalid_oo$missing, "tbl_df")
  expect_named(
    invalid_oo$missing,
    c("location", "target_end_date", "target", "output_type", "output_type_id")
  )
  expect_equal(
    invalid_oo$missing$output_type_id,
    "low"
  )
  expect_equal(
    invalid_oo$missing$target,
    "wk flu hosp rate category"
  )
  expect_equal(
    invalid_oo$missing$output_type,
    "pmf"
  )

  # Remove row with error. Should get the same output given we're interested in
  # completeness of output type IDs
  missing_row_tbl <- target_tbl_chr[-which(target_tbl_chr$output_type == "pmf")[1], ]
  missing_oo <- check_target_tbl_output_type_ids(
    target_tbl_chr,
    file_path, hub_path
  )
  expect_equal(missing_oo, invalid_oo)
})
