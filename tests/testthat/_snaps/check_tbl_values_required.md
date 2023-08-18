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
      List of 5
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ missing       : tibble [23 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ origin_date   : Date[1:23], format: "2022-10-08" "2022-10-08" ...
        ..$ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
        ..$ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
        ..$ location      : chr [1:23] "US" "US" "US" "US" ...
        ..$ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
        ..$ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

---

    Code
      str(res_missing_otid)
    Output
      List of 5
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ missing       : tibble [3 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ origin_date   : Date[1:3], format: "2022-10-08" "2022-10-08" ...
        ..$ target        : chr [1:3] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp"
        ..$ horizon       : int [1:3] 1 1 1
        ..$ location      : chr [1:3] "02" "02" "02"
        ..$ output_type   : chr [1:3] "quantile" "quantile" "quantile"
        ..$ output_type_id: num [1:3] 0.01 0.025 0.05
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

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
      List of 5
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ missing       : tibble [2 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : Date[1:2], format: "2023-05-08" "2023-05-08"
        ..$ horizon       : int [1:2] 2 2
        ..$ target        : chr [1:2] "wk ahead inc flu hosp" "wk ahead inc flu hosp"
        ..$ location      : chr [1:2] "US" "US"
        ..$ output_type   : chr [1:2] "quantile" "quantile"
        ..$ output_type_id: chr [1:2] "0.01" "0.025"
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

---

    Code
      str(missing_opt_otid)
    Output
      List of 5
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ missing       : tibble [2 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : Date[1:2], format: "2023-05-08" "2023-05-08"
        ..$ horizon       : int [1:2] 1 1
        ..$ target        : chr [1:2] "wk ahead inc flu hosp" "wk ahead inc flu hosp"
        ..$ location      : chr [1:2] "US" "US"
        ..$ output_type   : chr [1:2] "quantile" "quantile"
        ..$ output_type_id: chr [1:2] "0.01" "0.025"
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

---

    Code
      str(missing_pmf)
    Output
      List of 5
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ missing       : tibble [4 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : Date[1:4], format: "2023-05-08" "2023-05-08" ...
        ..$ horizon       : int [1:4] 2 2 2 2
        ..$ target        : chr [1:4] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change"
        ..$ location      : chr [1:4] "US" "US" "US" "US"
        ..$ output_type   : chr [1:4] "pmf" "pmf" "pmf" "pmf"
        ..$ output_type_id: chr [1:4] "decrease" "stable" "increase" "large_increase"
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

---

    Code
      str(missing_horizon)
    Output
      List of 5
       $ message       : chr "Required task ID/output type/output type ID combinations missing.  \n See `missing` attribute for details."
       $ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
       $ missing       : tibble [9 x 6] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : Date[1:9], format: "2023-05-08" "2023-05-08" ...
        ..$ horizon       : int [1:9] 1 1 1 1 2 2 2 2 2
        ..$ target        : chr [1:9] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
        ..$ location      : chr [1:9] "US" "US" "US" "US" ...
        ..$ output_type   : chr [1:9] "pmf" "pmf" "pmf" "pmf" ...
        ..$ output_type_id: chr [1:9] "decrease" "stable" "increase" "large_increase" ...
       $ call          : NULL
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

