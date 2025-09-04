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
  expect_message(
    check_for_errors(checks_single_target_file),
    regexp = "All validation checks have been successful."
  )
  expect_named(
    checks_single_target_file,
    c(
      "valid_config",
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique",
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

  filename_tbl <- purrr::map_chr(checks_single_target_file, ~ .x$where) |>
    table()

  structure(
    c(file = 1L, `oracle-output.csv` = 15L),
    dim = 2L,
    dimnames = structure(
      list(
        c("file", "oracle-output.csv")
      ),
      names = ""
    ),
    class = "table"
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
  expect_message(
    check_for_errors(checks_dir_target_file),
    regexp = "All validation checks have been successful."
  )
  expect_named(
    checks_dir_target_file,
    c(
      "valid_config",
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique",
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
      "target_tbl_oracle_value",
      "target_dataset_exists_1",
      "target_dataset_unique_1",
      "target_dataset_file_ext_unique_1",
      "target_dataset_rows_unique_1",
      "target_file_exists_1",
      "target_partition_file_name_1",
      "target_file_ext_1",
      "target_file_read_1",
      "target_tbl_colnames_1",
      "target_tbl_coltypes_1",
      "target_tbl_ts_targets_1",
      "target_tbl_rows_unique_1",
      "target_tbl_values_1",
      "target_tbl_output_type_ids_1",
      "target_tbl_oracle_value_1"
    )
  )

  filename_tbl <- purrr::map_chr(checks_dir_target_file, ~ .x$where) |>
    table()

  expect_equal(
    filename_tbl,
    structure(
      c(
        `oracle-output` = 4L,
        `oracle-output/output_type=cdf/part-0.parquet` = 11L,
        target = 1L,
        `time-series` = 4L,
        `time-series/target=wk%20inc%20flu%20hosp/part-0.parquet` = 11L
      ),
      dim = 5L,
      dimnames = structure(
        list(c(
          "oracle-output",
          "oracle-output/output_type=cdf/part-0.parquet",
          "target",
          "time-series",
          "time-series/target=wk%20inc%20flu%20hosp/part-0.parquet"
        )),
        names = ""
      ),
      class = "table"
    )
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
  expect_s3_class(checks_ignored_file, "target_validations")
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

  expect_named(
    checks_delete_ds_not_allowed,
    c(
      "valid_config",
      "target_dataset_exists",
      "target_dataset_exists_1",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique",
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
  expect_s3_class(
    checks_delete_ds_not_allowed[["target_dataset_exists"]],
    "check_error"
  )
  filenames <- unique(
    purrr::map_chr(checks_delete_ds_not_allowed, ~ .x$where)
  )
  expect_equal(
    filenames,
    c("target", "time-series", "oracle-output.csv")
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
  expect_s3_class(checks_delete_ds_allowed, "target_validations")
  expect_named(
    checks_delete_ds_allowed,
    c(
      "valid_config",
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique",
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

  filenames <- unique(purrr::map_chr(checks_delete_ds_allowed, ~ .x$where))
  expect_equal(
    filenames,
    c("target", "oracle-output.csv")
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
  expect_s3_class(checks_del_file_none, "target_validations")
  expect_named(
    checks_del_file_none,
    c(
      "valid_config",
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )

  filenames <- unique(purrr::map_chr(checks_del_file_none, ~ .x$where))
  expect_equal(
    filenames,
    c("target", "oracle-output")
  )

  # Now test with file_modification_check = "failure"
  checks_del_file_fail <- validate_target_pr(
    hub_path = repo_path,
    gh_repo = "hubverse-org/ci-testhub-target",
    pr_number = 5L,
    file_modification_check = "failure"
  )
  expect_named(
    checks_del_file_fail,
    c(
      "valid_config",
      "oracle_output_mod",
      "target_dataset_exists",
      "target_dataset_unique",
      "target_dataset_file_ext_unique",
      "target_dataset_rows_unique"
    )
  )
  expect_s3_class(checks_del_file_fail[["oracle_output_mod"]], "check_failure")
  expect_error(
    suppressMessages(check_for_errors(checks_del_file_fail)),
    regexp = "The validation checks produced some failures/errors reported above."
  )
})
