# validate_model_data works

    Code
      str(validate_model_data(hub_path, file_path))
    Output
      List of 12
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ missing       : tibble [0 x 6] (S3: tbl_df/tbl/data.frame)
        .. ..$ origin_date   : chr(0) 
        .. ..$ target        : chr(0) 
        .. ..$ horizon       : chr(0) 
        .. ..$ location      : chr(0) 
        .. ..$ output_type   : chr(0) 
        .. ..$ output_type_id: chr(0) 
        ..$ call          : chr "check_tbl_values_required"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_valid   :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(validate_model_data(hub_path, file_path = "2020-10-06-random-path.csv"))
    Output
      Classes 'hub_validations', 'list'  hidden list of 1
       $ file_read:List of 6
        ..$ message       : chr "File could not be read successfully. \n No file exists at path 'model-output/2020-10-06-random-path.csv'\nPleas"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "2020-10-06-random-path.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

---

    Code
      str(validate_model_data(hub_path, file_path, round_id_col = "random_col"))
    Output
      Classes 'hub_validations', 'list'  hidden list of 3
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 6
        ..$ message       : chr "`round_id_col` name must be valid. \n Must be one of\n                                      \"origin_date\", \""| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ unique_round_id   :List of 6
        ..$ message       : chr "`round_id_col` name must be valid. \n Must be one of\n                                      \"origin_date\", \""| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

---

    Code
      str(validate_model_data(hub_path, file_path))
    Output
      List of 12
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"forecast_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"forecast_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 6
        ..$ message       : chr "Column data types do not match hub schema. \n `output_type_id` should be \"character\" not \"double\"."
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ missing       : tibble [0 x 6] (S3: tbl_df/tbl/data.frame)
        .. ..$ forecast_date : chr(0) 
        .. ..$ horizon       : chr(0) 
        .. ..$ target        : chr(0) 
        .. ..$ location      : chr(0) 
        .. ..$ output_type   : chr(0) 
        .. ..$ output_type_id: chr(0) 
        ..$ call          : chr "check_tbl_values_required"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_valid   :List of 6
        ..$ message       : chr "Values in column `value` are not all valid with respect to modeling task config. \n  Values 196.83, 367.89, 244"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

# validate_model_data with config function works

    Code
      validate_model_data(hub_path, file_path)[["horizon_timediff"]]
    Output
      <message/check_success>
      Message:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` all match expected period of 7d 0H 0M 0S * `horizon`.

---

    Code
      validate_model_data(hub_path, file_path, validations_cfg_path = system.file(
        "testhubs/flusight/hub-config/validations.yml", package = "hubValidations"))[[
        "horizon_timediff"]]
    Output
      <message/check_success>
      Message:
      Time differences between t0 var `forecast_date` and t1 var `target_end_date` all match expected period of 7d 0H 0M 0S * `horizon`.

# validate_model_data print method work [plain]

    Code
      validate_model_data(hub_path, file_path)
    Message
      
      -- 2022-10-08-team1-goodmodel.csv ----
      
      v [file_read]: File could be read successfully.
      v [valid_round_id_col]: `round_id_col` name is valid.
      v [unique_round_id]: `round_id` column "origin_date" contains a single, unique round ID value.
      v [match_round_id]: All `round_id_col` "origin_date" values match submission `round_id` from file name.
      v [colnames]: Column names are consistent with expected round task IDs and std column names.
      v [col_types]: Column data types match hub schema.
      v [valid_vals]: `tbl` contains valid values/value combinations.
      v [rows_unique]: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      v [req_vals]: Required task ID/output type/output type ID combinations all present.
      v [value_col_valid]: Values in column `value` all valid with respect to modeling task config.
      v [value_col_non_desc]: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      i [value_col_sum1]: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [ansi]

    Code
      validate_model_data(hub_path, file_path)
    Message
      
      [96m-- [4m[1m2022-10-08-team1-goodmodel.csv[22m[24m ----[39m
      
      [1m[22m[32mv[39m [90m[file_read][39m: File could be read successfully.
      [32mv[39m [90m[valid_round_id_col][39m: `round_id_col` name is valid.
      [32mv[39m [90m[unique_round_id][39m: `round_id` column [34m"origin_date"[39m contains a single, unique round ID value.
      [32mv[39m [90m[match_round_id][39m: All `round_id_col` [34m"origin_date"[39m values match submission `round_id` from file name.
      [32mv[39m [90m[colnames][39m: Column names are consistent with expected round task IDs and std column names.
      [32mv[39m [90m[col_types][39m: Column data types match hub schema.
      [32mv[39m [90m[valid_vals][39m: `tbl` contains valid values/value combinations.
      [32mv[39m [90m[rows_unique][39m: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      [32mv[39m [90m[req_vals][39m: Required task ID/output type/output type ID combinations all present.
      [32mv[39m [90m[value_col_valid][39m: Values in column `value` all valid with respect to modeling task config.
      [32mv[39m [90m[value_col_non_desc][39m: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      [36mi[39m [90m[value_col_sum1][39m: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [unicode]

    Code
      validate_model_data(hub_path, file_path)
    Message
      
      ── 2022-10-08-team1-goodmodel.csv ────
      
      ✔ [file_read]: File could be read successfully.
      ✔ [valid_round_id_col]: `round_id_col` name is valid.
      ✔ [unique_round_id]: `round_id` column "origin_date" contains a single, unique round ID value.
      ✔ [match_round_id]: All `round_id_col` "origin_date" values match submission `round_id` from file name.
      ✔ [colnames]: Column names are consistent with expected round task IDs and std column names.
      ✔ [col_types]: Column data types match hub schema.
      ✔ [valid_vals]: `tbl` contains valid values/value combinations.
      ✔ [rows_unique]: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      ✔ [req_vals]: Required task ID/output type/output type ID combinations all present.
      ✔ [value_col_valid]: Values in column `value` all valid with respect to modeling task config.
      ✔ [value_col_non_desc]: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      ℹ [value_col_sum1]: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [fancy]

    Code
      validate_model_data(hub_path, file_path)
    Message
      
      [96m── [4m[1m2022-10-08-team1-goodmodel.csv[22m[24m ────[39m
      
      [1m[22m[32m✔[39m [90m[file_read][39m: File could be read successfully.
      [32m✔[39m [90m[valid_round_id_col][39m: `round_id_col` name is valid.
      [32m✔[39m [90m[unique_round_id][39m: `round_id` column [34m"origin_date"[39m contains a single, unique round ID value.
      [32m✔[39m [90m[match_round_id][39m: All `round_id_col` [34m"origin_date"[39m values match submission `round_id` from file name.
      [32m✔[39m [90m[colnames][39m: Column names are consistent with expected round task IDs and std column names.
      [32m✔[39m [90m[col_types][39m: Column data types match hub schema.
      [32m✔[39m [90m[valid_vals][39m: `tbl` contains valid values/value combinations.
      [32m✔[39m [90m[rows_unique][39m: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      [32m✔[39m [90m[req_vals][39m: Required task ID/output type/output type ID combinations all present.
      [32m✔[39m [90m[value_col_valid][39m: Values in column `value` all valid with respect to modeling task config.
      [32m✔[39m [90m[value_col_non_desc][39m: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      [36mℹ[39m [90m[value_col_sum1][39m: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data errors correctly

    Code
      validate_model_data(hub_path, file_path = "random-path.csv")
    Condition
      Error in `parse_file_name()`:
      ! Could not parse file name 'random-path' for submission metadata. Please consult documentation for file name requirements for correct metadata parsing.

# validate_model_data with v3 sample data works

    Code
      str(validate_model_data(hub_path = system.file("testhubs/samples", package = "hubValidations"),
      file_path = "flu-base/2022-10-22-flu-base.csv", validations_cfg_path = system.file(
        "testhubs/samples/hub-config/validations.yml", package = "hubValidations")))
    Output
      List of 17
       $ file_read              :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col     :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id        :List of 4
        ..$ message       : chr "`round_id` column \"reference_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id         :List of 4
        ..$ message       : chr "All `round_id_col` \"reference_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames               :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types              :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals             :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique            :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals               :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ missing       : tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
        .. ..$ location       : chr(0) 
        .. ..$ reference_date : chr(0) 
        .. ..$ horizon        : chr(0) 
        .. ..$ target_end_date: chr(0) 
        .. ..$ target         : chr(0) 
        .. ..$ output_type    : chr(0) 
        .. ..$ output_type_id : chr(0) 
        ..$ call          : chr "check_tbl_values_required"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_valid        :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc     :List of 4
        ..$ message       : chr "No quantile or cdf output types to check for non-descending values.\n        Check skipped."
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1         :List of 5
        ..$ message       : chr "Values in `value` column do sum to 1 for all unique task ID value combination of pmf\n    output types. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set:List of 6
        ..$ message            : chr "All samples in a model task conform to single, unique compound task ID set that matches or is\n    coarser than"| __truncated__
        ..$ where              : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ errors             : NULL
        ..$ compound_taskid_set:List of 2
        .. ..$ 1: NULL
        .. ..$ 2: chr [1:2] "reference_date" "location"
        ..$ call               : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format     : logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid       :List of 5
        ..$ message       : chr "Each sample compound task ID contains single, unique value. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ errors        : NULL
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid   :List of 5
        ..$ message       : chr "Task ID combinations of non compound task id values consistent across modeling task samples. \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ errors        : NULL
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ spl_n                  :List of 5
        ..$ message       : chr "Required samples per compound idx task present.  \n "
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ errors        : NULL
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ horizon_timediff       :List of 4
        ..$ message       : chr "Time differences between t0 var `reference_date` and t1 var\n        `target_end_date` all match expected perio"| __truncated__
        ..$ where         : chr "flu-base/2022-10-22-flu-base.csv"
        ..$ call          : NULL
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

