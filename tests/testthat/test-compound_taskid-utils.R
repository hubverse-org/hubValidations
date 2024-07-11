test_that("get_tbl_compound_taskid_set works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  config_tasks <- hubUtils::read_config(hub_path, "tasks")


  expect_snapshot(
    get_tbl_compound_taskid_set(tbl, config_tasks, round_id,
                                compact = TRUE, error = TRUE)
  )

  expect_snapshot(
    get_tbl_compound_taskid_set(tbl, config_tasks, round_id,
                                compact = FALSE, error = TRUE)
  )

})

test_that("get_tbl_compound_taskid_set errors correctly", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
  round_id <- "2022-10-22"
  tbl_error_dups <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  tbl_error_dups[which(tbl_error_dups$output_type_id == "2"), "horizon"] <- "0"
  expect_snapshot(
    get_tbl_compound_taskid_set(tbl_error_dups, config_tasks, round_id,
                                compact = TRUE, error = TRUE),
    error = TRUE
  )

  expect_snapshot(
    get_tbl_compound_taskid_set(tbl_error_dups, config_tasks, round_id,
                                compact = TRUE, error = FALSE)
  )

})
