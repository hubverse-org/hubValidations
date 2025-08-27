# validate_target_data works on single time-series target data file

    Code
      res_ts
    Message
      
      -- time-series.csv ----
      
      v [target_file_read]: target file could be read successfully.
      v [target_tbl_colnames]: Column names are consistent with expected column names for time-series target type data.
      v [target_tbl_coltypes]: Column data types match time-series target schema.
      v [target_tbl_ts_targets]: time-series targets are all valid.
      v [target_tbl_rows_unique]: time-series target data rows are unique.
      v [target_tbl_values]: `target_tbl_chr` contains valid values/value combinations.
      i [target_tbl_output_type_ids]: Check not applicable to time-series target data. Skipped.
      i [target_tbl_oracle_value]: Check not applicable to time-series target data. Skipped.

# validate_target_data works on single oracle-output target data file

    Code
      res_oo
    Message
      
      -- oracle-output.csv ----
      
      v [target_file_read]: target file could be read successfully.
      v [target_tbl_colnames]: Column names are consistent with expected column names for oracle-output target type data.
      v [target_tbl_coltypes]: Column data types match oracle-output target schema.
      i [target_tbl_ts_targets]: Check not applicable to oracle-output target data. Skipped.
      v [target_tbl_rows_unique]: oracle-output target data rows are unique.
      v [target_tbl_values]: `target_tbl_chr` contains valid values/value combinations.
      v [target_tbl_output_type_ids]: oracle-output `target_tbl` contains valid complete output_type_id values.
      v [target_tbl_oracle_value]: oracle-output `target_tbl` contains valid oracle values.

# validate_target_data works on multi-file time-series target data file

    Code
      res_ts
    Message
      
      -- part-0.parquet ----
      
      v [target_file_read]: target file could be read successfully.
      v [target_tbl_colnames]: Column names are consistent with expected column names for time-series target type data.
      v [target_tbl_coltypes]: Column data types match time-series target schema.
      v [target_tbl_ts_targets]: time-series targets are all valid.
      v [target_tbl_rows_unique]: time-series target data rows are unique.
      v [target_tbl_values]: `target_tbl_chr` contains valid values/value combinations.
      i [target_tbl_output_type_ids]: Check not applicable to time-series target data. Skipped.
      i [target_tbl_oracle_value]: Check not applicable to time-series target data. Skipped.

# validate_target_data works on  multi-file oracle-output target data file

    Code
      res_oo
    Message
      
      -- part-0.parquet ----
      
      v [target_file_read]: target file could be read successfully.
      v [target_tbl_colnames]: Column names are consistent with expected column names for oracle-output target type data.
      v [target_tbl_coltypes]: Column data types match oracle-output target schema.
      i [target_tbl_ts_targets]: Check not applicable to oracle-output target data. Skipped.
      v [target_tbl_rows_unique]: oracle-output target data rows are unique.
      v [target_tbl_values]: `target_tbl_chr` contains valid values/value combinations.
      v [target_tbl_output_type_ids]: oracle-output `target_tbl` contains valid complete output_type_id values.
      v [target_tbl_oracle_value]: oracle-output `target_tbl` contains valid oracle values.

