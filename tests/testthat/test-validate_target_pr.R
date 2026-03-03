# Set up CI target test hub for testing PR validation
if (curl::has_internet()) {
  # Allow example data temp directory to persist across tests.
  tmp_dir <- withr::local_tempdir()
  ci_target_hub_path <- fs::path(tmp_dir, "target")
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-target.git",
    path = ci_target_hub_path
  )
}

test_that("validate_target_pr works on valid single oracle output file", {
  repo_path <- ci_target_hub_path
  branch <- "add-file-oracle-output"
  # Checkout PR branch
  suppressMessages(gert::git_branch_checkout(branch, repo = repo_path))
  expect_equal(gert::git_branch(repo = repo_path), branch)

  checks_single_target_file <- validate_target_pr(
    hub_path = repo_path,
    gh_repo = "hubverse-org/ci-testhub-target",
    pr_number = 1L
  )
  expect_snapshot(checks_single_target_file)
  expect_s3_class(checks_single_target_file, "target_validations_collection")
  expect_message(
    check_for_errors(checks_single_target_file),
    regexp = "All validation checks have been successful."
  )
  # Collection is keyed by file path
  expect_named(
    checks_single_target_file,
    c("hub-config", "oracle-output", "oracle-output.csv")
  )
  # Each file entry contains target_validations with individual checks
  expect_s3_class(
    checks_single_target_file[["oracle-output"]],
    "target_validations"
  )
  expect_s3_class(
    checks_single_target_file[["oracle-output.csv"]],
    "target_validations"
  )

  # Verify check names within each entry
  expect_named(
    checks_single_target_file[["hub-config"]],
    "valid_config"
  )
  expect_named(
    checks_single_target_file[["oracle-output"]],
    c(
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )
  expect_named(
    checks_single_target_file[["oracle-output.csv"]],
    c(
      "target_file_exists",
      "target_partition_file_name",
      "target_file_ext",
      "target_file_read",
      "target_tbl_colnames",
      "target_tbl_coltypes",
      "target_tbl_ts_targets",
      "target_tbl_rows_unique",
      "target_tbl_values",
      "target_tbl_output_type_ids",
      "target_tbl_oracle_value"
    )
  )
})


test_that("validate_target_pr works on multiple valid dir oracle output files", {
  repo_path <- ci_target_hub_path
  branch <- "add-target-dir-files-v5"
  # Checkout PR branch
  suppressMessages(gert::git_branch_checkout(branch, repo = repo_path))
  expect_equal(gert::git_branch(repo = repo_path), branch)

  checks_dir_target_file <- validate_target_pr(
    hub_path = ci_target_hub_path,
    gh_repo = "hubverse-org/ci-testhub-target",
    pr_number = 2L
  )
  expect_snapshot(checks_dir_target_file)
  expect_s3_class(checks_dir_target_file, "target_validations_collection")
  expect_message(
    check_for_errors(checks_dir_target_file),
    regexp = "All validation checks have been successful."
  )
  # Collection is keyed by file path - has dataset checks and individual file checks
  expected_names <- c(
    "hub-config",
    "time-series",
    "time-series/target=wk%20inc%20flu%20hosp/part-0.parquet",
    "oracle-output",
    "oracle-output/output_type=cdf/part-0.parquet"
  )
  expect_named(checks_dir_target_file, expected_names)

  # Each entry is a target_validations object
  for (name in expected_names) {
    expect_s3_class(checks_dir_target_file[[name]], "target_validations")
  }

  # Verify check names within each entry
  expect_named(
    checks_dir_target_file[["hub-config"]],
    "valid_config"
  )
  # Dataset checks
  dataset_check_names <- c(
    "target_dataset_exists",
    "target_dataset_unique",
    "target_dataset_file_ext_unique",
    "target_dataset_rows_unique"
  )
  expect_named(
    checks_dir_target_file[["time-series"]],
    dataset_check_names
  )
  expect_named(
    checks_dir_target_file[["oracle-output"]],
    dataset_check_names
  )
  # File checks
  file_check_names <- c(
    "target_file_exists",
    "target_partition_file_name",
    "target_file_ext",
    "target_file_read",
    "target_tbl_colnames",
    "target_tbl_coltypes",
    "target_tbl_ts_targets",
    "target_tbl_rows_unique",
    "target_tbl_values",
    "target_tbl_output_type_ids",
    "target_tbl_oracle_value"
  )
  expect_named(
    checks_dir_target_file[[
      "time-series/target=wk%20inc%20flu%20hosp/part-0.parquet"
    ]],
    file_check_names
  )
  expect_named(
    checks_dir_target_file[["oracle-output/output_type=cdf/part-0.parquet"]],
    file_check_names
  )
})


test_that("validate_target_pr reports ignored files correctly", {
  repo_path <- ci_target_hub_path
  branch <- "add-ignored-files-target-dir-v5"
  # Checkout PR branch
  suppressMessages(gert::git_branch_checkout(branch, repo = repo_path))
  expect_equal(gert::git_branch(repo = repo_path), branch)

  msgs <- validate_target_pr(
    hub_path = repo_path,
    gh_repo = "hubverse-org/ci-testhub-target",
    pr_number = 3L
  ) |>
    capture_messages() |>
    cli::ansi_strip() |>
    stringr::str_squish()

  expect_match(
    msgs[1],
    "PR contains commits to additional files which have not been checked"
  )
  expect_match(
    msgs[2],
    "No changes to target data files in PR #3 of hubverse-org/ci-testhub-target. Checks skipped."
  )

  checks_ignored_file <-
    suppressMessages(validate_target_pr(
      hub_path = repo_path,
      gh_repo = "hubverse-org/ci-testhub-target",
      pr_number = 3L
    ))
  expect_s3_class(checks_ignored_file, "target_validations_collection")
  expect_length(checks_ignored_file, 0L)
})

test_that("validate_target_pr handles target dataset deletions appropriately", {
  repo_path <- ci_target_hub_path
  branch <- "remove-ts-add-oo"
  # Checkout PR branch
  suppressMessages(gert::git_branch_checkout(branch, repo = repo_path))
  expect_equal(gert::git_branch(repo = repo_path), branch)

  checks_delete_ds_not_allowed <- validate_target_pr(
    hub_path = repo_path,
    gh_repo = "hubverse-org/ci-testhub-target",
    pr_number = 4L
  )

  expect_s3_class(checks_delete_ds_not_allowed, "target_validations_collection")
  # Collection includes dataset and file validations
  expect_named(
    checks_delete_ds_not_allowed,
    c("hub-config", "time-series", "oracle-output", "oracle-output.csv")
  )
  # The time-series dataset check should contain a check_error for missing dataset
  ts_dataset_checks <- checks_delete_ds_not_allowed[["time-series"]]
  expect_s3_class(ts_dataset_checks, "target_validations")
  # Check that target_dataset_exists is a check_error
  expect_s3_class(
    ts_dataset_checks[["target_dataset_exists"]],
    "check_error"
  )
  # Verify check names
  expect_named(
    checks_delete_ds_not_allowed[["hub-config"]],
    "valid_config"
  )
  # time-series only has the exists check since it fails early
  expect_named(
    checks_delete_ds_not_allowed[["time-series"]],
    "target_dataset_exists"
  )
  expect_named(
    checks_delete_ds_not_allowed[["oracle-output"]],
    c(
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )
  expect_named(
    checks_delete_ds_not_allowed[["oracle-output.csv"]],
    c(
      "target_file_exists",
      "target_partition_file_name",
      "target_file_ext",
      "target_file_read",
      "target_tbl_colnames",
      "target_tbl_coltypes",
      "target_tbl_ts_targets",
      "target_tbl_rows_unique",
      "target_tbl_values",
      "target_tbl_output_type_ids",
      "target_tbl_oracle_value"
    )
  )

  # Now test with allow_target_type_deletion = TRUE
  checks_delete_ds_allowed <- validate_target_pr(
    hub_path = repo_path,
    gh_repo = "hubverse-org/ci-testhub-target",
    pr_number = 4L,
    allow_target_type_deletion = TRUE
  )
  expect_message(
    check_for_errors(checks_delete_ds_allowed),
    regexp = "All validation checks have been successful."
  )
  expect_s3_class(checks_delete_ds_allowed, "target_validations_collection")
  # When deletion is allowed, time-series check is skipped
  expect_named(
    checks_delete_ds_allowed,
    c("hub-config", "oracle-output", "oracle-output.csv")
  )
})

test_that("validate_target_pr modification check settings work", {
  repo_path <- ci_target_hub_path
  branch <- "delete-target-dir-files"
  # Checkout PR branch
  suppressMessages(gert::git_branch_checkout(branch, repo = repo_path))
  expect_equal(gert::git_branch(repo = repo_path), branch)

  checks_del_file_none <- validate_target_pr(
    hub_path = repo_path,
    gh_repo = "hubverse-org/ci-testhub-target",
    pr_number = 5L
  )
  expect_message(
    check_for_errors(checks_del_file_none),
    regexp = "All validation checks have been successful."
  )
  expect_s3_class(checks_del_file_none, "target_validations_collection")
  # With no modification check, only dataset validation is performed
  expect_named(
    checks_del_file_none,
    c("hub-config", "oracle-output")
  )
  # Verify check names
  expect_named(
    checks_del_file_none[["hub-config"]],
    "valid_config"
  )
  expect_named(
    checks_del_file_none[["oracle-output"]],
    c(
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )

  # Now test with file_modification_check = "failure"
  checks_del_file_fail <- validate_target_pr(
    hub_path = repo_path,
    gh_repo = "hubverse-org/ci-testhub-target",
    pr_number = 5L,
    file_modification_check = "failure"
  )
  expect_s3_class(checks_del_file_fail, "target_validations_collection")
  # Collection includes config, dataset validation, and the deleted file path
  deleted_file_path <- "oracle-output/output_type=sample/part-0.parquet"
  expect_named(
    checks_del_file_fail,
    c("hub-config", "oracle-output", deleted_file_path)
  )
  # Verify check names in each entry
  expect_named(checks_del_file_fail[["hub-config"]], "valid_config")
  expect_named(
    checks_del_file_fail[["oracle-output"]],
    c(
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )
  # The deleted file entry contains the valid_file_status check as a failure
  expect_named(checks_del_file_fail[[deleted_file_path]], "valid_file_status")
  expect_s3_class(
    checks_del_file_fail[[deleted_file_path]][["valid_file_status"]],
    "check_failure"
  )

  expect_error(
    suppressMessages(check_for_errors(checks_del_file_fail)),
    regexp = "The validation checks produced some failures/errors reported above."
  )
})
