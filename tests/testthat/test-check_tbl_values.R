test_that("check_tbl_values works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  round_id <- "2022-10-08"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )

  tbl[1, "horizon"] <- "11"
  expect_snapshot(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )
})


test_that("check_tbl_values consistent across numeric & character output type id columns & does not ignore trailing zeros", {
  # nolint: line_length_linter
  # Hub with both character & numeric output type ids & trailing zeros in
  # numeric output type id
  hub_path <- test_path("testdata/hub-chr")
  # File with both character & numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` as well as by `arrow::cast`.
  # Also contains trailing zeros.
  file_path <- "UMass-gbq/2023-10-28-UMass-gbq.csv"
  round_id <- "2023-10-28"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` as well as by `arrow::cast`.
  file_path <- "UMass-gbq/2023-11-04-UMass-gbq.csv"
  round_id <- "2023-11-04"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  file_path <- "UMass-gbq/2023-11-11-UMass-gbq.csv"
  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` but not by `arrow::cast`
  round_id <- "2023-11-11"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  # Hub with only numeric output type ids ----
  hub_path <- test_path("testdata/hub-num")
  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` as well as by `arrow::cast`.
  file_path <- "UMass-gbq/2023-11-04-UMass-gbq.csv"
  round_id <- "2023-11-04"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` as well as by `arrow::cast`.
  # Also contains trailing zeros
  file_path <- "UMass-gbq/2023-10-28-UMass-gbq.csv"
  round_id <- "2023-10-28"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` but not by `arrow::cast`
  file_path <- "UMass-gbq/2023-11-11-UMass-gbq.csv"
  round_id <- "2023-11-11"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )
})

test_that("check_tbl_values works with v3 spec samples", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )

  tbl[utils::head(which(tbl$output_type == "sample"), 2), "horizon"] <- c(
    "11",
    "12"
  )
  expect_snapshot(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )
})


test_that("Ignoring derived_task_ids in check_tbl_values works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- tbl_orig <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  # Introduce invalid value to derived task id that should be ignored when using
  # `derived_task_ids`.
  tbl[1, "target_end_date"] <- "random_date"
  expect_snapshot(
    check_tbl_values(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  # Check that ignoring derived task ids returns same result as not ignoring.
  expect_equal(
    check_tbl_values(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    ),
    check_tbl_values(
      tbl_orig,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )

  # Trigger invalid value error
  tbl[1, "horizon"] <- tbl_orig[1, "horizon"] <- "9"
  # Trigger invalid value combination error
  tbl[2, "output_type"] <- tbl_orig[2, "output_type"] <- "pmf"
  expect_snapshot(
    check_tbl_values(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  expect_snapshot(
    check_tbl_values(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )$error_tbl
  )

  expect_equal(
    check_tbl_values(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    ),
    check_tbl_values(
      tbl_orig,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
})
