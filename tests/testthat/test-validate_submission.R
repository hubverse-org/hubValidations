test_that("validate_submission works", {
  skip_if_offline()

  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  # File that passes validation
  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        skip_submit_window_check = TRUE,
        skip_check_config = TRUE
      )
    )
  )
  expect_s3_class(
    validate_submission(
      hub_path,
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      skip_submit_window_check = TRUE,
      skip_check_config = TRUE
    ),
    c("hub_validations")
  )

  # File with validation error ----
  # Missing file
  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
        skip_submit_window_check = TRUE,
        skip_check_config = TRUE
      )
    )
  )
  expect_s3_class(
    validate_submission(
      hub_path,
      file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
      skip_submit_window_check = TRUE,
      skip_check_config = TRUE
    ),
    c("hub_validations")
  )

  # Wrong submission location & missing data column (age_group)
  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv",
        skip_submit_window_check = TRUE,
        skip_check_config = TRUE
      )
    )
  )
  expect_s3_class(
    validate_submission(
      hub_path,
      file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv",
      skip_submit_window_check = TRUE,
      skip_check_config = TRUE
    ),
    c("hub_validations")
  )

  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        round_id_col = "random_col",
        skip_submit_window_check = TRUE,
        skip_check_config = TRUE
      )
    )
  )

  # File that passes validation & checks config
  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        skip_submit_window_check = TRUE
      )
    )
  )
  expect_s3_class(
    validate_submission(
      hub_path,
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      skip_submit_window_check = TRUE
    ),
    c("hub_validations")
  )
})

test_that("validate_submission submission within window works", {
  skip_if_offline()

  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  local_mocked_bindings(
    Sys.time = function(...) lubridate::as_datetime("2022-10-08 18:01:00 EEST")
  )
  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
      )[["submission_time"]]
    )
  )
})

test_that("validate_submission submission outside window fails correctly", {
  skip_if_offline()

  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  local_mocked_bindings(
    Sys.time = function(...) lubridate::as_datetime("2023-10-08 18:01:00 EEST")
  )
  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
      )[["submission_time"]]
    )
  )
})

test_that("validate_submission csv file read in and validated according to schema.", {
  skip_if_offline()

  expect_snapshot(
    str(
      validate_submission(
        hub_path = test_path("testdata/hub"),
        file_path = "hub-baseline/2023-04-24-hub-baseline.csv",
        skip_submit_window_check = TRUE
      )
    )
  )
})

test_that("validate_submission fails when csv cannot be parsed according to schema.", {
  skip_if_offline()

  expect_s3_class(
    validate_submission(
      hub_path = test_path("testdata/hub"),
      file_path = "hub-baseline/2023-05-01-hub-baseline.csv",
      skip_submit_window_check = TRUE
    )[["file_read"]],
    c("check_error")
  )
})

test_that("File containing task ID with all null properties validate correctly", {
  skip_if_offline()

  expect_snapshot(
    str(
      validate_submission(
        hub_path = test_path("testdata/hub-nul"),
        file_path = "team-model/2023-11-26-team-model.parquet",
        skip_submit_window_check = TRUE
      )
    )
  )
  expect_true(
    suppressMessages(
      check_for_errors(
        validate_submission(
          hub_path = test_path("testdata/hub-nul"),
          file_path = "team-model/2023-11-26-team-model.parquet",
          skip_submit_window_check = TRUE
        )
      )
    )
  )
  expect_snapshot(
    str(
      validate_submission(
        hub_path = test_path("testdata/hub-nul"),
        file_path = "team-model/2023-11-19-team-model.parquet",
        skip_submit_window_check = TRUE
      )
    )
  )
  expect_true(
    suppressMessages(
      check_for_errors(
        validate_submission(
          hub_path = test_path("testdata/hub-nul"),
          file_path = "team-model/2023-11-19-team-model.parquet",
          skip_submit_window_check = TRUE
        )
      )
    )
  )
})

test_that("validate_submission works with v3 samples.", {
  skip_if_offline()
  set.seed(123)
  expect_true(
    suppressMessages(
      check_for_errors(
        validate_submission(
          hub_path = test_path("testdata/hub-spl"),
          create_file_path("2022-10-22"),
          skip_submit_window_check = TRUE
        )
      )
    )
  )

  v <- validate_submission(
    hub_path = test_path("testdata/hub-spl"),
    create_file_path("2022-10-22"),
    skip_submit_window_check = TRUE
  )
  expect_snapshot(
    v$spl_compound_taskid_set$compound_taskid_set
  )
  expect_true(suppressMessages(check_for_errors(v)))
  # Coarser files validate successfully ----
  # compound_taskid_set = c("reference_date", "location")
  v_rl <- validate_submission(
    hub_path = test_path("testdata/hub-spl"),
    create_file_path("2022-10-29"),
    skip_submit_window_check = TRUE
  )
  expect_snapshot(
    v_rl$spl_compound_taskid_set$compound_taskid_set
  )
  expect_true(suppressMessages(check_for_errors(v_rl)))
  # compound_taskid_set = c("reference_date", "horizon")
  v_rh <- validate_submission(
    hub_path = test_path("testdata/hub-spl"),
    create_file_path("2022-11-05"),
    skip_submit_window_check = TRUE
  )
  expect_snapshot(
    v_rh$spl_compound_taskid_set$compound_taskid_set
  )
  expect_true(suppressMessages(check_for_errors(v_rh)))
})

test_that("validate_submission handles overriding output type id data type correctly.", {
  skip_if_offline()

  # Test with double output type id data type on parquet file
  # Getting character setting from config should pass
  expect_snapshot(
    validate_submission(
      hub_path = test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-11-Tm-Md.parquet",
      skip_submit_window_check = TRUE
    )[["col_types"]]
  )
  # Should pass
  expect_snapshot(
    validate_submission(
      hub_path = test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-11-Tm-Md.parquet",
      skip_submit_window_check = TRUE,
      output_type_id_datatype = "double"
    )[["col_types"]]
  )
  # Should pass
  expect_snapshot(
    validate_submission(
      hub_path = test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-11-Tm-Md.parquet",
      skip_submit_window_check = TRUE,
      output_type_id_datatype = "auto"
    )[["col_types"]]
  )
  # Should fail with warning
  expect_snapshot(
    validate_submission(
      hub_path = test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-11-Tm-Md.parquet",
      skip_submit_window_check = TRUE,
      output_type_id_datatype = "character"
    )[["col_types"]]
  )

  # Test with character output type id data type on parquet file
  # Getting character setting from config should pass
  expect_snapshot(
    validate_submission(
      hub_path = test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-18-Tm-Md.parquet",
      skip_submit_window_check = TRUE
    )[["col_types"]]
  )
  # Should fail with warning
  expect_snapshot(
    validate_submission(
      hub_path = test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-18-Tm-Md.parquet",
      skip_submit_window_check = TRUE,
      output_type_id_datatype = "double"
    )[["col_types"]]
  )
  # Should pass
  expect_snapshot(
    validate_submission(
      hub_path = test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-18-Tm-Md.parquet",
      skip_submit_window_check = TRUE,
      output_type_id_datatype = "character"
    )[["col_types"]]
  )
})

test_that("Ignoring derived_task_ids in validate_submission works", {
  skip_if_offline()
  # Validation passes
  expect_snapshot(
    str(
      validate_submission(
        hub_path = system.file("testhubs/samples", package = "hubValidations"),
        file_path = "flu-base/2022-10-22-flu-base.csv",
        skip_submit_window_check = TRUE,
        derived_task_ids = "target_end_date"
      )
    )
  )

  # Ensure derived_task_ids values are ignored in validate submission by introducing
  # deliberate error in derived_task_ids through mocking.
  # This should not impact successful validation of affected checks
  tbl_mod <- read_model_out_file(
    file_path = "flu-base/2022-10-22-flu-base.csv",
    hub_path = system.file("testhubs/samples", package = "hubValidations"),
    coerce_types = "chr"
  )
  tbl_mod[1, "target_end_date"] <- "2092-10-22"
  # Use `local_mocked_bindings()` to override `read_model_out_file`
  local_mocked_bindings(
    read_model_out_file = function(...) tbl_mod
  )
  expect_snapshot(
    validate_submission(
      hub_path = system.file("testhubs/samples", package = "hubValidations"),
      file_path = "flu-base/2022-10-22-flu-base.csv",
      skip_submit_window_check = TRUE,
      derived_task_ids = "target_end_date"
    )[c(
      "valid_vals",
      "req_vals",
      "value_col_valid",
      "spl_n",
      "spl_compound_taskid_set",
      "spl_compound_tid",
      "spl_non_compound_tid"
    )]
  )
})

test_that("validate_submission returns check_failure when duplicate files per round exist", {
  skip_if_offline()

  copy_path <- withr::local_tempdir()
  fs::dir_copy(
    system.file("testhubs/simple", package = "hubValidations"),
    copy_path
  )
  hub_path <- fs::path(copy_path, "simple")

  # Create duplicate parquet file
  read_model_out_file(
    file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
    hub_path = hub_path,
    coerce_types = "hub"
  ) |>
    arrow::write_parquet(
      fs::path(
        hub_path,
        "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.parquet"
      )
    )

  dup_model_out_val <- validate_submission(
    hub_path,
    file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
    skip_submit_window_check = TRUE,
    skip_check_config = TRUE
  )
  expect_snapshot(
    str(dup_model_out_val)
  )
  expect_snapshot(
    dup_model_out_val[["file_n"]]
  )
})

test_that("validate_submission works with v4 simple", {
  skip_if_offline()

  hub_path <- system.file("testhubs", "v4", "simple", package = "hubUtils")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  v4_simple <- validate_submission(
    hub_path,
    file_path = file_path,
    skip_submit_window_check = TRUE,
    skip_check_config = TRUE
  )
  expect_s3_class(v4_simple, c("hub_validations", "list"), exact = TRUE)
  expect_true(suppressMessages(check_for_errors(v4_simple)))
})

test_that("validate_submission works with v4 flusight (contains derived_task_ids)", {
  skip_if_offline()

  hub_path <- system.file("testhubs", "v4", "flusight", package = "hubUtils")
  file_path <- "hub-baseline/2023-05-08-hub-baseline.parquet"

  v4_missing_meta <- validate_submission(
    hub_path,
    file_path = file_path,
    skip_submit_window_check = TRUE,
    skip_check_config = TRUE
  )

  # TODO: Update snapshot when v4 flusight hub is updated
  expect_s3_class(v4_missing_meta, c("hub_validations", "list"), exact = TRUE)
  expect_snapshot(check_for_errors(v4_missing_meta), error = TRUE)

  # Check we get the same result when manually supplying derived_task_ids
  expect_equal(
    v4_missing_meta,
    validate_submission(
      hub_path,
      file_path = file_path,
      skip_submit_window_check = TRUE,
      skip_check_config = TRUE,
      derived_task_ids = "target_date"
    )
  )
})
