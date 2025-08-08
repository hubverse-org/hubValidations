# validate_target_file works with single CSV target data file

    Code
      res_ts
    Message
      
      -- time-series.csv ----
      
      v [target_file_exists]: File exists at path 'target-data/time-series.csv'.
      i [target_partition_file_name]: Target file path not hive-partitioned. Check skipped.
      v [target_file_ext]: Target data file extension is valid.

---

    Code
      res_oo
    Message
      
      -- oracle-output.csv ----
      
      v [target_file_exists]: File exists at path 'target-data/oracle-output.csv'.
      i [target_partition_file_name]: Target file path not hive-partitioned. Check skipped.
      v [target_file_ext]: Target data file extension is valid.

# validate_target_file works with partitioned parquet target data file

    Code
      res_ts
    Message
      
      -- part-0.parquet ----
      
      v [target_file_exists]: File exists at path 'target-data/time-series/target=wk%20flu%20hosp%20rate/part-0.parquet'.
      v [target_partition_file_name]: Hive-style partition file path segments are valid.
      v [target_file_ext]: Hive-partitioned target data file extension is valid.

---

    Code
      res_oo
    Message
      
      -- part-0.parquet ----
      
      v [target_file_exists]: File exists at path 'target-data/oracle-output/output_type=pmf/part-0.parquet'.
      v [target_partition_file_name]: Hive-style partition file path segments are valid.
      v [target_file_ext]: Hive-partitioned target data file extension is valid.

