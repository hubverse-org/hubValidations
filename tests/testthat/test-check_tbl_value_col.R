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
