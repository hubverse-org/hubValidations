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

