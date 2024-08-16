# check_tbl_values works

    Code
      check_tbl_values(tbl = tbl, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      `tbl` contains valid values/value combinations.

---

    Code
      check_tbl_values(tbl = tbl, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <error/check_error>
      Error:
      ! `tbl` contains invalid values/value combinations.  Column `horizon` contains invalid value "11".

# check_tbl_values works with v3 spec samples

    Code
      check_tbl_values(tbl = tbl, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      `tbl` contains valid values/value combinations.

---

    Code
      check_tbl_values(tbl = tbl, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <error/check_error>
      Error:
      ! `tbl` contains invalid values/value combinations.  Column `horizon` contains invalid values "11" and "12".

# Ignoring derived_task_ids in check_tbl_values works

    Code
      check_tbl_values(tbl, round_id, file_path, hub_path, derived_task_ids = "target_end_date")
    Output
      <message/check_success>
      Message:
      `tbl` contains valid values/value combinations.

---

    Code
      check_tbl_values(tbl, round_id, file_path, hub_path, derived_task_ids = "target_end_date")
    Output
      <error/check_error>
      Error:
      ! `tbl` contains invalid values/value combinations.  Column `horizon` contains invalid value "9". Additionally row 2 contains invalid combinations of valid values.  See `error_tbl` for details.

---

    Code
      check_tbl_values(tbl, round_id, file_path, hub_path, derived_task_ids = "target_end_date")$
        error_tbl
    Output
      # A tibble: 1 x 7
        location reference_date horizon target_end_date target          output_type
        <chr>    <chr>          <chr>   <chr>           <chr>           <chr>      
      1 US       2022-10-22     1       2022-10-29      wk inc flu hosp pmf        
      # i 1 more variable: output_type_id <chr>

