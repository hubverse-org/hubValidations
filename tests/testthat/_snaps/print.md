# print.hub_validations prints all check types correctly

    Code
      print(validations)
    Message
      
      -- test.csv ----
      
      v [success_check]: Test is passed.
      x [failure_check]: Test must be failed.
      (x) [error_check]: Test must be errored.
      i [info_check]: Informational message.
      # [exec_error_check]: Execution error.

# print.hub_validations prints validation-level warnings in box

    Code
      print(validations)
    Output
      +-------------------------------------+
      | ! Warnings                          |
      | • Config files modified: tasks.json |
      +-------------------------------------+
    Message
      
      
      -- test.csv ----
      
      v [test_check]: Test is passed.

# print.hub_validations prints multiple validation-level warnings

    Code
      print(validations)
    Output
      +---------------+
      | ! Warnings    |
      | • Warning one |
      | • Warning two |
      +---------------+
    Message
      
      
      -- test.csv ----
      
      v [test_check]: Test is passed.

# print.hub_validations show_check_warnings displays check-level warnings

    Code
      print(validations)
    Message
      
      -- test.csv ----
      
      v [test_check]: Test is passed.

---

    Code
      print(validations, show_check_warnings = TRUE)
    Message
      
      -- test.csv ----
      
      v [test_check]: Test is passed.
          ! Check-level warning here

# print.hub_validations with both validation and check-level warnings

    Code
      print(validations)
    Output
      +----------------------------+
      | ! Warnings                 |
      | • Validation-level warning |
      +----------------------------+
    Message
      
      
      -- test.csv ----
      
      v [test_check]: Test is passed.

---

    Code
      print(validations, show_check_warnings = TRUE)
    Output
      +----------------------------+
      | ! Warnings                 |
      | • Validation-level warning |
      +----------------------------+
    Message
      
      
      -- test.csv ----
      
      v [test_check]: Test is passed.
          ! Check-level warning

# combine merges warnings from multiple hub_validations objects

    Code
      print(combined)
    Output
      +-------------------+
      | ! Warnings        |
      | • Warning from v1 |
      | • Warning from v2 |
      +-------------------+
    Message
      
      
      -- a.csv ----
      
      v [check1]: A is ok.
      
      -- b.csv ----
      
      v [check2]: B is ok.

# print.hub_validations works without warnings

    Code
      print(validations)
    Message
      
      -- test.csv ----
      
      v [test_check]: Test is passed.

# check_for_errors prints validation-level warnings

    Code
      check_for_errors(validations, verbose = TRUE)
    Message
      
      -- Individual check results --
      
      -- test.csv ----
      
      v [test_check]: Test is passed.
      
      -- Overall validation result ---------------------------------------------------
    Output
      +----------------------------+
      | ! Warnings                 |
      | • Validation-level warning |
      +----------------------------+
    Message
      
      v All validation checks have been successful.

# check_for_errors show_warnings displays check-level warnings

    Code
      check_for_errors(validations, verbose = TRUE)
    Message
      
      -- Individual check results --
      
      -- test.csv ----
      
      v [test_check]: Test is passed.
      
      -- Overall validation result ---------------------------------------------------
    Output
      +----------------------------+
      | ! Warnings                 |
      | • Validation-level warning |
      +----------------------------+
    Message
      
      v All validation checks have been successful.

---

    Code
      check_for_errors(validations, verbose = TRUE, show_warnings = TRUE)
    Message
      
      -- Individual check results --
      
      -- test.csv ----
      
      v [test_check]: Test is passed.
          ! Check-level warning
      
      -- Overall validation result ---------------------------------------------------
    Output
      +----------------------------+
      | ! Warnings                 |
      | • Validation-level warning |
      +----------------------------+
    Message
      
      v All validation checks have been successful.

# check_for_errors shows warning box once with failures

    Code
      check_for_errors(validations, verbose = TRUE)
    Message
      
      -- Individual check results --
      
      -- test.csv ----
      
      v [pass_check]: Pass is ok.
      x [fail_check]: Fail must be not ok.
      
      -- Overall validation result ---------------------------------------------------
    Output
      +----------------------------+
      | ! Warnings                 |
      | • Validation-level warning |
      +----------------------------+
    Message
      
      
      -- test.csv ----
      
      x [fail_check]: Fail must be not ok.
    Condition
      Error in `check_for_errors()`:
      ! 
      The validation checks produced some failures/errors reported above.

