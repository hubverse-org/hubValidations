test_that("validate_pr works on valid PR", {
  skip_if_offline()

  dir <- withr::local_tempdir()
  temp_hub <- fs::dir_create(fs::path(dir, "valid_sb_hub"))
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-simple",
    path = temp_hub,
    branch = "pr-valid"
  )

  checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple",
      pr_number = 4,
      skip_submit_window_check = TRUE
    )
  )

  expect_s3_class(checks, "hub_validations_collection")
  expect_equal(
    purrr::map(checks, first_classes),
    list(
      "hub-config" = valid_config,
      "team1-goodmodel/2022-10-22-team1-goodmodel.csv" = valid_file_checks
    )
  )
  expect_invisible(suppressMessages(check_for_errors(checks)))
  expect_message(
    check_for_errors(checks),
    regexp = "All validation checks have been successful."
  )
})

test_that("validate_pr works on invalid PR", {
  skip_if_offline()

  dir <- withr::local_tempdir()
  temp_hub <- fs::dir_create(fs::path(dir, "invalid_sb_hub"))
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-simple",
    path = temp_hub,
    branch = "pr-missing-taskid"
  )

  invalid_checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple",
      pr_number = 5,
      skip_submit_window_check = TRUE
    )
  )

  expect_s3_class(invalid_checks, "hub_validations_collection")
  file_path <- "hub-baseline/2022-10-22-hub-baseline.parquet"
  expect_equal(
    purrr::map(invalid_checks, first_classes),
    rlang::list2(
      "hub-config" = valid_config,
      # The file is missing a task ID column, so validation stops at colnames.
      !!file_path := c(
        file_checks,
        data_checks[
          c(
            "file_read",
            "valid_round_id_col",
            "unique_round_id",
            "match_round_id"
          )
        ],
        colnames = "check_error"
      )
    )
  )
  expect_snapshot(invalid_checks[[file_path]][["colnames"]])

  expect_error(
    suppressMessages(check_for_errors(invalid_checks))
  )
})

test_that("validate_pr flags modifications and deletions in PR", {
  skip_if_offline()

  dir <- withr::local_tempdir()
  temp_hub <- fs::dir_create(fs::path(dir, "mod_del_hub"))
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-simple",
    path = temp_hub,
    branch = "test-mod-del"
  )

  # This checks that removed metadata and model-output files are detected and
  # flagged as check errors.
  # It also checks that missing metadata files do not cause early return
  # of submission validation of model output file.
  mod_checks_error <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE
    )
  )

  expect_s3_class(mod_checks_error, "hub_validations_collection")
  expect_equal(
    purrr::map(mod_checks_error, first_classes),
    list(
      "hub-config" = valid_config,
      "hub-baseline/2022-10-08-hub-baseline.csv" = c(
        valid_file_checks,
        valid_file_status = "check_error"
      ),
      "team1-goodmodel/2022-10-22-team1-goodmodel.csv" = no_metadata_file_checks,
      "team1-goodmodel/2022-10-15-team1-goodmodel.csv" = c(
        valid_file_status = "check_error"
      ),
      "team1-goodmodel.yaml" = c(valid_file_status = "check_error")
    )
  )
  mod_files <- c(
    "hub-baseline/2022-10-08-hub-baseline.csv",
    "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
    "team1-goodmodel.yaml"
  )
  expect_snapshot(purrr::map(mod_checks_error[mod_files], "valid_file_status"))
  expect_error(
    suppressMessages(check_for_errors(mod_checks_error))
  )

  # capture file_modification_check deprecation warning
  expect_warning(
    suppressMessages(
      validate_pr(
        hub_path = temp_hub,
        gh_repo = "hubverse-org/ci-testhub-simple",
        pr_number = 6,
        skip_submit_window_check = TRUE,
        file_modification_check = "warn"
      )
    )
  )

  # This checks that removed metadata and model-output files are detected and
  # flagged as check failure.
  # It also checks that missing metadata files do not cause early return
  # of submission validation of model output file.
  mod_checks_warn <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE,
      file_modification_check = "failure"
    )
  )
  expect_s3_class(mod_checks_warn, "hub_validations_collection")
  expect_equal(
    purrr::map(mod_checks_warn, first_classes),
    list(
      "hub-config" = valid_config,
      "hub-baseline/2022-10-08-hub-baseline.csv" = c(
        valid_file_checks,
        valid_file_status = "check_failure"
      ),
      "team1-goodmodel/2022-10-22-team1-goodmodel.csv" = no_metadata_file_checks,
      "team1-goodmodel/2022-10-15-team1-goodmodel.csv" = c(
        valid_file_status = "check_failure"
      ),
      "team1-goodmodel.yaml" = c(valid_file_status = "check_failure")
    )
  )
  expect_snapshot(purrr::map(mod_checks_warn[mod_files], "valid_file_status"))
  expect_error(
    suppressMessages(check_for_errors(mod_checks_warn))
  )

  mod_checks_message <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE,
      file_modification_check = "message"
    )
  )
  expect_s3_class(mod_checks_message, "hub_validations_collection")
  expect_equal(
    purrr::map(mod_checks_message, first_classes),
    list(
      "hub-config" = valid_config,
      "hub-baseline/2022-10-08-hub-baseline.csv" = c(
        valid_file_checks,
        valid_file_status = "check_info"
      ),
      "team1-goodmodel/2022-10-22-team1-goodmodel.csv" = no_metadata_file_checks,
      "team1-goodmodel/2022-10-15-team1-goodmodel.csv" = c(
        valid_file_status = "check_info"
      ),
      "team1-goodmodel.yaml" = c(valid_file_status = "check_info")
    )
  )
  expect_snapshot(
    purrr::map(mod_checks_message[mod_files], "valid_file_status")
  )
  # With file_modification_check = "message", modifications are check_info
  # All file status checks use the standard name "valid_file_status"
  # Modified files that are also validated will have both regular checks and valid_file_status
  expect_true(
    "valid_file_status" %in%
      names(mod_checks_message[["hub-baseline/2022-10-08-hub-baseline.csv"]])
  )
  expect_s3_class(
    mod_checks_message[[
      "hub-baseline/2022-10-08-hub-baseline.csv"
    ]]$valid_file_status,
    "check_info"
  )
  # Deleted files only have the valid_file_status check
  expect_named(
    mod_checks_message[["team1-goodmodel/2022-10-15-team1-goodmodel.csv"]],
    "valid_file_status"
  )
  expect_s3_class(
    mod_checks_message[[
      "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
    ]]$valid_file_status,
    "check_info"
  )
  expect_named(
    mod_checks_message[["team1-goodmodel.yaml"]],
    "valid_file_status"
  )
  expect_s3_class(
    mod_checks_message[["team1-goodmodel.yaml"]]$valid_file_status,
    "check_info"
  )

  mod_checks_none <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE,
      file_modification_check = "none"
    )
  )
  expect_s3_class(mod_checks_none, "hub_validations_collection")
  expect_equal(
    purrr::map(mod_checks_none, first_classes),
    list(
      "hub-config" = valid_config,
      "hub-baseline/2022-10-08-hub-baseline.csv" = valid_file_checks,
      "team1-goodmodel/2022-10-22-team1-goodmodel.csv" = no_metadata_file_checks
    )
  )
  # With file_modification_check = "none", no modification checks are added
  expect_false(
    "team1-goodmodel/2022-10-15-team1-goodmodel.csv" %in% names(mod_checks_none)
  )
  expect_false("team1-goodmodel.yaml" %in% names(mod_checks_none))
  expect_false(
    "valid_file_status" %in%
      names(mod_checks_none[["hub-baseline/2022-10-08-hub-baseline.csv"]])
  )

  local_mocked_bindings(
    Sys.time = function(...) lubridate::as_datetime("2022-10-08 18:01:00 EEST")
  )
  mod_checks_in_window <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE,
      allow_submit_window_mods = TRUE
    )
  )
  expect_s3_class(mod_checks_in_window, "hub_validations_collection")
  # The modification falls within the submission window, so only the
  # removed files are flagged.
  expect_equal(
    purrr::map(mod_checks_in_window, first_classes),
    list(
      "hub-config" = valid_config,
      "hub-baseline/2022-10-08-hub-baseline.csv" = valid_file_checks,
      "team1-goodmodel/2022-10-22-team1-goodmodel.csv" = no_metadata_file_checks,
      "team1-goodmodel/2022-10-15-team1-goodmodel.csv" = c(
        valid_file_status = "check_error"
      ),
      "team1-goodmodel.yaml" = c(valid_file_status = "check_error")
    )
  )
})


test_that("validate_pr handles errors in determining submission window & file renaming", {
  skip_if_offline()

  dir <- withr::local_tempdir()
  temp_hub <- fs::dir_create(fs::path(dir, "mod_exec_error_hub"))
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-simple",
    path = temp_hub,
    branch = "test-exec-error-mod-delete"
  )

  mod_checks_exec_error <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple",
      pr_number = 7,
      skip_submit_window_check = TRUE
    )
  )
  expect_s3_class(mod_checks_exec_error, "hub_validations_collection")
  file_path <- "team1-goodmodel/2022-10-team1-goodmodel.csv"
  expect_equal(
    purrr::map(mod_checks_exec_error, first_classes),
    rlang::list2(
      "hub-config" = valid_config,
      "team1-goodmodel/2022-10-22-team1-goodmodel.csv" = valid_file_checks,
      !!file_path := c(
        file_exists = "check_success",
        file_name = "check_error",
        valid_file_status = "check_exec_error"
      )
    )
  )
  expect_snapshot(mod_checks_exec_error[[file_path]][["file_name"]])
  expect_snapshot(mod_checks_exec_error[[file_path]][["valid_file_status"]])
  expect_error(
    suppressMessages(check_for_errors(mod_checks_exec_error))
  )
})


test_that("validate_pr works on valid PR using v2.0.0 schema and old orgname", {
  skip_if_offline()

  dir <- withr::local_tempdir()
  temp_hub <- fs::dir_create(fs::path(dir, "valid_sb_hub-old"))
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-simple-old-orgname",
    path = temp_hub,
    branch = "pr-valid"
  )

  checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-simple-old-orgname",
      pr_number = 1,
      skip_submit_window_check = TRUE
    )
  )

  expect_s3_class(checks, "hub_validations_collection")
  # The v2.0.0 schema has no sample output type, so no sample checks run.
  expect_equal(
    purrr::map(checks, first_classes),
    list(
      "hub-config" = valid_config,
      "team1-goodmodel/2022-10-22-team1-goodmodel.csv" = valid_file_checks[
        !startsWith(names(valid_file_checks), "spl_")
      ]
    )
  )
  expect_invisible(suppressMessages(check_for_errors(checks)))
  expect_message(
    check_for_errors(checks),
    regexp = "All validation checks have been successful."
  )
})

test_that("validate_pr works on PR with more than 30 files", {
  skip_if_offline()

  dir <- withr::local_tempdir()
  temp_hub <- fs::dir_create(fs::path(dir, "many_files_hub"))
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-target",
    path = temp_hub,
    branch = "pr-many-files"
  )

  # This tests that validate_pr correctly handles PRs with more than 30 files
  # (beyond GitHub API's default pagination limit). Relates to issue #278.
  many_files_checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "hubverse-org/ci-testhub-target",
      pr_number = 7,
      skip_submit_window_check = TRUE
    )
  )

  expect_s3_class(many_files_checks, "hub_validations_collection")
  # Expect errors due to invalid filenames (can't parse model metadata),
  # but all 35 files should be validated
  expect_error(
    suppressMessages(check_for_errors(many_files_checks))
  )
  # With the new hierarchical structure, file paths are the names of the collection
  files_checked <- names(many_files_checks)

  expected_files <- c(
    "hub-config",
    sprintf(
      "test-model-%02d/2022-10-22-test-model-%02d.csv",
      1:35,
      1:35
    )
  )

  expect_equal(files_checked, expected_files)
})
