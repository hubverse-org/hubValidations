test_that("check_tbl_col_types works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  tbl <- read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_col_types(tbl, file_path, hub_path)
  )

  mockery::stub(
    check_tbl_col_types,
    "hubUtils::create_hub_schema",
    c(
      origin_date = "character", target = "character", horizon = "double",
      location = "character", age_group = "character", output_type = "character",
      output_type_id = "double", value = "integer"
    ),
    1
  )
  expect_snapshot(
    check_tbl_col_types(tbl, file_path, hub_path)
  )

  # Check "06" location value read and validated correctly
  hub_path <- test_path("testdata/hub")
  file_path <- "hub-baseline/2023-04-24-hub-baseline.csv"
  tbl <- read_model_out_file(file_path,
    hub_path
  )
  expect_snapshot(
    check_tbl_col_types(tbl, file_path, hub_path)
  )
})
