test_that("check_tbl_value_col works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  round_id <- "2022-10-08"

  expect_snapshot(
    check_tbl_value_col(tbl, round_id, file_path, hub_path)
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  round_id <- "2023-05-08"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_value_col(tbl, round_id, file_path, hub_path)
  )
})


test_that("check_tbl_value_col errors correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  round_id <- "2022-10-08"

  tbl$value[1] <- -6
  tbl$value[2] <- "fail"

  expect_snapshot(
    check_tbl_value_col(tbl, round_id, file_path, hub_path)
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  round_id <- "2023-05-08"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl$value[1] <- -6
  tbl$value[2] <- "fail"

  expect_snapshot(
    check_tbl_value_col(tbl, round_id, file_path, hub_path)
  )
})

test_that("Ignoring derived_task_ids in check_tbl_value_col works", {
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
    check_tbl_value_col(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  # Check that ignoring derived task ids returns same result as not ignoring.
  expect_equal(
    check_tbl_value_col(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    ),
    check_tbl_value_col(
      tbl_orig,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
})
