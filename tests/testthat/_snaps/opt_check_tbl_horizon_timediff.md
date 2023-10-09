# opt_check_tbl_horizon_timediff works

    Code
      opt_check_tbl_horizon_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date")
    Output
      <message/check_success>
      Message:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` all match expected period of 7d 0H 0M 0S * `horizon`.

---

    Code
      opt_check_tbl_horizon_timediff(tbl_chr, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date")
    Output
      <message/check_success>
      Message:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` all match expected period of 7d 0H 0M 0S * `horizon`.

---

    Code
      opt_check_tbl_horizon_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date")
    Output
      <warning/check_failure>
      Warning:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` do not all match expected period of 7d 0H 0M 0S * `horizon`.  t1 var value "2023-05-22 (horizon = 1)" are invalid.

---

    Code
      opt_check_tbl_horizon_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date", timediff = lubridate::weeks(2))
    Output
      <warning/check_failure>
      Warning:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` do not all match expected period of 14d 0H 0M 0S * `horizon`.  t1 var values "2023-05-15 (horizon = 1)" and "2023-05-22 (horizon = 2)" are invalid.

# opt_check_tbl_horizon_timediff fails correctly

    Code
      opt_check_tbl_horizon_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_dates")
    Condition
      Error in `opt_check_tbl_horizon_timediff()`:
      ! Assertion on 't1_colname' failed: Must be element of set {'forecast_date','target_end_date','horizon','target','location','output_type','output_type_id','value'}, but is 'target_end_dates'.

---

    Code
      opt_check_tbl_horizon_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = c("target_end_date", "forecast_date"))
    Condition
      Error in `opt_check_tbl_horizon_timediff()`:
      ! Assertion on 't1_colname' failed: Must have length 1, but has length 2.

---

    Code
      opt_check_tbl_horizon_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date", timediff = 7L)
    Condition
      Error in `opt_check_tbl_horizon_timediff()`:
      ! Assertion on 'timediff' failed: Must inherit from class 'Period', but has class 'integer'.

---

    Code
      opt_check_tbl_horizon_timediff(tbl, file_path, hub_path, t0_colname = "forecast_date",
        t1_colname = "target_end_date")
    Condition
      Error in `opt_check_tbl_horizon_timediff()`:
      ! Column `colname` must be configured as <Date> not <character>.

