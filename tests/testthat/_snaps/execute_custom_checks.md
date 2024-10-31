# execute_custom_checks works

    Code
      str(test_custom_checks_caller(validations_cfg_path = testthat::test_path(
        "testdata", "config", "validations.yml")))
    Output
      List of 1
       $ horizon_timediff:List of 4
        ..$ message       : chr "Time differences between t0 var `forecast_date` and t1 var\n        `target_end_date` all match expected period"| __truncated__
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : NULL
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(test_custom_checks_caller(validations_cfg_path = testthat::test_path(
        "testdata", "config", "validations-error.yml")))
    Output
      Classes 'hub_validations', 'list'  hidden list of 1
       $ horizon_timediff:List of 6
        ..$ message       : chr "Time differences between t0 var `forecast_date` and t1 var\n        `target_end_date` do not all match expected"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : NULL
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

# execute_custom_checks sourcing functions from scripts works

    Code
      validations_src_external
    Message
      
      -- 2023-05-08-hub-ensemble.parquet ----
      
      i [src_check_works]: Sourcing custom functions WORKS! Also "Extra arguments passed"!!

# execute_custom_checks return early when appropriate

    Code
      early_ret_custom
    Message
      
      -- 2023-05-08-hub-ensemble.parquet ----
      
      (x) [check_1]: Check failed !  Early return

---

    Code
      early_ret_exec_error
    Message
      
      -- 2023-05-08-hub-ensemble.parquet ----
      
      [check_1]: Stop! Early return because of exec error.

---

    Code
      no_early_ret_custom
    Message
      
      -- 2023-05-08-hub-ensemble.parquet ----
      
      x [check_1]: Check failed !
      v [check_2]: Check passed !

