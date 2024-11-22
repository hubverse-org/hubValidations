test_that("check_tbl_spl_compound_taskid_set works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
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

  # Read in test files
  tbl_coarse_location <- read_model_out_file(
    file_path = create_file_path("2022-10-29"),
    hub_path = hub_path, coerce_types = "chr"
  )
  tbl_coarse_horizon <- read_model_out_file(
    file_path = create_file_path("2022-11-05"),
    hub_path = hub_path, coerce_types = "chr"
  )


  # Validation of coarser compound_taskid_set works
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_coarse_location, "2022-10-29",
        create_file_path("2022-10-29"), hub_path
      )
    )
  )
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_coarse_horizon,
        "2022-11-05", create_file_path("2022-11-05"), hub_path
      )
    )
  )

  # Mock the config file to include all task ids a derived task id depends on
  #  in the compound_taskid_set but exclude the derived task id itself.
  #  Currently will fail
  config_tasks_full_ctids <- purrr::modify_in(
    hubUtils::read_config_file(
      fs::path(hub_path, "hub-config", "tasks.json")
    ),
    list(
      "rounds", 1, "model_tasks", 2,
      "output_type", "sample",
      "output_type_id_params", "compound_taskid_set"
    ),
    ~ c("reference_date", "horizon", "location", "variant")
  )
  local_mocked_bindings(
    read_config = function(...) config_tasks_full_ctids
  )
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_coarse_horizon,
        "2022-11-05", create_file_path("2022-11-05"), hub_path
      )
    )
  )
  # Specifying the derived task IDs allows validation to pass and excludes derived
  # task IDs from the compound_taskid_set
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_coarse_horizon,
        "2022-11-05", create_file_path("2022-11-05"), hub_path,
        derived_task_ids = "target_end_date"
      )
    )
  )
})

test_that("Finer compound_taskid_sets work", {
  hub_path <- test_path("testdata/hub-spl")
  # Mock the config file to remove variant from compound_taskid_set
  # Then test against file created with full compound_taskid_set (i.e. finest
  # sample structure possible). Test should fail
  config_tasks_no_variant <- purrr::modify_in(
    hubUtils::read_config_file(
      fs::path(hub_path, "hub-config", "tasks.json")
    ),
    list(
      "rounds", 1, "model_tasks", 2,
      "output_type", "sample",
      "output_type_id_params", "compound_taskid_set"
    ),
    ~ c("reference_date", "horizon", "location", "target_end_date")
  )
  local_mocked_bindings(
    read_config = function(...) config_tasks_no_variant
  )
  tbl_fine <- create_spl_file("2022-10-22",
    compound_taskid_set = list(NULL, NULL),
    write = FALSE, out_datatype = "chr"
  )

  # Validation of finer compound_taskid_set fails
  expect_snapshot(
    check_tbl_spl_compound_taskid_set(
      tbl_fine, "2022-10-22",
      create_file_path("2022-10-22"),
      test_path("testdata/hub-spl")
    )
  )
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_fine, "2022-10-22",
        create_file_path("2022-10-22"),
        test_path("testdata/hub-spl")
      )
    )
  )
})

test_that("Ignoring derived_task_ids in check_tbl_spl_compound_taskid_set works", {
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
    check_tbl_spl_compound_taskid_set(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  # Check that ignoring derived task ids returns same result as not ignoring.
  expect_equal(
    check_tbl_spl_compound_taskid_set(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    ),
    check_tbl_spl_compound_taskid_set(tbl_orig, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    )
  )
})
