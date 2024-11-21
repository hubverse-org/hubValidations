test_that("check_tbl_col_types works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_col_types(tbl, file_path, hub_path)
  )
  local_mocked_bindings(
    create_hub_schema = function(...) {
      c(
        origin_date = "character", target = "character", horizon = "double",
        location = "character", age_group = "character", output_type = "character",
        output_type_id = "double", value = "integer"
      )
    }
  )
  expect_snapshot(
    check_tbl_col_types(tbl, file_path, hub_path)
  )
})

test_that(
  "Check '06' location value validated correctly in check_tbl_col_types",
  {
    hub_path <- test_path("testdata/hub")
    file_path <- "hub-baseline/2023-04-24-hub-baseline.csv"
    tbl <- read_model_out_file(
      file_path,
      hub_path
    )
    expect_snapshot(
      check_tbl_col_types(tbl, file_path, hub_path)
    )
  }
)

test_that("check_tbl_col_types on datetimes doesn't cause exec error", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- read_model_out_file(file_path, hub_path)
  tbl$origin_date <- as.POSIXct(tbl$origin_date)

  # Should return a check_failure not an exec error
  expect_snapshot(
    check_tbl_col_types(tbl, file_path, hub_path)
  )
})
