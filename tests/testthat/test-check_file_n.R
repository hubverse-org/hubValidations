test_that("check_file_n works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.parquet"
  check_file_n(file_path, hub_path)

  expect_s3_class(
    check_file_n(
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      hub_path
    ),
    c("check_success")
  )

  expect_s3_class(
    check_file_n(
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.parquet",
      hub_path
    ),
    c("check_failure")
  )

  expect_snapshot(
    check_file_n(
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.parquet",
      hub_path
    )
  )
})
