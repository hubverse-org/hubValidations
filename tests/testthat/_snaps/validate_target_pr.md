# validate_target_pr works on valid single oracle output file

    Code
      checks_single_target_file
    Message
      
      -- target ----
      
      v [valid_config]: All hub config files are valid.
      
      -- oracle-output.csv ----
      
      v [target_dataset_exists]: oracle-output dataset detected.
      v [target_dataset_unique]: 'target-data' directory contains single unique oracle-output dataset.
      v [target_dataset_file_ext_unique]: oracle-output dataset files share single unique file format.
      v [target_dataset_rows_unique]: oracle-output target dataset rows are unique.
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

# validate_target_pr works on multiple valid dir oracle output files

    Code
      checks_dir_target_file
    Message
      
      -- target ----
      
      v [valid_config]: All hub config files are valid.
      
      -- time-series ----
      
      v [target_dataset_exists]: time-series dataset detected.
      v [target_dataset_unique]: 'target-data' directory contains single unique time-series dataset.
      v [target_dataset_file_ext_unique]: time-series dataset files share single unique file format.
      v [target_dataset_rows_unique]: time-series target dataset rows are unique.
      
      -- time-series/target=wk%20inc%20flu%20hosp/part-0.parquet ----
      
      v [target_file_exists]: File exists at path 'target-data/time-series/target=wk%20inc%20flu%20hosp/part-0.parquet'.
      v [target_partition_file_name]: Hive-style partition file path segments are valid.
      v [target_file_ext]: Hive-partitioned target data file extension is valid.
      v [target_file_read]: target file could be read successfully.
      v [target_tbl_colnames]: Column names are consistent with expected column names for time-series target type data.
      v [target_tbl_coltypes]: Column data types match time-series target schema.
      v [target_tbl_ts_targets]: time-series targets are all valid.
      v [target_tbl_rows_unique]: time-series target data rows are unique.
      v [target_tbl_values]: `target_tbl_chr` contains valid values/value combinations.
      i [target_tbl_output_type_ids]: Check not applicable to time-series target data. Skipped.
      i [target_tbl_oracle_value]: Check not applicable to time-series target data. Skipped.
      
      -- oracle-output ----
      
      v [target_dataset_exists_1]: oracle-output dataset detected.
      v [target_dataset_unique_1]: 'target-data' directory contains single unique oracle-output dataset.
      v [target_dataset_file_ext_unique_1]: oracle-output dataset files share single unique file format.
      v [target_dataset_rows_unique_1]: oracle-output target dataset rows are unique.
      
      -- oracle-output/output_type=cdf/part-0.parquet ----
      
      v [target_file_exists_1]: File exists at path 'target-data/oracle-output/output_type=cdf/part-0.parquet'.
      v [target_partition_file_name_1]: Hive-style partition file path segments are valid.
      v [target_file_ext_1]: Hive-partitioned target data file extension is valid.
      v [target_file_read_1]: target file could be read successfully.
      v [target_tbl_colnames_1]: Column names are consistent with expected column names for oracle-output target type data.
      v [target_tbl_coltypes_1]: Column data types match oracle-output target schema.
      i [target_tbl_ts_targets_1]: Check not applicable to oracle-output target data. Skipped.
      v [target_tbl_rows_unique_1]: oracle-output target data rows are unique.
      v [target_tbl_values_1]: `target_tbl_chr` contains valid values/value combinations.
      v [target_tbl_output_type_ids_1]: oracle-output `target_tbl` contains valid complete output_type_id values.
      v [target_tbl_oracle_value_1]: oracle-output `target_tbl` contains valid oracle values.

