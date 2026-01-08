test_that("check_valid_round_id_col works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- arrow::read_csv_arrow(
    system.file(
      "files/2022-10-15-team1-goodmodel.csv",
      package = "hubValidations"
    )
  )
  expect_snapshot(
    check_valid_round_id_col(
      tbl = tbl,
      file_path = file_path,
      hub_path = hub_path
    )
  )
  expect_snapshot(
    str(
      check_valid_round_id_col(
        tbl = tbl,
        file_path = file_path,
        hub_path = hub_path
      )
    )
  )
  expect_snapshot(
    check_valid_round_id_col(
      tbl = tbl,
      file_path = file_path,
      hub_path = hub_path,
      round_id_col = "origin_date"
    )
  )
  expect_snapshot(
    str(check_valid_round_id_col(
      tbl = tbl,
      round_id_col = "origin_date",
      file_path = file_path,
      hub_path = hub_path
    ))
  )

  # Fails with warning when round_id_col invalid
  expect_snapshot(
    check_valid_round_id_col(
      tbl = tbl,
      file_path = file_path,
      hub_path = hub_path,
      round_id_col = "random_column"
    )
  )
})
