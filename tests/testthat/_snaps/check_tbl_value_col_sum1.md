# check_tbl_value_col_sum1 works

    Code
      check_tbl_value_col_sum1(tbl, file_path)
    Output
      <message/check_success>
      Message:
      Values in `value` column do sum to 1 for all unique task ID value combination of pmf output types.

# check_tbl_value_col_sum1 errors correctly

    Code
      str(check_tbl_value_col_sum1(tbl, file_path))
    Output
      List of 7
       $ message       : chr "Values in `value` column do not sum to 1 for all unique task ID value combination of pmf\n    output types. \n "| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "umass-ens/2023-05-08-umass-ens.csv"
       $ error_tbl     : tibble [1 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date: Date[1:1], format: "2023-05-08"
        ..$ horizon      : int 2
        ..$ target       : chr "wk flu hosp rate change"
        ..$ location     : chr "US"
        ..$ output_type  : chr "pmf"
       $ call          : chr "check_tbl_value_col_sum1"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

---

    Code
      str(check_tbl_value_col_sum1(tbl, file_path))
    Output
      List of 7
       $ message       : chr "Values in `value` column do not sum to 1 for all unique task ID value combination of pmf\n    output types. \n "| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "umass-ens/2023-05-08-umass-ens.csv"
       $ error_tbl     : tibble [1 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date: Date[1:1], format: "2023-05-08"
        ..$ horizon      : int 2
        ..$ target       : chr "wk flu hosp rate change"
        ..$ location     : chr "US"
        ..$ output_type  : chr "pmf"
       $ call          : chr "check_tbl_value_col_sum1"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

---

    Code
      str(check_tbl_value_col_sum1(tbl, file_path))
    Output
      List of 5
       $ message       : chr "Values in `value` column do sum to 1 for all unique task ID value combination of pmf\n    output types. \n "
       $ where         : chr "umass-ens/2023-05-08-umass-ens.csv"
       $ error_tbl     : NULL
       $ call          : chr "check_tbl_value_col_sum1"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

# check_tbl_value_col_sum1 skips correctly

    Code
      check_tbl_value_col_sum1(tbl, file_path)
    Output
      <message/check_info>
      Message:
      No pmf output types to check for sum of 1. Check skipped.

