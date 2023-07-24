# check_tbl_colnames validates correct files

    Code
      check_tbl_colnames(tbl = arrow::read_csv_arrow(system.file(
        "files/2022-10-15-team1-goodmodel.csv", package = "hubValidations")),
      round_id, config_tasks, file_path)
    Output
      [[1]]
      <message/check_success>
      Message:
      Column names are consistent with expected round task IDs and std column names.
      

---

    Code
      check_tbl_colnames(tbl = arrow::read_parquet(system.file(
        "files/2022-10-15-team1-goodmodel.parquet", package = "hubValidations")),
      round_id, config_tasks, file_path)
    Output
      [[1]]
      <message/check_success>
      Message:
      Column names are consistent with expected round task IDs and std column names.
      

# check_tbl_colnames fails on files

    Code
      check_tbl_colnames(tbl = missing_col, round_id, config_tasks, file_path)
    Output
      [[1]]
      <warning/check_failure>
      Warning:
      Column names must be consistent with expected round task IDs and std column names.  Expected column "age_group" not present in file.
      

