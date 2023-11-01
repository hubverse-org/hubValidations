test_that("check_tbl_value_col_sum1 works", {
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "umass_ens/2023-05-08-umass_ens.csv"
  round_id <- "2023-05-08"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  expect_snapshot(
    check_tbl_value_col_sum1(tbl, file_path)
  )
})

test_that("check_tbl_value_col_sum1 errors correctly", {
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "umass_ens/2023-05-08-umass_ens.csv"
  round_id <- "2023-05-08"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl$value[1] <- 0.1
  expect_snapshot(
    str(
      check_tbl_value_col_sum1(tbl, file_path)
    )
  )

  tbl$value[3] <- 0.8
  expect_snapshot(
    str(
      check_tbl_value_col_sum1(tbl, file_path)
    )
  )

  tbl$value[1] <- 0.818
  tbl$value[2] <- 0.180
  tbl$value[3] <- 0.002
  expect_snapshot(
    str(
      check_tbl_value_col_sum1(tbl, file_path)
    )
  )



})

test_that("check_tbl_value_col_sum1 skips correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_value_col_sum1(tbl, file_path)
  )
})
