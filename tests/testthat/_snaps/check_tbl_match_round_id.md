# check_tbl_match_round_id works

    Code
      check_tbl_match_round_id(tbl = tbl, file_path = file_path, hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      All `round_id_col` "origin_date" values match submission `round_id` from file name.

---

    Code
      check_tbl_match_round_id(tbl = tbl, file_path = file_path, hub_path = hub_path,
        round_id_col = "origin_date")
    Output
      <message/check_success>
      Message:
      All `round_id_col` "origin_date" values match submission `round_id` from file name.

# check_tbl_match_round_id fails correctly

    Code
      check_tbl_match_round_id(tbl = read_model_out_file(file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        hub_path), file_path = file_path, hub_path = hub_path)
    Output
      <error/check_error>
      Error:
      ! All `round_id_col` "origin_date" values must match submission `round_id` from file name.  `round_id` value 2022-10-08 does not match submission `round_id` "2022-10-01"

---

    Code
      check_tbl_match_round_id(tbl = tbl, file_path = file_path, hub_path = hub_path,
        round_id_col = "random_column")
    Output
      <error/check_error>
      Error:
      ! `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", and "location" not "random_column".

