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
      <warning/check_failure>
      Warning:
      Values in column `value` are not all valid with respect to modeling task config.  Contains values that cannot be coerced to expected data type "integer" for output type "quantile".Values in column `value` are not all valid with respect to modeling task config.  Value -6 is smaller than allowed minimum value 0 for output type "quantile".

---

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Values in column `value` are not all valid with respect to modeling task config.  Contains values that cannot be coerced to expected data type "integer" for output type "quantile".Values in column `value` are not all valid with respect to modeling task config.  Value -6 is smaller than allowed minimum value 0 for output type "quantile".

