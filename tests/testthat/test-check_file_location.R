test_that("check_file_location works", {
  expect_snapshot(
    check_file_location("team1-goodmodel/2022-10-08-team1-goodmodel.csv")
  )
  expect_snapshot(
    check_file_location("team1-goodmodel/2022-10-08-team2-goodmodel.csv")
  )
})
