test_that("validate_pr works on valid PR", {
  skip_if_offline()

  temp_hub <- fs::path(tempdir(), "valid_sb_hub")
  gert::git_clone(
    url = "https://github.com/Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
    path = temp_hub,
    branch = "pr-valid"
  )

  checks <- validate_pr(
    hub_path = temp_hub,
    gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
    pr_number = 4,
    skip_submit_window_check = TRUE
  )

  expect_snapshot(str(checks))
  expect_invisible(suppressMessages(check_for_errors(checks)))
  expect_message(check_for_errors(checks),
    regexp = "All validation checks have been successful."
  )
})

test_that("validate_pr works on invalid PR", {
  skip_if_offline()

  temp_hub <- fs::path(tempdir(), "invalid_sb_hub")
  gert::git_clone(
    url = "https://github.com/Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
    path = temp_hub,
    branch = "pr-missing-taskid"
  )

  checks <- validate_pr(
    hub_path = temp_hub,
    gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
    pr_number = 5,
    skip_submit_window_check = TRUE
  )

  expect_snapshot(str(checks))

  expect_error(
    suppressMessages(check_for_errors(checks))
  )
})

test_that("validate_pr flags modifications and deletions in PR", {
  skip_if_offline()

  temp_hub <- fs::path(tempdir(), "mod_del_hub")
  gert::git_clone(
    url = "https://github.com/Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
    path = temp_hub,
    branch = "test-mod-del"
  )

  checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE
    )
  )

  expect_snapshot(str(checks))
  expect_error(
    suppressMessages(check_for_errors(checks))
  )

  checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE,
      file_modify_check = "warn"
    )
  )
  expect_snapshot(str(checks))
  expect_error(
    suppressMessages(check_for_errors(checks))
  )

  checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE,
      file_modify_check = "message"
    )
  )
  expect_snapshot(str(checks))
  expect_true(
    suppressMessages(check_for_errors(checks[1:5]))
  )


  checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE,
      file_modify_check = "none"
    )
  )
  expect_snapshot(str(checks))
  expect_true(
    suppressMessages(check_for_errors(checks[1:5]))
  )

  mockery::stub(
    check_submission_time,
    "Sys.time",
    lubridate::as_datetime("2022-10-08 18:01:00 EEST"),
    2
  )
  checks <- suppressMessages(
    validate_pr(
      hub_path = temp_hub,
      gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
      pr_number = 6,
      skip_submit_window_check = TRUE,
      allow_submit_window_mods = TRUE
    )
  )
  expect_snapshot(str(checks))
})
