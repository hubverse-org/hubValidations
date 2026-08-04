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
    which(tbl_error$output_type == "sample" & tbl_error$output_type_id == "1")[
      1
    ],
    "horizon"
  ] <- "2"

  expect_snapshot(
    check_tbl_spl_compound_taskid_set(tbl_error, round_id, file_path, hub_path)
  )
  error_check <- check_tbl_spl_compound_taskid_set(
    tbl_error,
    round_id,
    file_path,
    hub_path
  )
  expect_snapshot(error_check$errors)

  ## Test 3 - Force one sample to have different compound task id set then the rest
  ## of the samples. This should fail validation for more than 1 unique task id set
  ## per modeling task
  tbl_error_dups <- tbl
  tbl_error_dups[which(tbl_error_dups$output_type_id == "2"), "horizon"] <- "0"
  expect_snapshot(
    check_tbl_spl_compound_taskid_set(
      tbl_error_dups,
      round_id,
      file_path,
      hub_path
    )
  )

  error_dup_check <- check_tbl_spl_compound_taskid_set(
    tbl_error_dups,
    round_id,
    file_path,
    hub_path
  )
  expect_snapshot(error_dup_check$errors)
})

test_that("Different compound_taskid_sets work", {
  hub_path <- test_path("testdata/hub-spl")

  # Read in test files
  tbl_coarse_location <- read_model_out_file(
    file_path = create_file_path("2022-10-29"),
    hub_path = hub_path,
    coerce_types = "chr"
  )
  tbl_coarse_horizon <- read_model_out_file(
    file_path = create_file_path("2022-11-05"),
    hub_path = hub_path,
    coerce_types = "chr"
  )

  # Validation of coarser compound_taskid_set works
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_coarse_location,
        "2022-10-29",
        create_file_path("2022-10-29"),
        hub_path
      )
    )
  )
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_coarse_horizon,
        "2022-11-05",
        create_file_path("2022-11-05"),
        hub_path
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
      "rounds",
      1,
      "model_tasks",
      2,
      "output_type",
      "sample",
      "output_type_id_params",
      "compound_taskid_set"
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
        "2022-11-05",
        create_file_path("2022-11-05"),
        hub_path
      )
    )
  )
  # Specifying the derived task IDs allows validation to pass and excludes derived
  # task IDs from the compound_taskid_set
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_coarse_horizon,
        "2022-11-05",
        create_file_path("2022-11-05"),
        hub_path,
        derived_task_ids = "target_end_date"
      )
    )
  )
})

test_that("Coarser compound_taskid_set triggers check-level warning", {
  hub_path <- test_path("testdata/hub-spl")
  round_id <- "2022-10-29"
  file_path <- create_file_path(round_id = round_id)

  # This file has compound_taskid_set = ["reference_date", "location"],
  # coarser than configured ["reference_date", "horizon", "location",
  # "variant", "target_end_date"].
  tbl_coarse_location <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  result <- check_tbl_spl_compound_taskid_set(
    tbl_coarse_location,
    round_id = round_id,
    file_path = file_path,
    hub_path = hub_path
  )

  # Check passes but with a warning
  expect_s3_class(result, "check_success")
  expect_true(length(result$warnings) > 0)

  # Full check message explicitly states the coarser outcome and carries
  # per-modeling-task detected vs configured details.
  expect_equal(
    result$message,
    paste0(
      "All samples in a model task conform to single, unique compound ",
      "task ID set that matches or is\n    coarser than the configured ",
      "`compound_taskid_set`. \n mt 2: detected (\"reference_date\" and ",
      "\"location\") is coarser than configured (\"reference_date\", ",
      "\"horizon\", \"location\", \"variant\", and \"target_end_date\")."
    )
  )

  # Matching compound_taskid_set should have no warnings
  hub_path_match <- system.file("testhubs/samples", package = "hubValidations")
  file_path_match <- "flu-base/2022-10-22-flu-base.csv"
  result_match <- check_tbl_spl_compound_taskid_set(
    read_model_out_file(
      file_path = file_path_match,
      hub_path = hub_path_match,
      coerce_types = "chr"
    ),
    "2022-10-22",
    file_path_match,
    hub_path_match
  )
  expect_s3_class(result_match, "check_success")
  expect_null(result_match$warnings)
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
      "rounds",
      1,
      "model_tasks",
      2,
      "output_type",
      "sample",
      "output_type_id_params",
      "compound_taskid_set"
    ),
    ~ c("reference_date", "horizon", "location", "target_end_date")
  )
  local_mocked_bindings(
    read_config = function(...) config_tasks_no_variant
  )
  tbl_fine <- create_spl_file(
    "2022-10-22",
    compound_taskid_set = list(NULL, NULL),
    write = FALSE,
    out_datatype = "chr"
  )

  # Validation of finer compound_taskid_set fails
  expect_snapshot(
    check_tbl_spl_compound_taskid_set(
      tbl_fine,
      "2022-10-22",
      create_file_path("2022-10-22"),
      test_path("testdata/hub-spl")
    )
  )
  expect_snapshot(
    str(
      check_tbl_spl_compound_taskid_set(
        tbl_fine,
        "2022-10-22",
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
    check_tbl_spl_compound_taskid_set(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  # Check that ignoring derived task ids returns same result as not ignoring.
  expect_equal(
    check_tbl_spl_compound_taskid_set(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    ),
    check_tbl_spl_compound_taskid_set(
      tbl_orig,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
})

test_that("check_tbl_spl_compound_taskid_set works with an empty compound_taskid_set", {
  hub_path <- empty_cts_hub()
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  tbl <- tbl[tbl$output_type == "sample", ]
  task_ids <- setdiff(names(tbl), c(hubUtils::std_colnames, "value"))

  # Give every sample one row per task ID value combination, so no task ID holds a
  # single value within a sample and the detected set is empty, as configured.
  joint <- tbl |>
    dplyr::group_by(dplyr::pick(dplyr::all_of(task_ids))) |>
    dplyr::mutate(output_type_id = as.character(dplyr::row_number())) |>
    dplyr::ungroup()

  expect_snapshot(
    check_tbl_spl_compound_taskid_set(joint, round_id, file_path, hub_path)
  )
  config_tasks <- read_config(hub_path, "tasks")
  expect_equal(
    get_tbl_compound_taskid_set(joint, config_tasks, round_id, compact = FALSE),
    list(`1` = NULL, `2` = character(0))
  )
  # Compacting drops the modeling task without samples but keeps the empty detected
  # set, which is an answer rather than an absence.
  expect_equal(
    get_tbl_compound_taskid_set(joint, config_tasks, round_id),
    list(`2` = character(0))
  )

  # The file as submitted keeps each sample to one location, which is a finer set
  # than a hub expecting none.
  expect_snapshot(
    check_tbl_spl_compound_taskid_set(tbl, round_id, file_path, hub_path)
  )
})

test_that("validation passes end to end with an empty compound_taskid_set", {
  # The other sample checks all read the compound task ID set, and an empty one is easy
  # to lose on the way to them: dropped when compacting, or arriving as `NULL`. Either
  # way they would see nothing configured and read it as an absent set, which asks for
  # the opposite of what an empty one does. So this calls `validate_model_data()` rather
  # than the check on its own, to pin that the empty set reaches them intact.
  hub_path <- empty_cts_hub()
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  spl <- tbl[tbl$output_type == "sample", ]
  task_ids <- setdiff(names(spl), c(hubUtils::std_colnames, "value"))

  joint <- spl |>
    dplyr::group_by(dplyr::pick(dplyr::all_of(task_ids))) |>
    dplyr::mutate(output_type_id = as.character(dplyr::row_number())) |>
    dplyr::ungroup()
  utils::write.csv(
    rbind(tbl[tbl$output_type != "sample", ], joint),
    fs::path(hub_path, "model-output", file_path),
    row.names = FALSE
  )

  checks <- validate_model_data(hub_path, file_path)
  expect_true(all(purrr::map_lgl(checks, \(.x) !is_any_error(.x))))
})
