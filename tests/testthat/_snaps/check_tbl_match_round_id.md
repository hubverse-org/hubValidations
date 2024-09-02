# check_tbl_match_round_id works

    Code
      check_tbl_match_round_id(tbl = tbl, file_path = file_path, hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      All `round_id_col` "origin_date" values match submission `round_id` from file name.

---

    Code
      str(check_tbl_match_round_id(tbl = tbl, file_path = file_path, hub_path = hub_path))
    Output
      List of 4
       $ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ call          : chr "check_tbl_match_round_id"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

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

---

    Code
      str(check_tbl_match_round_id(tbl = tbl, file_path = file_path, hub_path = hub_path,
        round_id_col = "random_column"))
    Output
      List of 6
       $ message       : chr "`round_id_col` name must be valid. \n Must be one of\n                                      \"origin_date\", \""| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "hub-baseline/2022-10-01-hub-baseline.csv"
       $ call          : chr "check_tbl_match_round_id"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

