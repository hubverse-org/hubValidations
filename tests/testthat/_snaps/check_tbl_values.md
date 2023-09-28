# check_tbl_values works

    Code
      check_tbl_values(tbl = tbl, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      Data rows contain valid value combinations

---

    Code
      check_tbl_values(tbl = tbl, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <error/check_error>
      Error:
      ! Data rows do not contain valid value combinations Affected rows: 1

