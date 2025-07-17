test_that("check_target_tbl_oracle_value works", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  #  cloned in `setup.R`
  hub_path <- example_file_hub_path
  target_tbl <- read_target_file("oracle-output.csv", hub_path)
  file_path <- "oracle-output.csv"
  # ---- Check valid data ----
  valid_oo <- check_target_tbl_oracle_value(
    target_tbl,
    target_type = "oracle-output",
    file_path,
    hub_path
  )

  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` contains valid oracle values."
  )
  expect_null(valid_oo$error_tbl)

  # Introducing invalid values causes check to fail ----
  # Add invalid oracle value to pmf output type observation
  target_tbl$oracle_value[target_tbl$output_type == "pmf"][1] <- 2L
  # Add second 1L oracle value to pmf output type observation
  target_tbl$oracle_value[target_tbl$output_type == "pmf"][5] <- 1L
  # Add non-decreasing oracle value to cdf output type observation
  target_tbl$oracle_value[target_tbl$output_type == "cdf"][1] <- 1L

  invalid_oo <- check_target_tbl_oracle_value(
    target_tbl,
    target_type = "oracle-output",
    file_path,
    hub_path
  )

  expect_s3_class(invalid_oo, "check_failure")
  expect_equal(
    cli::ansi_strip(invalid_oo$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` contains invalid oracle values. Invalid `oracle_value` value 2 in \"pmf\" output type detected | \"cdf\" oracle values that violate CDF non-decreasing constrain detected | \"pmf\" oracle values that do not sum to 1 for each observation unit detected | See `error_tbl` for details." # nolint: line_length_linter
  )
  expect_s3_class(invalid_oo$error_df, "tbl_df")
  expect_named(
    invalid_oo$error_df,
    c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
  expect_equal(
    invalid_oo$error_df$output_type_id,
    c(
      "low",
      "0.5",
      "low",
      "moderate",
      "high",
      "very high",
      "low",
      "moderate",
      "high",
      "very high"
    )
  )
  expect_equal(
    invalid_oo$error_df$oracle_value,
    c(2, 0, 1, 1, 0, 0, 2, 0, 0, 0)
  )
  expect_equal(
    unique(invalid_oo$error_df$output_type),
    c("pmf", "cdf")
  )
})

test_that("check_target_tbl_oracle_value skipped for time-series", {
  skip <- check_target_tbl_oracle_value(
    target_tbl = NULL,
    target_type = "time-series",
    file_path = "time-series.csv",
    hub_path
  )
  expect_s3_class(skip, "check_info")
  expect_equal(
    cli::ansi_strip(skip$message) |> stringr::str_squish(),
    "Check not applicable to time-series target data. Skipped."
  )
})

test_that("check_target_tbl_oracle_value skipped when no output type id column present", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  #  cloned in `setup.R`
  hub_path <- example_file_hub_path
  target_tbl <- read_target_file("oracle-output.csv", hub_path)
  file_path <- "oracle-output.csv"
  target_tbl[["output_type_id"]] <- NULL

  skip <- check_target_tbl_oracle_value(
    target_tbl = target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path
  )
  expect_s3_class(skip, "check_info")
  expect_equal(
    cli::ansi_strip(skip$message) |> stringr::str_squish(),
    "Target table does not have `output_type_id` column. Check skipped."
  )
})

test_that("check_target_tbl_oracle_value skipped when no distributional output types present", {
  # Example hub is the hubverse-org/example-complex-forecast-hub on github
  #  cloned in `setup.R`
  hub_path <- example_file_hub_path
  target_tbl <- read_target_file("oracle-output.csv", hub_path)
  file_path <- "oracle-output.csv"
  target_tbl <- target_tbl[
    !target_tbl[["output_type"]] %in% c("pmf", "cdf"),
  ]

  skip <- check_target_tbl_oracle_value(
    target_tbl = target_tbl,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path
  )
  expect_s3_class(skip, "check_info")
  expect_equal(
    cli::ansi_strip(skip$message) |> stringr::str_squish(),
    "Target table does not contain \"cdf\" or \"pmf\" output types. Check skipped."
  )
})
