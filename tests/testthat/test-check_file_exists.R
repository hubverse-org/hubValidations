test_that("check_file_exists works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  expect_s3_class(
    check_file_exists(file_path, hub_path),
    c("check_success")
  )

  file_path <- "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
  expect_s3_class(
    check_file_exists(file_path, hub_path),
    c("check_error")
  )

  expect_error(
    check_file_exists(file_path, hub_path = "random_path")
  )
})
