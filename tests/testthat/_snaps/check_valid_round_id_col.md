# check_valid_round_id_col works

    Code
      check_valid_round_id_col(tbl = tbl, file_path = file_path, hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      `round_id_col` name is valid.

---

    Code
      str(check_valid_round_id_col(tbl = tbl, file_path = file_path, hub_path = hub_path))
    Output
      List of 4
       $ message       : chr "`round_id_col` name is valid. \n "
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ call          : chr "check_valid_round_id_col"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

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
      str(check_valid_round_id_col(tbl = tbl, round_id_col = "origin_date",
        file_path = file_path, hub_path = hub_path))
    Output
      List of 4
       $ message       : chr "`round_id_col` name is valid. \n "
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ call          : chr "check_valid_round_id_col"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

---

    Code
      check_valid_round_id_col(tbl = tbl, file_path = file_path, hub_path = hub_path,
        round_id_col = "random_column")
    Output
      <warning/check_failure>
      Warning:
      `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", "location", and "age_group" not "random_column".

