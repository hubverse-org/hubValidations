# check_tbl_value_col_sum1 works

    Code
      check_tbl_value_col_sum1(tbl, file_path)
    Output
      <message/check_success>
      Message:
      Values in `value` column do sum to 1 for all unique task ID value combination of pmf output types.

# check_tbl_value_col_sum1 errors correctly

    Code
      res
    Output
      <error/check_failure>
      Error:
      ! Values in `value` column do not sum to 1 for all unique task ID value combination of pmf output types.  See `error_tbl` attribute for details.

---

    Code
      res
    Output
      <message/check_success>
      Message:
      Values in `value` column do sum to 1 for all unique task ID value combination of pmf output types.

# check_tbl_value_col_sum1 skips correctly

    Code
      check_tbl_value_col_sum1(tbl, file_path)
    Output
      <message/check_info>
      Message:
      No pmf output types to check for sum of 1. Check skipped.

