test_that("check_target_tbl_output_type_ids works", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl_chr <- read_target_file("oracle-output.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "oracle-output.csv"
  # ---- Check valid data ----
  valid_oo <- check_target_tbl_output_type_ids(
    target_tbl_chr,
    target_type = "oracle-output",
    file_path,
    hub_path
  )

  expect_s3_class(valid_oo, "check_success")
  expect_equal(
    cli::ansi_strip(valid_oo$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` contains valid complete output_type_id values."
  )
  expect_null(valid_oo$missing)

  # Introducing invalid values causes check to fail ----
  # Add random output type ID to pmf output type
  target_tbl_chr$output_type_id[target_tbl_chr$output_type == "pmf"][
    1
  ] <- "random"
  # Add non-NAs to quantile output type
  target_tbl_chr$output_type_id[target_tbl_chr$output_type == "quantile"][
    1
  ] <- "random"
  invalid_oo <- check_target_tbl_output_type_ids(
    target_tbl_chr,
    target_type = "oracle-output",
    file_path,
    hub_path
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
  missing_row_tbl <- target_tbl_chr[
    -which(
      target_tbl_chr$output_type == "pmf"
    )[1],
  ]
  missing_oo <- check_target_tbl_output_type_ids(
    target_tbl_chr,
    target_type = "oracle-output",
    file_path,
    hub_path
  )
  expect_equal(missing_oo, invalid_oo)
})

test_that("check_target_tbl_output_type_ids works with NULL target_keys", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl_chr <- read_target_file("oracle-output.csv", hub_path) |>
    hubData::coerce_to_character()
  target_tbl_chr[["targets"]] <- NULL
  file_path <- "oracle-output.csv"

  # restrict to first round and model task 3 ("wk inc flu hosp" target)
  non_dist_config_tasks <- mock_global_target_config(
    categorical = FALSE,
    hub_path = hub_path
  )
  non_dist_tbl <- target_tbl_chr |>
    dplyr::filter(output_type %in% c("quantile", "mean"))
  # restrict to first round and model task 1 (target "wk flu hosp rate category")
  dist_config_tasks <- mock_global_target_config(
    categorical = TRUE,
    hub_path = hub_path
  )
  dist_tbl <- target_tbl_chr |>
    dplyr::filter(output_type == "pmf")

  local_mocked_bindings(
    read_config = function(hub_path) {
      non_dist_config_tasks
    }
  )

  valid_non_dist <- check_target_tbl_output_type_ids(
    target_tbl_chr = non_dist_tbl,
    target_type = "oracle-output",
    file_path,
    hub_path
  )
  expect_s3_class(valid_non_dist, "check_success")
  expect_equal(
    cli::ansi_strip(valid_non_dist$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` contains valid complete output_type_id values."
  )
  expect_null(valid_non_dist$missing)

  # Check invalid non-distributional output types ----
  non_dist_tbl$output_type_id[1] <- "random"
  non_dist_tbl[
    non_dist_tbl$output_type == "mean",
  ]$output_type_id[1] <- "random"

  invalid_non_dist <- check_target_tbl_output_type_ids(
    target_tbl_chr = non_dist_tbl,
    target_type = "oracle-output",
    file_path,
    hub_path
  )
  expect_s3_class(invalid_non_dist, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_non_dist$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` does not contain valid complete output_type_id values. Non-`NA` output type ID values detected for output types \"quantile\" and \"mean\"." # nolint: line_length_linter
  )
  expect_null(invalid_non_dist$missing)

  # Distributional (pmf) output type IDs checks ----
  local_mocked_bindings(
    read_config = function(hub_path) {
      dist_config_tasks
    }
  )
  valid_dist <- check_target_tbl_output_type_ids(
    target_tbl_chr = dist_tbl,
    target_type = "oracle-output",
    file_path,
    hub_path
  )
  expect_s3_class(valid_dist, "check_success")
  expect_equal(
    cli::ansi_strip(valid_dist$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` contains valid complete output_type_id values."
  )
  expect_null(valid_dist$missing)

  # Check invalid distributional output types ----
  dist_tbl$output_type_id[1] <- "random"

  invalid_dist <- check_target_tbl_output_type_ids(
    target_tbl_chr = dist_tbl,
    target_type = "oracle-output",
    file_path,
    hub_path
  )
  expect_s3_class(invalid_dist, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_dist$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` does not contain valid complete output_type_id values. Missing output type ID values detected for output type \"pmf\". See `missing` for details." # nolint: line_length_linter
  )
  expect_s3_class(invalid_dist$missing, "tbl_df")
  expect_named(
    invalid_dist$missing,
    c("location", "target_end_date", "output_type", "output_type_id")
  )
  expect_equal(
    invalid_dist$missing$output_type_id,
    "low"
  )
  expect_equal(
    invalid_dist$missing$output_type,
    "pmf"
  )
})

test_that("check_target_tbl_output_type_ids skipped for time-series", {
  skip <- check_target_tbl_output_type_ids(
    target_tbl_chr = NULL,
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

test_that("check_target_tbl_output_type_ids works with 2 dist targets", {
  hub_path <- system.file(
    "testhubs/v5/target_file",
    package = "hubUtils"
  )
  target_tbl_chr <- read_target_file("oracle-output.csv", hub_path) |>
    hubData::coerce_to_character()
  file_path <- "oracle-output.csv"

  target_tbl_chr <- target_tbl_chr[target_tbl_chr$output_type == "pmf", ]
  dist_2_tbl <- rbind(
    target_tbl_chr,
    dplyr::mutate(
      target_tbl_chr,
      target = "wk flu death rate category"
    )
  )

  # restrict to first round and model task 3 with an added
  # "wk flu death rate category" target
  dist_2_config_tasks <- mock_global_2_target_config(
    hub_path = hub_path
  )
  local_mocked_bindings(
    read_config = function(hub_path) {
      dist_2_config_tasks
    }
  )
  valid_dist_2 <- check_target_tbl_output_type_ids(
    target_tbl_chr = dist_2_tbl,
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(valid_dist_2, "check_success")
  expect_equal(
    cli::ansi_strip(valid_dist_2$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` contains valid complete output_type_id values."
  )
  expect_null(valid_dist_2$error_tbl)

  dist_2_tbl$output_type_id[1] <- "random"
  dist_2_tbl[
    dist_2_tbl$target == "wk flu death rate category",
  ]$output_type_id[1] <- "random"
  invalid_dist_2 <- check_target_tbl_output_type_ids(
    target_tbl_chr = dist_2_tbl,
    target_type = "oracle-output",
    file_path,
    hub_path
  )
  expect_s3_class(invalid_dist_2, "check_error")
  expect_equal(
    cli::ansi_strip(invalid_dist_2$message) |> stringr::str_squish(),
    "oracle-output `target_tbl` does not contain valid complete output_type_id values. Missing output type ID values detected for output type \"pmf\". See `missing` for details." # nolint: line_length_linter
  )

  expect_s3_class(invalid_dist_2$missing, "tbl_df")
  expect_named(
    invalid_dist_2$missing,
    c("location", "target_end_date", "target", "output_type", "output_type_id")
  )
  expect_equal(
    unique(invalid_dist_2$missing$output_type_id),
    "low"
  )
  expect_equal(
    sort(invalid_dist_2$missing$target),
    c("wk flu death rate category", "wk flu hosp rate category")
  )
  expect_equal(
    unique(invalid_dist_2$missing$output_type),
    "pmf"
  )
})

# v6 config-based validation ----
test_that("check_target_tbl_output_type_ids works with v6 config", {
  skip_if_not_installed("hubUtils", minimum_version = "0.1.0")

  hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")
  config_target_data <- hubUtils::read_config(hub_path, "target-data")

  # Valid oracle-output
  target_tbl <- read_target_file("oracle-output.csv", hub_path)
  target_tbl_chr <- hubData::coerce_to_character(target_tbl)

  valid_oo <- check_target_tbl_output_type_ids(
    target_tbl_chr,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path = hub_path,
    config_target_data = config_target_data
  )
  expect_s3_class(valid_oo, "check_success")

  # Invalid oracle-output - remove some output_type_id rows to create incomplete set
  target_tbl_incomplete <- target_tbl[-(1:10), ] # Remove first 10 rows
  target_tbl_incomplete_chr <- hubData::coerce_to_character(
    target_tbl_incomplete
  )

  invalid_oo <- check_target_tbl_output_type_ids(
    target_tbl_incomplete_chr,
    target_type = "oracle-output",
    file_path = "oracle-output.csv",
    hub_path = hub_path,
    config_target_data = config_target_data
  )
  expect_s3_class(invalid_oo, "check_error")
})
