# check_tbl_value_col_ascending works

    Code
      check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
    Output
      <message/check_success>
      Message:
      Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.

---

    Code
      check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
    Output
      <message/check_success>
      Message:
      Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.

# check_tbl_value_col_ascending works when output type IDs not ordered

    Code
      check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
    Output
      <message/check_success>
      Message:
      Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.

# check_tbl_value_col_ascending errors correctly

    Code
      str(check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id))
    Output
      List of 7
       $ message       : chr "Values in `value` column are not non-decreasing as output_type_ids increase for all unique task ID\n    value/o"| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ error_tbl     : tibble [1 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ origin_date: Date[1:1], format: "2022-10-08"
        ..$ target     : chr "wk inc flu hosp"
        ..$ horizon    : int 1
        ..$ location   : chr "US"
        ..$ output_type: chr "quantile"
       $ call          : chr "check_tbl_value_col_ascending"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

---

    Code
      str(check_tbl_value_col_ascending(tbl_error, file_path, hub_path, file_meta$
        round_id))
    Output
      List of 7
       $ message       : chr "Values in `value` column are not non-decreasing as output_type_ids increase for all unique task ID\n    value/o"| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ error_tbl     : tibble [1 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date: Date[1:1], format: "2023-05-08"
        ..$ horizon      : int 1
        ..$ target       : chr "wk ahead inc covid hosp"
        ..$ location     : chr "US"
        ..$ output_type  : chr "quantile"
       $ call          : chr "check_tbl_value_col_ascending"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

---

    Code
      str(check_tbl_value_col_ascending(rbind(tbl, tbl_error), file_path, hub_path,
      file_meta$round_id))
    Output
      List of 7
       $ message       : chr "Values in `value` column are not non-decreasing as output_type_ids increase for all unique task ID\n    value/o"| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ error_tbl     : tibble [1 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date: Date[1:1], format: "2023-05-08"
        ..$ horizon      : int 1
        ..$ target       : chr "wk ahead inc covid hosp"
        ..$ location     : chr "US"
        ..$ output_type  : chr "quantile"
       $ call          : chr "check_tbl_value_col_ascending"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

# check_tbl_value_col_ascending skips correctly

    Code
      check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
    Output
      <message/check_info>
      Message:
      No quantile or cdf output types to check for non-descending values. Check skipped.

