# check_tbl_value_col works

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Values in column `value` all valid with respect to modeling task config.

---

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Values in column `value` all valid with respect to modeling task config.

# check_tbl_value_col errors correctly

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <error/check_failure>
      Error:
      ! Values in column `value` are not all valid with respect to modeling task config.  Value "fail" cannot be coerced to expected data type "integer" for output type "quantile". | Value -6 is smaller than allowed minimum value 0 for output type "quantile".

---

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <error/check_failure>
      Error:
      ! Values in column `value` are not all valid with respect to modeling task config.  Value "fail" cannot be coerced to expected data type "integer" for output type "quantile". | Value -6 is smaller than allowed minimum value 0 for output type "quantile".

# Ignoring derived_task_ids in check_tbl_value_col works

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path, derived_task_ids = "target_end_date")
    Output
      <message/check_success>
      Message:
      Values in column `value` all valid with respect to modeling task config.

