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
      List of 3
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name must be valid. \n Must be one of\n                                      \"origin_date\", \""| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id_col` name must be valid. \n Must be one of\n                                      \"origin_date\", \""| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_warning" "warning" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

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
       $ col_types         :List of 4
        ..$ message       : chr "Column data types do not match hub schema. \n `output_type_id ` should be \"character \" not \"double \""
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...
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
       $ value_col_valid   :List of 4
        ..$ message       : chr "Values in column `value` are not all valid with respect to modeling task config. \n  Values 196.83, 367.89, 244"| __truncated__
        ..$ where         : chr "hub-ensemble/2023-05-08-hub-ensemble.parquet"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...
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
      v 2022-10-08-team1-goodmodel.csv: File could be read successfully.
      v 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.
      v 2022-10-08-team1-goodmodel.csv: `round_id` column "origin_date" contains a single, unique round ID value.
      v 2022-10-08-team1-goodmodel.csv: All `round_id_col` "origin_date" values match submission `round_id` from file name.
      v 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.
      v 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.
      v 2022-10-08-team1-goodmodel.csv: `tbl` contains valid values/value combinations.
      v 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      v 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.
      v 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.
      v 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      i 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

---

    Code
      validate_model_data(hub_path, file_path)
    Output
      ::notice file=test-validate_model_data.R,line=57,endLine=61,col=3,endCol=3::v 2022-10-08-team1-goodmodel.csv: File could be read successfully.%0Av 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.%0Av 2022-10-08-team1-goodmodel.csv: `round_id` column "origin_date" contains a single, unique round ID value.%0Av 2022-10-08-team1-goodmodel.csv: All `round_id_col` "origin_date" values match submission `round_id` from file name.%0Av 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.%0Av 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.%0Av 2022-10-08-team1-goodmodel.csv: `tbl` contains valid values/value combinations.%0Av 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.%0Av 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.%0Av 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.%0Av 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.%0Ai 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [ansi]

    Code
      validate_model_data(hub_path, file_path)
    Message
      [1m[22m[32mv[39m 2022-10-08-team1-goodmodel.csv: File could be read successfully.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: `round_id` column [34m"origin_date"[39m contains a single, unique round ID value.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: All `round_id_col` [34m"origin_date"[39m values match submission `round_id` from file name.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: `tbl` contains valid values/value combinations.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      [36mi[39m 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

---

    Code
      validate_model_data(hub_path, file_path)
    Output
      ::notice file=test-validate_model_data.R,line=57,endLine=61,col=3,endCol=3::v 2022-10-08-team1-goodmodel.csv: File could be read successfully.%0Av 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.%0Av 2022-10-08-team1-goodmodel.csv: `round_id` column [34m"origin_date"[39m contains a single, unique round ID value.%0Av 2022-10-08-team1-goodmodel.csv: All `round_id_col` [34m"origin_date"[39m values match submission `round_id` from file name.%0Av 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.%0Av 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.%0Av 2022-10-08-team1-goodmodel.csv: `tbl` contains valid values/value combinations.%0Av 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.%0Av 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.%0Av 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.%0Av 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.%0Ai 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [unicode]

    Code
      validate_model_data(hub_path, file_path)
    Message
      ✔ 2022-10-08-team1-goodmodel.csv: File could be read successfully.
      ✔ 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.
      ✔ 2022-10-08-team1-goodmodel.csv: `round_id` column "origin_date" contains a single, unique round ID value.
      ✔ 2022-10-08-team1-goodmodel.csv: All `round_id_col` "origin_date" values match submission `round_id` from file name.
      ✔ 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.
      ✔ 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.
      ✔ 2022-10-08-team1-goodmodel.csv: `tbl` contains valid values/value combinations.
      ✔ 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      ✔ 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.
      ✔ 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.
      ✔ 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      ℹ 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

---

    Code
      validate_model_data(hub_path, file_path)
    Output
      ::notice file=test-validate_model_data.R,line=57,endLine=61,col=3,endCol=3::✔ 2022-10-08-team1-goodmodel.csv: File could be read successfully.%0A✔ 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.%0A✔ 2022-10-08-team1-goodmodel.csv: `round_id` column "origin_date" contains a single, unique round ID value.%0A✔ 2022-10-08-team1-goodmodel.csv: All `round_id_col` "origin_date" values match submission `round_id` from file name.%0A✔ 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.%0A✔ 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.%0A✔ 2022-10-08-team1-goodmodel.csv: `tbl` contains valid values/value combinations.%0A✔ 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.%0A✔ 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.%0A✔ 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.%0A✔ 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.%0Aℹ 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [fancy]

    Code
      validate_model_data(hub_path, file_path)
    Message
      [1m[22m[32m✔[39m 2022-10-08-team1-goodmodel.csv: File could be read successfully.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: `round_id` column [34m"origin_date"[39m contains a single, unique round ID value.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: All `round_id_col` [34m"origin_date"[39m values match submission `round_id` from file name.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: `tbl` contains valid values/value combinations.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      [36mℹ[39m 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

---

    Code
      validate_model_data(hub_path, file_path)
    Output
      ::notice file=test-validate_model_data.R,line=57,endLine=61,col=3,endCol=3::✔ 2022-10-08-team1-goodmodel.csv: File could be read successfully.%0A✔ 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.%0A✔ 2022-10-08-team1-goodmodel.csv: `round_id` column [34m"origin_date"[39m contains a single, unique round ID value.%0A✔ 2022-10-08-team1-goodmodel.csv: All `round_id_col` [34m"origin_date"[39m values match submission `round_id` from file name.%0A✔ 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.%0A✔ 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.%0A✔ 2022-10-08-team1-goodmodel.csv: `tbl` contains valid values/value combinations.%0A✔ 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.%0A✔ 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.%0A✔ 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.%0A✔ 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.%0Aℹ 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data errors correctly

    Code
      validate_model_data(hub_path, file_path = "random-path.csv")
    Condition
      Error in `parse_file_name()`:
      ! Could not parse file name 'random-path' for submission metadata. Please consult documentation for file name requirements for correct metadata parsing.

# validate_model_data with v3 sample data works

    Code
      str(validate_model_data(hub_path, file_path, validations_cfg_path = system.file(
        "testhubs/flusight/hub-config/validations.yml", package = "hubValidations")))
    Output
      Classes 'hub_validations', 'list'  hidden list of 17
       $ file_read              :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col     :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id        :List of 4
        ..$ message       : chr "`round_id` column \"reference_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id         :List of 4
        ..$ message       : chr "All `round_id_col` \"reference_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames               :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types              :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals             :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique            :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals               :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
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
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc     :List of 4
        ..$ message       : chr "No quantile or cdf output types to check for non-descending values.\n        Check skipped."
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1         :List of 5
        ..$ message       : chr "Values in `value` column do sum to 1 for all unique task ID value combination of pmf\n    output types. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set:List of 5
        ..$ message       : chr "All samples in a model task conform to single, unique compound task ID set that matches or is\n    coarser than"| __truncated__
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ errors        : Named list()
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid       :List of 5
        ..$ message       : chr "Each sample compound task ID contains single, unique value. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ errors        : NULL
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid   :List of 5
        ..$ message       : chr "Task ID combinations of non compound task id values consistent across modeling task samples. \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ errors        : NULL
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ spl_n                  :List of 5
        ..$ message       : chr "Required samples per compound idx task present.  \n "
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ errors        : NULL
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ horizon_timediff       :List of 6
        ..$ message       : chr "Assertion on 't0_colname' failed: Must be element of set ['location','reference_date','horizon','target_end_dat"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
        ..$ call          : chr "horizon_timediff"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_exec_error" "hub_check" "rlang_error" "error" ...

