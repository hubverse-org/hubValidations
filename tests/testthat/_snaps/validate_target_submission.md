# validate_target_submission works on single time-series target data file

    Code
      res_ts
    Message
      
      -- target_file ----
      
      v [valid_config]: All hub config files are valid.
      
      -- time-series.csv ----
      
      v [target_file_exists]: File exists at path 'target-data/time-series.csv'.
      i [target_partition_file_name]: Target file path not hive-partitioned. Check skipped.
      v [target_file_ext]: Target data file extension is valid.
      v [target_file_read]: target file could be read successfully.
      v [target_tbl_colnames]: Column names are consistent with expected column names for time-series target type data.  Column name validation for time-series data in inference mode is limited. For robust validation, create a 'target-data.json' config file.
      v [target_tbl_coltypes]: Column data types match time-series target schema.
      v [target_tbl_ts_targets]: time-series targets are all valid.
      v [target_tbl_rows_unique]: time-series target data rows are unique.
      v [target_tbl_values]: `target_tbl_chr` contains valid values/value combinations.
      i [target_tbl_output_type_ids]: Check not applicable to time-series target data. Skipped.
      i [target_tbl_oracle_value]: Check not applicable to time-series target data. Skipped.

# validate_target_submission works on single oracle-output target data file

    Code
      res_oo
    Message
      
      -- target_file ----
      
      v [valid_config]: All hub config files are valid.
      
      -- oracle-output.csv ----
      
      v [target_file_exists]: File exists at path 'target-data/oracle-output.csv'.
      i [target_partition_file_name]: Target file path not hive-partitioned. Check skipped.
      v [target_file_ext]: Target data file extension is valid.
      v [target_file_read]: target file could be read successfully.
      v [target_tbl_colnames]: Column names are consistent with expected column names for oracle-output target type data.
      v [target_tbl_coltypes]: Column data types match oracle-output target schema.
      i [target_tbl_ts_targets]: Check not applicable to oracle-output target data. Skipped.
      v [target_tbl_rows_unique]: oracle-output target data rows are unique.
      v [target_tbl_values]: `target_tbl_chr` contains valid values/value combinations.
      v [target_tbl_output_type_ids]: oracle-output `target_tbl` contains valid complete output_type_id values.
      v [target_tbl_oracle_value]: oracle-output `target_tbl` contains valid oracle values.

# validate_target_submission returns early as expected

    Code
      early_return_ts
    Message
      
      -- target_file ----
      
      v [valid_config]: All hub config files are valid.
      
      -- time-series/target=wk%20flu%20hosp%20rate/part-0.parquet ----
      
      (x) [target_file_exists]: File does not exist at path 'target-data/time-series/target=wk%20flu%20hosp%20rate/part-0.parquet'.

