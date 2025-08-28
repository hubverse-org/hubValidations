# new_target_validations works

    Code
      str(new_target_validations())
    Output
       Named list()
       - attr(*, "class")= chr [1:3] "target_validations" "hub_validations" "list"

---

    Code
      str(new_target_validations(target_file_name = check_target_file_name(file_path),
      target_file_ext_valid = check_target_file_ext_valid(file_path)))
    Output
      List of 2
       $ target_file_name     :List of 4
        ..$ message       : chr "Target file path not hive-partitioned. Check skipped."
        ..$ where         : chr "time-series.csv"
        ..$ call          : chr "check_target_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ target_file_ext_valid:List of 4
        ..$ message       : chr "Target data file extension is valid. \n "
        ..$ where         : chr "time-series.csv"
        ..$ call          : chr "check_target_file_ext_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:3] "target_validations" "hub_validations" "list"

# new_target_validations works with hive partitioned target files

    Code
      str(new_target_validations(target_file_name = check_target_file_name(file_path),
      target_file_ext_valid = check_target_file_ext_valid(file_path)))
    Output
      List of 2
       $ target_file_name     :List of 4
        ..$ message       : chr "Hive-style partition file path segments are valid. \n "
        ..$ where         : chr "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"
        ..$ call          : chr "check_target_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ target_file_ext_valid:List of 4
        ..$ message       : chr "Hive-partitioned target data file extension is valid. \n "
        ..$ where         : chr "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"
        ..$ call          : chr "check_target_file_ext_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:3] "target_validations" "hub_validations" "list"

