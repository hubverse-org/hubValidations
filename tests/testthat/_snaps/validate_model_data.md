# validate_model_data works

    Code
      res$file_read
    Output
      <error/check_error>
      Error:
      ! File could not be read successfully.  No file exists at path 'model-output/2020-10-06-random-path.csv' Please check file path is correct and file can be read using `read_model_out_file()`

---

    Code
      res$valid_round_id_col
    Output
      <error/check_failure>
      Error:
      ! `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", and "location" not "random_col".

---

    Code
      res$unique_round_id
    Output
      <error/check_error>
      Error:
      ! `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", and "location" not "random_col".

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
      
      -- team1-goodmodel/2022-10-08-team1-goodmodel.csv ----
      
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
      v [value_col_non_desc]: Quantile or cdf `value` values increase when ordered by `output_type_id`.
      i [value_col_sum1]: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [ansi]

    Code
      validate_model_data(hub_path, file_path)
    Message
      
      [35m-- [4m[1mteam1-goodmodel/2022-10-08-team1-goodmodel.csv[22m[24m ----[39m
      
      [1m[22m[32mv[39m [90m[file_read][39m: File could be read successfully.
      [1m[22m[32mv[39m [90m[valid_round_id_col][39m: `round_id_col` name is valid.
      [1m[22m[32mv[39m [90m[unique_round_id][39m: `round_id` column [34m"origin_date"[39m contains a single, unique round ID value.
      [1m[22m[32mv[39m [90m[match_round_id][39m: All `round_id_col` [34m"origin_date"[39m values match submission `round_id` from file name.
      [1m[22m[32mv[39m [90m[colnames][39m: Column names are consistent with expected round task IDs and std column names.
      [1m[22m[32mv[39m [90m[col_types][39m: Column data types match hub schema.
      [1m[22m[32mv[39m [90m[valid_vals][39m: `tbl` contains valid values/value combinations.
      [1m[22m[32mv[39m [90m[rows_unique][39m: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      [1m[22m[32mv[39m [90m[req_vals][39m: Required task ID/output type/output type ID combinations all present.
      [1m[22m[32mv[39m [90m[value_col_valid][39m: Values in column `value` all valid with respect to modeling task config.
      [1m[22m[32mv[39m [90m[value_col_non_desc][39m: Quantile or cdf `value` values increase when ordered by `output_type_id`.
      [1m[22m[36mi[39m [90m[value_col_sum1][39m: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [unicode]

    Code
      validate_model_data(hub_path, file_path)
    Message
      
      ── team1-goodmodel/2022-10-08-team1-goodmodel.csv ────
      
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
      ✔ [value_col_non_desc]: Quantile or cdf `value` values increase when ordered by `output_type_id`.
      ℹ [value_col_sum1]: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data print method work [fancy]

    Code
      validate_model_data(hub_path, file_path)
    Message
      
      [35m── [4m[1mteam1-goodmodel/2022-10-08-team1-goodmodel.csv[22m[24m ────[39m
      
      [1m[22m[32m✔[39m [90m[file_read][39m: File could be read successfully.
      [1m[22m[32m✔[39m [90m[valid_round_id_col][39m: `round_id_col` name is valid.
      [1m[22m[32m✔[39m [90m[unique_round_id][39m: `round_id` column [34m"origin_date"[39m contains a single, unique round ID value.
      [1m[22m[32m✔[39m [90m[match_round_id][39m: All `round_id_col` [34m"origin_date"[39m values match submission `round_id` from file name.
      [1m[22m[32m✔[39m [90m[colnames][39m: Column names are consistent with expected round task IDs and std column names.
      [1m[22m[32m✔[39m [90m[col_types][39m: Column data types match hub schema.
      [1m[22m[32m✔[39m [90m[valid_vals][39m: `tbl` contains valid values/value combinations.
      [1m[22m[32m✔[39m [90m[rows_unique][39m: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      [1m[22m[32m✔[39m [90m[req_vals][39m: Required task ID/output type/output type ID combinations all present.
      [1m[22m[32m✔[39m [90m[value_col_valid][39m: Values in column `value` all valid with respect to modeling task config.
      [1m[22m[32m✔[39m [90m[value_col_non_desc][39m: Quantile or cdf `value` values increase when ordered by `output_type_id`.
      [1m[22m[36mℹ[39m [90m[value_col_sum1][39m: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data errors correctly

    Code
      validate_model_data(hub_path, file_path = "random-path.csv")
    Condition
      Error in `parse_file_name()`:
      x File name 'random-path' does not match expected pattern of [round_id]-[team_abbr]-[model_abbr]. Please consult documentation on file name requirements (<https://docs.hubverse.io/en/latest/user-guide/model-output.html#directory-structure>) for details.

