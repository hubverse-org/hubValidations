# check_valid_round_id_col works

    Code
      check_valid_round_id_col(tbl = tbl, file_path = file_path, hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      `round_id_col` name is valid.

---

    Code
      check_valid_round_id_col(tbl = tbl, file_path = file_path, hub_path = hub_path,
        round_id_col = "origin_date")
    Output
      <message/check_success>
      Message:
      `round_id_col` name is valid.

---

    Code
      check_valid_round_id_col(tbl = tbl, file_path = file_path, hub_path = hub_path,
        round_id_col = "random_column")
    Output
      <error/check_failure>
      Error:
      ! `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", "location", and "age_group" not "random_column".

