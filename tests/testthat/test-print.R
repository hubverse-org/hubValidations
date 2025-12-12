test_that("print.hub_validations prints all check types correctly", {
  validations <- new_hub_validations()

  validations$success_check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "passed."
  )
  validations$failure_check <- capture_check_cnd(
    check = FALSE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "failed."
  )
  validations$error_check <- capture_check_cnd(
    check = FALSE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "errored.",
    error = TRUE
  )
  validations$info_check <- capture_check_info(
    file_path = "test.csv",
    msg = "Informational message."
  )
  validations$exec_error_check <- capture_exec_error(
    file_path = "test.csv",
    msg = "Execution error."
  )

  expect_snapshot(print(validations))
})

test_that("print.hub_validations prints validation-level warnings in box", {
  validations <- new_hub_validations()
  validations$test_check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "passed."
  )

  # Attach a validation-level warning
  warning <- capture_validation_warning(
    msg = "Config files modified: tasks.json",
    where = "hub-config",
    config_files = c("tasks.json")
  )
  attr(validations, "warnings") <- list(warning)

  expect_snapshot(print(validations))
})

test_that("print.hub_validations prints multiple validation-level warnings", {
  validations <- new_hub_validations()
  validations$test_check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "passed."
  )

  # Attach multiple warnings
  warnings <- list(
    capture_validation_warning(msg = "Warning one"),
    capture_validation_warning(msg = "Warning two")
  )
  attr(validations, "warnings") <- warnings

  expect_snapshot(print(validations))
})

test_that("print.hub_validations show_check_warnings displays check-level warnings", {
  validations <- new_hub_validations()

  # Create a check with an attached warning
  check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "passed."
  )
  check$warnings <- list(
    capture_validation_warning(msg = "Check-level warning here")
  )
  validations$test_check <- check

  # Without show_check_warnings, check-level warnings should not appear
  expect_snapshot(print(validations))

  # With show_check_warnings, check-level warnings should appear
  expect_snapshot(print(validations, show_check_warnings = TRUE))
})

test_that("print.hub_validations with both validation and check-level warnings", {
  validations <- new_hub_validations()

  # Create a check with an attached warning
  check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "passed."
  )
  check$warnings <- list(
    capture_validation_warning(msg = "Check-level warning")
  )
  validations$test_check <- check

  # Attach validation-level warning
  attr(validations, "warnings") <- list(
    capture_validation_warning(msg = "Validation-level warning")
  )

  # Validation-level warning always shown, check-level only with show_check_warnings
  expect_snapshot(print(validations))
  expect_snapshot(print(validations, show_check_warnings = TRUE))
})

test_that("combine merges warnings from multiple hub_validations objects", {
  v1 <- new_hub_validations()
  v1$check1 <- capture_check_cnd(
    check = TRUE,
    file_path = "a.csv",
    msg_subject = "A",
    msg_attribute = "ok."
  )
  attr(v1, "warnings") <- list(
    capture_validation_warning(msg = "Warning from v1")
  )

  v2 <- new_hub_validations()
  v2$check2 <- capture_check_cnd(
    check = TRUE,
    file_path = "b.csv",
    msg_subject = "B",
    msg_attribute = "ok."
  )
  attr(v2, "warnings") <- list(
    capture_validation_warning(msg = "Warning from v2")
  )

  combined <- combine(v1, v2)

  # Should have 2 warnings

  expect_length(attr(combined, "warnings"), 2)

  expect_snapshot(print(combined))
})

test_that("print.hub_validations works without warnings", {
  validations <- new_hub_validations()
  validations$test_check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "passed."
  )

  # No warnings attached - should print normally
  expect_snapshot(print(validations))
})

test_that("check_pr_config_modified detects modified config files", {
  # Create a mock pr_df with modified config files
  pr_df <- tibble::tibble(
    filename = c(
      "hub-config/tasks.json",
      "hub-config/admin.json",
      "model-output/team1/2022-01-01-team1-model.csv",
      "hub-config/new-file.json"
    ),
    status = c("modified", "renamed", "added", "added")
  )

  warning <- check_pr_config_modified(pr_df)

  expect_s3_class(warning, "validation_warning")
  expect_equal(warning$where, "hub-config")
  expect_equal(
    warning$config_files,
    c("hub-config/tasks.json", "hub-config/admin.json")
  )
  expect_match(warning$message, "Hub config file")
})

test_that("check_pr_config_modified returns NULL when config files only added not modified", {
  pr_df <- tibble::tibble(
    filename = c(
      "model-output/team1/2022-01-01-team1-model.csv",
      "hub-config/new-file.json"
    ),
    status = c("added", "added")
  )

  warning <- check_pr_config_modified(pr_df)

  expect_null(warning)
})

test_that("check_for_errors prints validation-level warnings", {
  validations <- new_hub_validations()
  validations$test_check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "passed."
  )

  attr(validations, "warnings") <- list(
    capture_validation_warning(msg = "Validation-level warning")
  )

  # Validation-level warnings should appear with verbose = TRUE

  expect_snapshot(check_for_errors(validations, verbose = TRUE))
})

test_that("check_for_errors show_warnings displays check-level warnings", {
  validations <- new_hub_validations()

  check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Test",
    msg_attribute = "passed."
  )
  check$warnings <- list(
    capture_validation_warning(msg = "Check-level warning")
  )
  validations$test_check <- check

  # Add validation-level warning too
  attr(validations, "warnings") <- list(
    capture_validation_warning(msg = "Validation-level warning")
  )

  # Without show_warnings, check-level warnings hidden but validation-level shown
  expect_snapshot(check_for_errors(validations, verbose = TRUE))

  # With show_warnings, both levels shown
  expect_snapshot(check_for_errors(
    validations,
    verbose = TRUE,
    show_warnings = TRUE
  ))
})

test_that("check_for_errors shows warning box once with failures", {
  validations <- new_hub_validations()

  # Add validation-level warning
  attr(validations, "warnings") <- list(
    capture_validation_warning(msg = "Validation-level warning")
  )

  # Add a passing check
  validations$pass_check <- capture_check_cnd(
    check = TRUE,
    file_path = "test.csv",
    msg_subject = "Pass",
    msg_attribute = "ok."
  )

  # Add a failing check
  validations$fail_check <- capture_check_cnd(
    check = FALSE,
    file_path = "test.csv",
    msg_subject = "Fail",
    msg_attribute = "not ok."
  )

  # Warning box should appear once before failures, not in verbose section
  expect_snapshot(
    error = TRUE,
    check_for_errors(validations, verbose = TRUE)
  )
})
