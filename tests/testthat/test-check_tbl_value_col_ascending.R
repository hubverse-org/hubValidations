test_that("check_tbl_value_col_ascending works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_value_col_ascending(tbl, file_path)
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_value_col_ascending(tbl, file_path)
  )
})

test_that("check_tbl_value_col_ascending works when output type IDs not ordered", {
  tbl <- arrow::read_csv_arrow(
    test_path("testdata/files/2024-01-10-ISI-NotOrdered.csv")
  ) %>%
    hubData::coerce_to_character()
  file_path <- "ISI-NotOrdered/2024-01-10-ISI-NotOrdered.csv"
  expect_snapshot(
    check_tbl_value_col_ascending(tbl, file_path)
  )
})

test_that("check_tbl_value_col_ascending errors correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  tbl$value[c(1, 10)] <- 150

  expect_snapshot(
    str(check_tbl_value_col_ascending(tbl, file_path))
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl_error <- tbl
  tbl_error$target <- "wk ahead inc covid hosp"
  tbl_error$value[1] <- 800

  expect_snapshot(
    str(
      check_tbl_value_col_ascending(tbl_error, file_path)
    )
  )
  expect_snapshot(
    str(
      check_tbl_value_col_ascending(
        rbind(tbl, tbl_error),
        file_path
      )
    )
  )
})

test_that("check_tbl_value_col_ascending skips correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl <- tbl[tbl$output_type == "mean", ]

  expect_snapshot(
    check_tbl_value_col_ascending(tbl, file_path)
  )
})


test_that("(#78) check_tbl_value_col_ascending handle cdf char values", {

  file_path <- test_path("testdata/files/2024-08-12-cdf-ascent.csv")
  ex <- arrow::read_csv_arrow(file_path)

  res <- hubValidations:::check_tbl_value_col_ascending(ex, file_path = "")
  expect_s3_class(res, "check_success")
  expect_null(res$error_tbl)
})
