# execute_custom_checks works

    Code
      res
    Message
      
      -- hub-ensemble/2023-05-08-hub-ensemble.parquet ----
      
      v [horizon_timediff]: Time differences between t0 var `forecast_date` and t1 var `target_end_date` all match expected period of 7d 0H 0M 0S * `horizon`.

---

    Code
      res
    Message
      
      -- hub-ensemble/2023-05-08-hub-ensemble.parquet ----
      
      x [horizon_timediff]: Time differences between t0 var `forecast_date` and t1 var `target_end_date` do not all match expected period of 14d 0H 0M 0S * `horizon`.  t1 var values "2023-05-15 (horizon = 1)" and "2023-05-22 (horizon = 2)" are invalid.

# execute_custom_checks sourcing functions from scripts works

    Code
      validations_src_external
    Message
      
      -- hub-ensemble/2023-05-08-hub-ensemble.parquet ----
      
      i [src_check_works]: Sourcing custom functions WORKS! Also "Extra arguments passed"!!

# execute_custom_checks return early when appropriate

    Code
      early_ret_custom
    Message
      
      -- hub-ensemble/2023-05-08-hub-ensemble.parquet ----
      
      (x) [check_1]: Check failed !  Early return

---

    Code
      early_ret_exec_error
    Message
      
      -- hub-ensemble/2023-05-08-hub-ensemble.parquet ----
      
      # [check_1]: Stop! Early return because of exec error.

---

    Code
      no_early_ret_custom
    Message
      
      -- hub-ensemble/2023-05-08-hub-ensemble.parquet ----
      
      x [check_1]: Check failed !
      v [check_2]: Check passed !

