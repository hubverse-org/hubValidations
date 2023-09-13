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
      <warning/check_failure>
      Warning:
      Column data types do not match hub schema.  `origin_date ` should be "character " not "Date ", `horizon ` should be "double " not "integer "

