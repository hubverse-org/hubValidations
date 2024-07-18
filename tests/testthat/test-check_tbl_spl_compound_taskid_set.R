test_that("check_tbl_spl_compound_taskid_set works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  tbl <- tbl[tbl$output_type == "sample", ] |>
    dplyr::arrange(output_type_id)

  expect_snapshot(
    check_tbl_spl_compound_taskid_set(tbl, round_id, file_path, hub_path)
  )


  ## Test 1 - file with 1 target and all optional horizons and 1 row per sample
  ## where only one is provided.
  ## This should pass validation
  tbl_subset <- tbl[tbl$horizon == 1L, ]

  expect_snapshot(
    check_tbl_spl_compound_taskid_set(tbl_subset, round_id, file_path, hub_path)
  )

  ## Test 2 - file with 1 target and all optional horizons and 1 row per sample
  ##  where more than one horizon is provided across different samples.
  ##  This should fail validation for valid task ids
  tbl_error <- tbl_subset
  tbl_error[
    which(tbl_error$output_type == "sample" & tbl_error$output_type_id == "1")[1],
    "horizon"
  ] <- "2"

  expect_snapshot(
    check_tbl_spl_compound_taskid_set(tbl_error, round_id, file_path, hub_path)
  )
  error_check <- check_tbl_spl_compound_taskid_set(
    tbl_error, round_id, file_path, hub_path
  )
  expect_snapshot(error_check$errors)


  ## Test 3 - Force one sample to have different compound task id set then the rest
  ## of the samples. This should fail validation for more than 1 unique task id set
  ## per modeling task
  tbl_error_dups <- tbl
  tbl_error_dups[which(tbl_error_dups$output_type_id == "2"), "horizon"] <- "0"
  expect_snapshot(
    check_tbl_spl_compound_taskid_set(tbl_error_dups, round_id, file_path, hub_path)
  )

  error_dup_check <- check_tbl_spl_compound_taskid_set(
    tbl_error_dups, round_id, file_path, hub_path
  )
  expect_snapshot(error_dup_check$errors)
})

test_that("Different compound_taskid_sets work", {
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

  tbl_fine <- submission_tmpl(
    config_task = config_task,
    round_id = round_id,
    compound_taskid_set = list(NULL, NULL)
  ) |>
    dplyr::filter(.data$output_type == "sample") |>
    hubData::coerce_to_character()

  # Validation of coarser compound_taskid_set works
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(tbl_coarse, round_id, file_path, hub_path)
    )
  )

  # Validation of finer compound_taskid_set fails
  expect_snapshot(
    check_tbl_spl_compound_taskid_set(tbl_fine, round_id, file_path, hub_path)
  )
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(tbl_fine, round_id, file_path, hub_path)
    )
  )
})
