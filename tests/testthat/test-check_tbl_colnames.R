test_that("check_tbl_colnames validates correct files", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  file_path <- "test/file.csv"
  round_id <- "2022-10-15"

  expect_snapshot(
    check_tbl_colnames(tbl = arrow::read_csv_arrow(
      system.file("files/2022-10-15-team1-goodmodel.csv",
        package = "hubValidations"
      )
    ), round_id, file_path, hub_path)
  )
  expect_snapshot(
    check_tbl_colnames(
      tbl = arrow::read_parquet(
        system.file("files/2022-10-15-team1-goodmodel.parquet",
          package = "hubValidations"
        )
      ),
      round_id, file_path, hub_path
    )
  )
})

test_that("check_tbl_colnames fails on files", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "test/file.csv"
  round_id <- "2022-10-15"

  missing_col <- suppressMessages(
    testthis::read_testdata(
      "missing_col",
      subdir = "files"
    )
  )
  expect_snapshot(
    check_tbl_colnames(
      tbl = missing_col,
      round_id, file_path, hub_path
    )
  )
})
