# check_tbl_unique_round_id works

    Code
      check_tbl_unique_round_id(tbl = tbl, file_path = file_path, hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      `round_id` column "origin_date" contains a single, unique round ID value.

---

    Code
      check_tbl_unique_round_id(tbl = tbl, file_path = file_path, hub_path = hub_path,
        round_id_col = "origin_date")
    Output
      <message/check_success>
      Message:
      `round_id` column "origin_date" contains a single, unique round ID value.

---

    Code
      str(check_tbl_unique_round_id(tbl = tbl, round_id_col = "origin_date",
        file_path = file_path, hub_path = hub_path))
    Output
      List of 4
       $ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ call          : chr "check_tbl_unique_round_id"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

# check_tbl_unique_round_id fails correctly

    Code
      check_tbl_unique_round_id(tbl = multiple_rids, file_path = file_path, hub_path = hub_path)
    Output
      <error/check_error>
      Error:
      ! `round_id` column "origin_date" must contain a single, unique round ID value.  Column actually contains 2 round ID values, 2022-10-15 and 2022-10-08

---

    Code
      check_tbl_unique_round_id(tbl = multiple_rids, file_path = file_path, hub_path = hub_path,
        round_id_col = "random_column")
    Output
      <error/check_error>
      Error:
      ! `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", "location", and "age_group" not "random_column".

---

    Code
      str(check_tbl_unique_round_id(tbl = multiple_rids, file_path = file_path,
        hub_path = hub_path, round_id_col = "random_column"))
    Output
      List of 6
       $ message       : chr "`round_id_col` name must be valid. \n Must be one of\n                                      \"origin_date\", \""| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ call          : chr "check_tbl_unique_round_id"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

