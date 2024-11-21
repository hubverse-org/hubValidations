test_that("match_tbl_to_model_task works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  tbl <- read_model_out_file(
    file_path = "flu-base/2022-10-22-flu-base.csv",
    hub_path, coerce_types = "chr"
  )
  config_tasks <- read_config(hub_path, "tasks")

  expect_snapshot(
    match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22")
  )
  expect_snapshot(
    match_tbl_to_model_task(tbl, config_tasks,
      round_id = "2022-10-22",
      output_types = "sample"
    )
  )
})
