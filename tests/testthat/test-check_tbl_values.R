test_that("check_tbl_values works", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  file_path_10_08 <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl_10_08 <- read_model_out_file(
    file_path = file_path_10_08,
    hub_path = hub_path
  )
  expect_snapshot(
    check_tbl_values(
      tbl = tbl_10_08,
      file_path = file_path_10_08,
      hub_path = hub_path
    )
  )
})
