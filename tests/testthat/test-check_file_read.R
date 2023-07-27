test_that("check_file_read works", {
  hub_path <- system.file("testhubs/simple", package = "hubUtils")

  expect_snapshot(
    check_file_read(
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      hub_path = hub_path
    )
  )
  expect_s3_class(
    check_file_read(
      file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition")
  )
})
