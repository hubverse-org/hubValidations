# check_tbl_value_col_ascending works

    Code
      check_tbl_value_col_ascending(tbl, file_path)
    Output
      <message/check_success>
      Message:
      For each unique task ID value/output type combination, all values non-decreasing as output_type_ids increase.

---

    Code
      check_tbl_value_col_ascending(tbl, file_path)
    Output
      <message/check_success>
      Message:
      For each unique task ID value/output type combination, all values non-decreasing as output_type_ids increase.

# check_tbl_value_col_ascending errors correctly

    Code
      str(check_tbl_value_col_ascending(tbl, file_path))
    Output
      List of 5
       $ message       : chr "For each unique task ID value/output type combination, decreasing values detected as output_type_ids increase. "| __truncated__
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ error_tbl     : tibble [1 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ origin_date: Date[1:1], format: "2022-10-08"
        ..$ target     : chr "wk inc flu hosp"
        ..$ horizon    : int 1
        ..$ location   : chr "US"
        ..$ output_type: chr "quantile"
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

---

    Code
      str(check_tbl_value_col_ascending(tbl_error, file_path))
    Output
      List of 5
       $ message       : chr "For each unique task ID value/output type combination, decreasing values detected as output_type_ids increase. "| __truncated__
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ error_tbl     : tibble [1 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date: Date[1:1], format: "2023-05-08"
        ..$ horizon      : int 1
        ..$ target       : chr "wk ahead inc covid hosp"
        ..$ location     : chr "US"
        ..$ output_type  : chr "quantile"
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

---

    Code
      str(check_tbl_value_col_ascending(rbind(tbl, tbl_error), file_path))
    Output
      List of 5
       $ message       : chr "For each unique task ID value/output type combination, decreasing values detected as output_type_ids increase. "| __truncated__
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ error_tbl     : tibble [1 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date: Date[1:1], format: "2023-05-08"
        ..$ horizon      : int 1
        ..$ target       : chr "wk ahead inc covid hosp"
        ..$ location     : chr "US"
        ..$ output_type  : chr "quantile"
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

# check_tbl_value_col_ascending skips correctly

    Code
      check_tbl_value_col_ascending(tbl, file_path)
    Output
      <message/check_info>
      Message:
      No quantile or cdf output types to check for non-descending values. Check skipped.

