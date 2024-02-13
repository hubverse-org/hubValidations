test_that("check_tbl_rows_unique works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  expect_snapshot(
    check_tbl_rows_unique(tbl, file_path, hub_path)
  )
  expect_snapshot(
    check_tbl_rows_unique(rbind(tbl, tbl[c(5, 9), ]), file_path, hub_path)
  )
})
