test_that("check_tbl_values works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_snapshot(
    check_tbl_values(
      tbl = tbl,
      file_path = file_path,
      hub_path = hub_path
    )
  )

  tbl[1, "horizon"] <- 11L
  expect_snapshot(
    check_tbl_values(
      tbl = tbl,
      file_path = file_path,
      hub_path = hub_path
    )
  )
})
