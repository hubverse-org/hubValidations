test_that("check_tbl_spl_n works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_spl_n(tbl, round_id, file_path, hub_path)
  )

  tbl_error <- tbl[-which(
    tbl$output_type == "sample" & tbl$output_type_id %in% c("1", "102")
  ), ]

  expect_snapshot(
    check_tbl_spl_n(tbl_error, round_id, file_path, hub_path)
  )
  error_check <- check_tbl_spl_n(
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
  file_path <- "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
  round_id <- "2022-10-22"
  config_task <- hubUtils::read_config_file(
    fs::path(hub_path, "hub-config", "tasks.json")
  )
  compound_taskid_set <- list(
    NULL,
    c("reference_date", "horizon")
  )
  tbl_coarse <- submission_tmpl(
    config_task = config_task,
    round_id = round_id,
    compound_taskid_set = compound_taskid_set
  ) |>
    dplyr::filter(.data$output_type == "sample") |>
    hubData::coerce_to_character()

  # Validation of coarser files should return check failure.
  # Also, because there is a mismatch in compound taskid set, the compound_idx
  # value are inconsistent.
  expect_snapshot(
    str(
      check_tbl_spl_n(tbl_coarse, round_id, file_path, hub_path)
    )
  )

  # Validation providing coarser compound taskid still fails because the coarser
  # structure means the same rows are spread across fewer samples. But the
  # compound_idx values are as expected because the compound_taskid_set matches
  # that used to generate the data.
  expect_snapshot(
    check_tbl_spl_n(tbl_coarse, round_id, file_path, hub_path,
                               compound_taskid_set = compound_taskid_set)
  )
})
