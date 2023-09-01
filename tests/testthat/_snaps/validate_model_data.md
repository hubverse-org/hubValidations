# validate_model_data works

    Code
      validate_model_data(hub_path, file_path)
    Message <rlang_message>
      v 2022-10-08-team1-goodmodel.csv: File could be read successfully.
      v 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.
      v 2022-10-08-team1-goodmodel.csv: `round_id` column "origin_date" contains a single, unique round ID value.
      v 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.
      v 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.
      v 2022-10-08-team1-goodmodel.csv: Data rows contain valid value combinations
      v 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      v 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.
      v 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.
      v 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      i 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

---

    Code
      validate_model_data(hub_path, file_path = "2020-10-06-random-path.csv")
    Message <rlang_message>
      x 2020-10-06-random-path.csv: File could not be read successfully.  No file exists at path 'model-output/2020-10-06-random-path.csv' Please check file path is correct and file can be read using `read_model_out_file()`

---

    Code
      validate_model_data(hub_path, file_path, round_id_col = "random_col")
    Message <rlang_message>
      v 2022-10-08-team1-goodmodel.csv: File could be read successfully.
      ! 2022-10-08-team1-goodmodel.csv: `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", and "location" not "random_col".
      x 2022-10-08-team1-goodmodel.csv: `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", and "location" not "random_col".

---

    Code
      validate_model_data(hub_path, file_path)
    Message <rlang_message>
      v 2022-10-08-team1-goodmodel.csv: File could be read successfully.
      v 2022-10-08-team1-goodmodel.csv: `round_id_col` name is valid.
      v 2022-10-08-team1-goodmodel.csv: `round_id` column "origin_date" contains a single, unique round ID value.
      v 2022-10-08-team1-goodmodel.csv: Column names are consistent with expected round task IDs and std column names.
      v 2022-10-08-team1-goodmodel.csv: Column data types match hub schema.
      v 2022-10-08-team1-goodmodel.csv: Data rows contain valid value combinations
      v 2022-10-08-team1-goodmodel.csv: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      v 2022-10-08-team1-goodmodel.csv: Required task ID/output type/output type ID combinations all present.
      v 2022-10-08-team1-goodmodel.csv: Values in column `value` all valid with respect to modeling task config.
      v 2022-10-08-team1-goodmodel.csv: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      i 2022-10-08-team1-goodmodel.csv: No pmf output types to check for sum of 1. Check skipped.

---

    Code
      validate_model_data(hub_path, file_path)
    Message <rlang_message>
      v 2023-05-08-hub-ensemble.parquet: File could be read successfully.
      v 2023-05-08-hub-ensemble.parquet: `round_id_col` name is valid.
      v 2023-05-08-hub-ensemble.parquet: `round_id` column "forecast_date" contains a single, unique round ID value.
      v 2023-05-08-hub-ensemble.parquet: Column names are consistent with expected round task IDs and std column names.
      ! 2023-05-08-hub-ensemble.parquet: Column data types do not match hub schema.  `output_type_id ` should be "character " not "double "
      v 2023-05-08-hub-ensemble.parquet: Data rows contain valid value combinations
      v 2023-05-08-hub-ensemble.parquet: All combinations of task ID column/`output_type`/`output_type_id` values are unique.
      v 2023-05-08-hub-ensemble.parquet: Required task ID/output type/output type ID combinations all present.
      v 2023-05-08-hub-ensemble.parquet: Values in column `value` all valid with respect to modeling task config.
      v 2023-05-08-hub-ensemble.parquet: Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID value/output type combinations of quantile or cdf output types.
      i 2023-05-08-hub-ensemble.parquet: No pmf output types to check for sum of 1. Check skipped.

# validate_model_data errors correctly

    Code
      validate_model_data(hub_path, file_path = "random-path.csv")
    Error <rlang_error>
      Could not parse file name 'random-path' for submission metadata. Please consult documentation for file name requirements for correct metadata parsing.

