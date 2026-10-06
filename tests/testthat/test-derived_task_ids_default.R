test_that("checks default to the derived task IDs of the round (#395)", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")

  round_ids_seen <- list()
  local_mocked_bindings(
    get_hub_derived_task_ids = function(hub_path, round_id = NULL) {
      round_ids_seen <<- c(round_ids_seen, list(round_id))
      NULL
    }
  )
  check_tbl_spl_compound_taskid_set(tbl, round_id, file_path, hub_path)
  check_tbl_values_required(tbl, round_id, file_path, hub_path)
  # The samples hub has no quantile output, so the ascending check would return
  # before evaluating its default. Use a hub with quantiles for it.
  hub_path_177 <- test_path("testdata/hub-177")
  file_path_177 <- "FluSight-baseline/2024-12-14-FluSight-baseline.parquet"
  check_tbl_value_col_ascending(
    read_model_out_file(file_path_177, hub_path_177, coerce_types = "chr"),
    file_path_177,
    hub_path_177,
    "2024-12-14"
  )

  expect_equal(round_ids_seen, list(round_id, round_id, "2024-12-14"))
})
