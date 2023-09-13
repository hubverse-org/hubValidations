# cfg_check_tbl_col_timediff works

    Code
      cfg_check_tbl_col_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date", timediff = lubridate::weeks(2))
    Output
      <message/check_success>
      Message:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` all match expected period of 14d 0H 0M 0S.

---

    Code
      cfg_check_tbl_col_timediff(tbl_chr, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date", timediff = lubridate::weeks(2))
    Output
      <message/check_success>
      Message:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` all match expected period of 14d 0H 0M 0S.

---

    Code
      cfg_check_tbl_col_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date", timediff = lubridate::weeks(2))
    Output
      <warning/check_failure>
      Warning:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` do not all match expected period of 14d 0H 0M 0S.  t1 var value 2023-05-15 invalid.

# cfg_check_tbl_col_timediff fails correctly

    Code
      cfg_check_tbl_col_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_dates", timediff = lubridate::weeks(2))
    Error <simpleError>
      Assertion on 't1_colname' failed: Must be element of set {'forecast_date','target_end_date','horizon','target','location','output_type','output_type_id','value'}, but is 'target_end_dates'.

---

    Code
      cfg_check_tbl_col_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = c("target_end_date", "forecast_date"), timediff = lubridate::weeks(
          2))
    Error <simpleError>
      Assertion on 't1_colname' failed: Must have length 1, but has length 2.

---

    Code
      cfg_check_tbl_col_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date", timediff = 14L)
    Error <simpleError>
      Assertion on 'timediff' failed: Must inherit from class 'Period', but has class 'integer'.

---

    Code
      cfg_check_tbl_col_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date", timediff = lubridate::weeks(2))
    Error <rlang_error>
      Column `colname` must be configured as <Date> not <character>.

