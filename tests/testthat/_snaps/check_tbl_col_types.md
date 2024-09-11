# check_tbl_col_types works

    Code
      check_tbl_col_types(tbl, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

---

    Code
      check_tbl_col_types(tbl, file_path, hub_path)
    Output
      <error/check_failure>
      Error:
      ! Column data types do not match hub schema.  `origin_date` should be "character" not "Date", `horizon` should be "double" not "integer".

# Check '06' location value validated correctly in check_tbl_col_types

    Code
      check_tbl_col_types(tbl, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

# check_tbl_col_types on datetimes doesn't cause exec error

    Code
      check_tbl_col_types(tbl, file_path, hub_path)
    Output
      <error/check_failure>
      Error:
      ! Column data types do not match hub schema.  `origin_date` should be "Date" not "POSIXct/POSIXt".

