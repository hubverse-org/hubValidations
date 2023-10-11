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

---

    Code
      check_tbl_col_types(tbl, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Column data types do not match hub schema.  `NA ` should be "NA " not "NA ", `NA ` should be "NA " not "NA ", `horizon ` should be "double " not "integer ", `output_type_id ` should be "double " not "character ", `value ` should be "integer " not "double "

