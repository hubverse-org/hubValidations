test_that("check_tbl_spl_compound_tid works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_spl_compound_tid(tbl, round_id, file_path, hub_path)
  )

  tbl_error <- tbl
  tbl_error[
    which(tbl$output_type == "sample" & tbl$output_type_id == "1")[1],
    "location"
  ] <- "02"

  expect_snapshot(
    check_tbl_spl_compound_tid(tbl_error, round_id, file_path, hub_path)
  )
  error_check <- check_tbl_spl_compound_tid(
    tbl_error, round_id, file_path, hub_path
  )

  expect_snapshot(error_check$errors)

  # Ensure other checks pass
  expect_s3_class(
    check_tbl_spl_non_compound_tid(tbl_error, round_id, file_path, hub_path),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )
  expect_s3_class(
    check_tbl_spl_compound_tid(tbl_error, round_id, file_path, hub_path),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )
})


test_that("Overriding compound_taskid_set in check_tbl_spl_compound_tid works", {
  hub_path <- test_path("testdata/hub-spl")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  config_task <- hubUtils::read_config_file(
    fs::path(hub_path, "hub-config", "tasks.json")
  )
  compound_taskid_set <- list(
    NULL,
    c("reference_date", "horizon")
  )
  tbl_coarse <- create_spl_file("2022-10-22",
    compound_taskid_set = compound_taskid_set,
    write = FALSE,
    out_datatype = "chr",
    n_samples = 1L
  )

  # Normal validation should return check failure
  expect_snapshot(
    str(
      check_tbl_spl_compound_tid(tbl_coarse, round_id, file_path, hub_path)
    )
  )

  # Validation providing coarser compound taskid set succeeds
  expect_snapshot(
    check_tbl_spl_compound_tid(tbl_coarse, round_id, file_path, hub_path,
      compound_taskid_set = compound_taskid_set
    )

test_that("Ignoring derived_task_ids in check_tbl_spl_compound_tid works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- tbl_orig <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  # Introduce invalid value to derived task id that should be ignored when using
  # `derived_task_ids`.
  tbl[1, "target_end_date"] <- "random_date"
  expect_snapshot(
    check_tbl_spl_compound_tid(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  # Check that ignoring derived task ids returns same result as not ignoring.
  expect_equal(
    check_tbl_spl_compound_tid(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    ),
    check_tbl_spl_compound_tid(tbl_orig, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    )
  )
})
