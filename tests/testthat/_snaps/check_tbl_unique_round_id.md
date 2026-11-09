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

