# check_tbl_values_required works with 1 model task & completely opt cols

    Code
      check_tbl_values_required(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Required task ID/output type/output type ID combinations all present.

---

    Code
      str(missing_req_block)
    Output
      List of 7
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ missing       : tibble [23 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ origin_date   : Date[1:23], format: "2022-10-08" "2022-10-08" ...
        ..$ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
        ..$ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
        ..$ location      : chr [1:23] "US" "US" "US" "US" ...
        ..$ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
        ..$ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ call          : chr "check_tbl_values_required"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

---

    Code
      str(res_missing_otid)
    Output
      List of 7
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ missing       : tibble [3 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ origin_date   : Date[1:3], format: "2022-10-08" "2022-10-08" ...
        ..$ target        : chr [1:3] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp"
        ..$ horizon       : int [1:3] 1 1 1
        ..$ location      : chr [1:3] "02" "02" "02"
        ..$ output_type   : chr [1:3] "quantile" "quantile" "quantile"
        ..$ output_type_id: num [1:3] 0.01 0.025 0.05
       $ call          : chr "check_tbl_values_required"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

# check_tbl_values_required works with 2 separate model tasks & completely missing cols

    Code
      check_tbl_values_required(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Required task ID/output type/output type ID combinations all present.

---

    Code
      str(missing_required)
    Output
      List of 7
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ missing       : tibble [2 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : Date[1:2], format: "2023-05-08" "2023-05-08"
        ..$ horizon       : int [1:2] 2 2
        ..$ target        : chr [1:2] "wk ahead inc flu hosp" "wk ahead inc flu hosp"
        ..$ location      : chr [1:2] "US" "US"
        ..$ output_type   : chr [1:2] "quantile" "quantile"
        ..$ output_type_id: chr [1:2] "0.01" "0.025"
       $ call          : chr "check_tbl_values_required"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

---

    Code
      str(missing_opt_otid)
    Output
      List of 7
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ missing       : tibble [2 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : Date[1:2], format: "2023-05-08" "2023-05-08"
        ..$ horizon       : int [1:2] 1 1
        ..$ target        : chr [1:2] "wk ahead inc flu hosp" "wk ahead inc flu hosp"
        ..$ location      : chr [1:2] "US" "US"
        ..$ output_type   : chr [1:2] "quantile" "quantile"
        ..$ output_type_id: chr [1:2] "0.01" "0.025"
       $ call          : chr "check_tbl_values_required"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

---

    Code
      str(missing_pmf)
    Output
      List of 7
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ missing       : tibble [4 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : Date[1:4], format: "2023-05-08" "2023-05-08" ...
        ..$ horizon       : int [1:4] 2 2 2 2
        ..$ target        : chr [1:4] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change"
        ..$ location      : chr [1:4] "US" "US" "US" "US"
        ..$ output_type   : chr [1:4] "pmf" "pmf" "pmf" "pmf"
        ..$ output_type_id: chr [1:4] "decrease" "stable" "increase" "large_increase"
       $ call          : chr "check_tbl_values_required"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

---

    Code
      str(missing_horizon)
    Output
      List of 7
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ missing       : tibble [9 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : Date[1:9], format: "2023-05-08" "2023-05-08" ...
        ..$ horizon       : int [1:9] 1 1 1 1 2 2 2 2 2
        ..$ target        : chr [1:9] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
        ..$ location      : chr [1:9] "US" "US" "US" "US" ...
        ..$ output_type   : chr [1:9] "pmf" "pmf" "pmf" "pmf" ...
        ..$ output_type_id: chr [1:9] "decrease" "stable" "increase" "large_increase" ...
       $ call          : chr "check_tbl_values_required"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

# check_tbl_values_required works with v3 spec samples

    Code
      check_tbl_values_required(tbl = tbl, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      Required task ID/output type/output type ID combinations all present.

---

    Code
      check_tbl_values_required(tbl = tbl, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <error/check_failure>
      Error:
      ! Required task ID/output type/output type ID combinations missing.  See `missing` attribute for details.

---

    Code
      missing
    Output
      # A tibble: 21 x 7
         location reference_date horizon target_end_date target            output_type
         <chr>    <date>           <int> <date>          <chr>             <chr>      
       1 US       2022-10-22           0 2022-10-22      wk flu hosp rate~ pmf        
       2 US       2022-10-22           0 2022-10-22      wk flu hosp rate~ pmf        
       3 US       2022-10-22           0 2022-10-22      wk flu hosp rate~ pmf        
       4 US       2022-10-22           0 2022-10-22      wk flu hosp rate~ pmf        
       5 US       2022-10-22           1 2022-10-29      wk flu hosp rate~ pmf        
       6 US       2022-10-22           1 2022-10-29      wk flu hosp rate~ pmf        
       7 US       2022-10-22           1 2022-10-29      wk flu hosp rate~ pmf        
       8 US       2022-10-22           1 2022-10-29      wk flu hosp rate~ pmf        
       9 US       2022-10-22           2 2022-11-05      wk flu hosp rate~ pmf        
      10 US       2022-10-22           2 2022-11-05      wk flu hosp rate~ pmf        
      # i 11 more rows
      # i 1 more variable: output_type_id <chr>

# Ignoring derived_task_ids in check_tbl_values_required works

    Code
      check_tbl_values_required(tbl, round_id, file_path, hub_path, derived_task_ids = "target_end_date")
    Output
      <message/check_success>
      Message:
      Required task ID/output type/output type ID combinations all present.

# (#123) check_tbl_values_required works with all optional output types

    Code
      opt_output_type_ids_result
    Output
      <error/check_failure>
      Error:
      ! Required task ID/output type/output type ID combinations missing.  See `missing` attribute for details.

---

    Code
      opt_output_type_ids_result$missing
    Output
      # A tibble: 168 x 6
         nowcast_date target_date clade location output_type output_type_id
         <date>       <date>      <chr> <chr>    <chr>       <chr>         
       1 2024-10-02   2024-09-01  24A   AL       sample      <NA>          
       2 2024-10-02   2024-09-01  24B   AL       sample      <NA>          
       3 2024-10-02   2024-09-01  24A   CA       sample      <NA>          
       4 2024-10-02   2024-09-01  24B   CA       sample      <NA>          
       5 2024-10-02   2024-09-02  24A   AL       sample      <NA>          
       6 2024-10-02   2024-09-02  24B   AL       sample      <NA>          
       7 2024-10-02   2024-09-02  24A   CA       sample      <NA>          
       8 2024-10-02   2024-09-02  24B   CA       sample      <NA>          
       9 2024-10-02   2024-09-03  24A   AL       sample      <NA>          
      10 2024-10-02   2024-09-03  24B   AL       sample      <NA>          
      # i 158 more rows

---

    Code
      check_for_errors(validate_submission(hub_path, file_path,
        skip_submit_window_check = TRUE))
    Message
      
      -- 2024-10-02-UMass-HMLR.parquet ----
      
      x [req_vals]: Required task ID/output type/output type ID combinations missing.  See `missing` attribute for details.
    Condition
      Error in `check_for_errors()`:
      ! 
      The validation checks produced some failures/errors reported above.

