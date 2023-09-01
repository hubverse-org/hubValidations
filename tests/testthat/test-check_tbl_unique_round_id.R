test_that("check_tbl_unique_round_id works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  expect_snapshot(
    check_tbl_unique_round_id(
      tbl = arrow::read_csv_arrow(
        system.file("files/2022-10-15-team1-goodmodel.csv",
          package = "hubValidations"
        )
      ),
      file_path = file_path,
      hub_path = hub_path
    )
  )
  expect_snapshot(
    check_tbl_unique_round_id(
      tbl = arrow::read_csv_arrow(
        system.file("files/2022-10-15-team1-goodmodel.csv",
                    package = "hubValidations"
        )
      ),
      file_path = file_path, hub_path = hub_path,
      round_id_col = "origin_date"
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
      file_path = file_path,
      hub_path = hub_path
    ))
  )
})


test_that("check_tbl_unique_round_id fails correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  multiple_rids <- suppressMessages(
    testthis::read_testdata(
      "multiple_rids",
      subdir = "files"
    )
  )
  # Fails with error when more than one unique round_id detected in tbl
  expect_snapshot(
    check_tbl_unique_round_id(
      tbl = multiple_rids,
      file_path = file_path,
      hub_path = hub_path
    )
  )
  # Fails with warning when round_id_col invalid
  expect_snapshot(
    check_tbl_unique_round_id(
      tbl = multiple_rids,
      file_path = file_path,
      hub_path = hub_path,
      round_id_col = "random_column"
    )
  )
})
