test_that("check_tbl_spl_n works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  # Check succeeds when samples are in range and consistent across all
  # compound_idx
  expect_snapshot(
    check_tbl_spl_n(tbl, round_id, file_path, hub_path)
  )

  # Check failure when sample n not consistent across compound_idx outside ----
  tbl_const_error <- tbl[-which(
    tbl$output_type == "sample" & tbl$output_type_id %in% c("1", "102")
  ), ]

  expect_snapshot(
    check_tbl_spl_n(tbl_const_error, round_id, file_path, hub_path)
  )

  const_error_check <- check_tbl_spl_n(
    tbl_const_error, round_id, file_path, hub_path
  )

  expect_snapshot(const_error_check$errors)

  # Ensure other checks pass
  expect_s3_class(
    check_tbl_spl_non_compound_tid(
      tbl_const_error, round_id,
      file_path, hub_path
    ),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )
  expect_s3_class(
    check_tbl_spl_compound_tid(
      tbl_const_error, round_id,
      file_path, hub_path
    ),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )


  # Check failure when all compound_idx outside range ----
  tbl_min_error <- tbl[-which(
    tbl$output_type == "sample" & tbl$output_type_id %in% c(
      "1", "102", "201", "301", "5201"
    )
  ), ]

  expect_snapshot(
    check_tbl_spl_n(tbl_min_error, round_id, file_path, hub_path)
  )

  min_error_check <- check_tbl_spl_n(
    tbl_min_error, round_id, file_path, hub_path
  )

  expect_snapshot(min_error_check$errors)
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
      compound_taskid_set = compound_taskid_set
    )
  )

  # Create 100 spls of each compound idx
  tbl_full <- create_spl_file("2022-10-22",
    compound_taskid_set = compound_taskid_set,
    write = FALSE,
    out_datatype = "chr"
  )

  # This succeeds!
  expect_snapshot(
    check_tbl_spl_n(tbl_full, round_id, file_path, hub_path,
      compound_taskid_set = compound_taskid_set
    )
  )

  # If we remove one sample, the check will fail because of an inconsistent
  # number of samples per compound_idx (Most will have 100 but one will only
  # have 99)
  tbl_minus_1 <- tbl_full[-which(
    tbl_full$output_type_id == "1"
  ), ]
  expect_snapshot(
    check_tbl_spl_n(tbl_minus_1, round_id, file_path, hub_path,
      compound_taskid_set = compound_taskid_set
    )
  )
})
