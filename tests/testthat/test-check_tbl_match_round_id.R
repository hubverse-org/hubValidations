test_that("check_tbl_match_round_id works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_match_round_id(
      tbl = tbl,
      file_path = file_path,
      hub_path = hub_path
    )
  )
  expect_snapshot(
    str(
      check_tbl_match_round_id(
        tbl = tbl,
        file_path = file_path,
        hub_path = hub_path
      )
    )
  )

  # Supply round_id_col
  expect_snapshot(
    check_tbl_match_round_id(
      tbl = tbl,
      file_path = file_path,
      hub_path = hub_path,
      round_id_col = "origin_date"
    )
  )
})

test_that("check_tbl_match_round_id fails correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "hub-baseline/2022-10-01-hub-baseline.csv"
  tbl <- read_model_out_file(file_path, hub_path)

  # Fails with error when round_id detected in tbl does not match
  # submission round_id
  expect_snapshot(
    check_tbl_match_round_id(
      tbl = read_model_out_file(
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        hub_path
      ),
      file_path = file_path,
      hub_path = hub_path
    )
  )
  # Fails with warning when round_id_col invalid
  expect_snapshot(
    check_tbl_match_round_id(
      tbl = tbl,
      file_path = file_path,
      hub_path = hub_path,
      round_id_col = "random_column"
    )
  )
  expect_snapshot(
    str(
      check_tbl_match_round_id(
        tbl = tbl,
        file_path = file_path,
        hub_path = hub_path,
        round_id_col = "random_column"
      )
    )
  )
})
