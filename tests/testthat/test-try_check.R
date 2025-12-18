test_that("try_check works", {
  hub_path <- system.file("testhubs/flusight", package = "hubValidations")

  skip_if_offline()
  expect_snapshot(
    try_check(
      check_config_hub_valid(hub_path),
      "test_file.csv"
    )
  )

  expect_snapshot(
    try_check(
      check_config_hub_valid("random_hub"),
      "test_file.csv"
    )
  )

  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  tbl <- read_model_out_file(file_path, hub_path)

  expect_snapshot(
    try_check(
      opt_check_tbl_horizon_timediff(
        tbl,
        file_path,
        hub_path,
        t0_colname = "random_col1",
        t1_colname = "random_col1",
        horizon_colname = "horizon",
        timediff = lubridate::weeks()
      ),
      file_path
    )
  )
})
