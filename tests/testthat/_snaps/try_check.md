# try_check works

    Code
      try_check(check_config_hub_valid(hub_path), "test_file.csv")
    Output
      <message/check_success>
      Message:
      All hub config files are valid.

---

    Code
      try_check(check_config_hub_valid("random_hub"), "test_file.csv")
    Output
      <error/check_exec_error>
      Error:
      ! EXEC ERROR: In index: 1. --> Assertion on 'hub_path' failed: Directory 'random_hub' does not exist.

---

    Code
      try_check(opt_check_tbl_horizon_timediff(tbl, file_path, hub_path, t0_colname = "random_col1",
        t1_colname = "random_col1", horizon_colname = "horizon", timediff = lubridate::weeks()),
      file_path)
    Output
      <error/check_exec_error>
      Error:
      ! EXEC ERROR: Assertion on 't0_colname' failed: Must be element of set ['forecast_date','target_end_date','horizon','target','location','output_type','output_type_id','value'], but is 'random_col1'.

