test_that("capture_check_cnd works", {
  expect_snapshot(
    capture_check_cnd(
      check = TRUE,
      file_path = "test/file.csv",
      msg_subject = "{.var round_id}",
      msg_attribute = "valid.",
      error = FALSE
    )
  )
  expect_snapshot(
    capture_check_cnd(
      check = FALSE,
      file_path = "test/file.csv",
      msg_subject = "{.var round_id}",
      msg_attribute = "valid.",
      error = FALSE,
      details = "Must be one of {.val {c('A', 'B')}}, not {.val C}"
    )
  )
  expect_snapshot(
    capture_check_cnd(
      check = FALSE,
      file_path = "test/file.csv",
      msg_subject = "{.var round_id}",
      msg_attribute = "valid.",
      error = TRUE,
      details = "Must be one of 'A' or 'B', not 'C'"
    )
  )
  expect_snapshot(
    capture_check_cnd(
      check = TRUE,
      file_path = "test/file.csv",
      msg_subject = "Column names",
      msg_attribute = "consistent with expected round task IDs and std column names.",
      msg_verbs = c("are", "must be")
    )
  )
  expect_snapshot(
    capture_check_cnd(
      check = FALSE,
      file_path = "test/file.csv",
      msg_subject = "Column names",
      msg_attribute = "consistent with expected round task IDs and std column names.",
      msg_verbs = c("are", "must always be")
    )
  )
  expect_snapshot(
    str(
      capture_check_cnd(
        check = FALSE,
        file_path = "test/file.csv",
        msg_subject = "Column names",
        msg_attribute = "consistent with expected round task IDs and std column names.",
        msg_verbs = c("are", "must always be")
      )
    )
  )
})

test_that("capture_check_cnd fails correctly", {
  expect_snapshot(
    capture_check_cnd(
      check = FALSE,
      file_path = "test/file.csv",
      msg_subject = "Column names",
      msg_attribute = "consistent with expected round task IDs and std column names.",
      msg_verbs = 1:2
    ),
    error = TRUE
  )
  expect_snapshot(
    capture_check_cnd(
      check = FALSE,
      file_path = "test/file.csv",
      msg_subject = "Column names",
      msg_attribute = "consistent with expected round task IDs and std column names.",
      msg_verbs = c("are")
    ),
    error = TRUE
  )
})

test_that("capture_check_cnd works correctly", {
  expect_snapshot(
    capture_check_info(
      file_path = "test/file.csv",
      msg = "Check {.code check_tbl_unique_round_id} only applicable to rounds
        where {.code round_id_from_variable} is {.code TRUE}. Check skipped."
    )
  )
})
