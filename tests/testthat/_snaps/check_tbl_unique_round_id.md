# check_tbl_unique_round_id works

    Code
      check_tbl_unique_round_id(tbl = arrow::read_csv_arrow(system.file(
        "files/2022-10-15-team1-goodmodel.csv", package = "hubValidations")),
      round_id_col = "origin_date", file_path, hub_path)
    Output
      <message/check_success>
      Message:
      `round_id` column "origin_date" contains a single, unique round ID value.

---

    Code
      str(check_tbl_unique_round_id(tbl = arrow::read_csv_arrow(system.file(
        "files/2022-10-15-team1-goodmodel.csv", package = "hubValidations")),
      round_id_col = "origin_date", file_path, hub_path))
    Output
      List of 4
       $ message       : chr "`round_id` column\n                                                       \"origin_date\" contains a single, un"| __truncated__
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

---

    Code
      check_tbl_unique_round_id(tbl = multiple_rids, round_id_col = "origin_date",
        file_path, hub_path)
    Output
      <error/check_error>
      Error:
      ! `round_id` column "origin_date" must contain a single, unique round ID value.  Column actually contains 2 round ID values, 2022-10-15 and 2022-10-08

---

    Code
      check_tbl_unique_round_id(tbl = testthis::read_testdata("multiple_rids",
        subdir = "files"), round_id_col = "random_column", file_path, hub_path)
    Error <rlang_error>
      `round_id_col` must be one of "origin_date", "target", "horizon", "location", "age_group", "output_type", "output_type_id", or "value", not "random_column".

