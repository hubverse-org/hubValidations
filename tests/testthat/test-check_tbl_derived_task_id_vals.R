test_that("check_tbl_derived_task_ids_vals works", {
  hub_path <- system.file("testhubs/v4/flusight", package = "hubUtils")
  file_path <- "hub-baseline/2023-05-08-hub-baseline.parquet"
  round_id <- "2023-05-08"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")

  # Check should succeed
  expect_snapshot(
    check_tbl_derived_task_id_vals(
      tbl, round_id, file_path, hub_path
    )
  )
 # Check should skip
  expect_snapshot(
    check_tbl_derived_task_id_vals(
      tbl, round_id, file_path, hub_path,
      derived_task_ids = NULL
    )
  )

  tbl$target_date <- "random_val"
  # Check should fail
  expect_snapshot(
    check_tbl_derived_task_id_vals(
      tbl, round_id, file_path, hub_path
    )
  )
})
