# capture_check_cnd works

    Code
      capture_check_cnd(check = TRUE, file_path = "test/file.csv", msg_subject = "{.var round_id}",
        msg_attribute = "valid.", error = FALSE)
    Output
      <message/check_success>
      Message:
      `round_id` is valid.

---

    Code
      capture_check_cnd(check = FALSE, file_path = "test/file.csv", msg_subject = "{.var round_id}",
        msg_attribute = "valid.", error = FALSE, details = "Must be one of {.val {c('A', 'B')}}, not {.val C}")
    Output
      <warning/check_failure>
      Warning:
      `round_id` must be valid.  Must be one of "A" and "B", not "C"

---

    Code
      capture_check_cnd(check = FALSE, file_path = "test/file.csv", msg_subject = "{.var round_id}",
        msg_attribute = "valid.", error = TRUE, details = "Must be one of 'A' or 'B', not 'C'")
    Output
      <error/check_error>
      Error:
      ! `round_id` must be valid.  Must be one of 'A' or 'B', not 'C'

---

    Code
      capture_check_cnd(check = TRUE, file_path = "test/file.csv", msg_subject = "Column names",
        msg_attribute = "consistent with expected round task IDs and std column names.",
        msg_verbs = c("are", "must be"))
    Output
      <message/check_success>
      Message:
      Column names are consistent with expected round task IDs and std column names.

---

    Code
      capture_check_cnd(check = FALSE, file_path = "test/file.csv", msg_subject = "Column names",
        msg_attribute = "consistent with expected round task IDs and std column names.",
        msg_verbs = c("are", "must always be"))
    Output
      <warning/check_failure>
      Warning:
      Column names must always be consistent with expected round task IDs and std column names.

# capture_check_cnd fails correctly

    Code
      capture_check_cnd(check = FALSE, file_path = "test/file.csv", msg_subject = "Column names",
        msg_attribute = "consistent with expected round task IDs and std column names.",
        msg_verbs = 1:2)
    Error <rlang_error>
      `msg_verbs` must be a character vector of length 2, not class <integer> of length 2

---

    Code
      capture_check_cnd(check = FALSE, file_path = "test/file.csv", msg_subject = "Column names",
        msg_attribute = "consistent with expected round task IDs and std column names.",
        msg_verbs = c("are"))
    Error <rlang_error>
      `msg_verbs` must be a character vector of length 2, not class <character> of length 1

