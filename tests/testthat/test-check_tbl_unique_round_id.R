test_that("check_tbl_unique_round_id works", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")
  hub_con <- hubUtils::connect_hub(hub_path)
  config_tasks <- attr(hub_con, "config_tasks")
  file_path <- "test/file.csv"
  round_id <- "2022-10-15"

  expect_snapshot(
    check_tbl_unique_round_id(
      tbl = arrow::read_csv_arrow(
        system.file("files/2022-10-15-team1-goodmodel.csv",
          package = "hubValidations"
        )
      ),
      round_id_col = "origin_date", file_path
    )
  )
  multiple_rids <- suppressMessages(
    testthis::read_testdata(
      "multiple_rids",
      subdir = "files"
    )
  )
  expect_snapshot(
    check_tbl_unique_round_id(tbl = multiple_rids, round_id_col = "origin_date", file_path)
  )
})


test_that("check_tbl_unique_round_id works", {
  expect_snapshot(
    check_tbl_unique_round_id(tbl = testthis::read_testdata(
      "multiple_rids",
      subdir = "files"
    ), round_id_col = "random_column", file_path),
    error = TRUE
  )
})
