test_that("check_tbl_value_col_sum1 works", {
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "umass-ens/2023-05-08-umass-ens.csv"
  round_id <- "2023-05-08"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  expect_snapshot(
    check_tbl_value_col_sum1(tbl, file_path)
  )
})

test_that("check_tbl_value_col_sum1 errors correctly", {
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "umass-ens/2023-05-08-umass-ens.csv"
  round_id <- "2023-05-08"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  expected <- tibble::tibble(
    forecast_date = as.Date("2023-05-08"),
    horizon = 2L,
    target = "wk flu hosp rate change",
    location = "US",
    output_type = "pmf"
  )

  tbl$value[1] <- 0.1
  res <- check_tbl_value_col_sum1(tbl, file_path)
  expect_snapshot(res)
  expect_check(res, failure_class, file_path, "check_tbl_value_col_sum1")
  expect_equal(res$error_tbl, expected)

  tbl$value[3] <- 0.8
  res <- check_tbl_value_col_sum1(tbl, file_path)
  expect_check(res, failure_class, file_path, "check_tbl_value_col_sum1")
  expect_equal(res$error_tbl, expected)

  tbl$value[1] <- 0.818
  tbl$value[2] <- 0.180
  tbl$value[3] <- 0.002
  res <- check_tbl_value_col_sum1(tbl, file_path)
  expect_snapshot(res)
  expect_check(res, success_class, file_path, "check_tbl_value_col_sum1")
  expect_true("error_tbl" %in% names(res))
  expect_null(res$error_tbl)
})

test_that("check_tbl_value_col_sum1 skips correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_value_col_sum1(tbl, file_path)
  )
})
