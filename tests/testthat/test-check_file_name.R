test_that("check_file_name works when file name valid", {
  expect_snapshot(
    check_file_name(
      "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    )
  )
  expect_snapshot(
    check_file_name(
      "team1-goodmodel/2022-10-08-team1-good_model.csv"
    )
  )
  expect_snapshot(
    check_file_name(
      "team1-goodmodel/round_1-team1-goodmodel.parquet"
    )
  )
})

test_that("check_file_name works when file name fails", {
  expect_snapshot(
    check_file_name(
      "team1-goodmodel/2022-10-08-team1_goodmodel.csv"
    )
  )
  expect_snapshot(
    check_file_name(
      "team1-goodmodel/round_1-team1-good-model.parquet"
    )
  )
})
