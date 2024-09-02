# check_tbl_rows_unique works

    Code
      check_tbl_rows_unique(tbl, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      All combinations of task ID column/`output_type`/`output_type_id` values are unique.

---

    Code
      check_tbl_rows_unique(rbind(tbl, tbl[c(5, 9), ]), file_path, hub_path)
    Output
      <error/check_failure>
      Error:
      ! All combinations of task ID column/`output_type`/`output_type_id` values must be unique.  Rows containing duplicate combinations: 48 and 49

