test_that("check_tbl_unique_round_id works", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  expect_snapshot(
    check_tbl_unique_round_id(
      tbl = arrow::read_csv_arrow(
        system.file("files/2022-10-15-team1-goodmodel.csv",
          package = "hubValidations"
        )
      ),
      round_id_col = "origin_date",
      file_path, hub_path
    )
  )
  expect_snapshot(
    str(check_tbl_unique_round_id(
      tbl = arrow::read_csv_arrow(
        system.file("files/2022-10-15-team1-goodmodel.csv",
          package = "hubValidations"
        )
      ),
      round_id_col = "origin_date",
      file_path, hub_path
    ))
  )
  multiple_rids <- suppressMessages(
    testthis::read_testdata(
      "multiple_rids",
      subdir = "files"
    )
  )
  expect_snapshot(
    check_tbl_unique_round_id(
      tbl = multiple_rids,
      round_id_col = "origin_date",
      file_path, hub_path
    )
  )
})


test_that("check_tbl_unique_round_id works", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  expect_snapshot(
    check_tbl_unique_round_id(
      tbl = testthis::read_testdata(
        "multiple_rids",
        subdir = "files"
      ), round_id_col = "random_column",
      file_path, hub_path
    ),
    error = TRUE
  )
})
