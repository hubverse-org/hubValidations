# validate_target_dataset works on single file target data

    Code
      res_ts
    Message
      
      -- time-series.csv ----
      
      v [target_dataset_exists]: time-series dataset detected.
      v [target_dataset_unique]: 'target-data' directory contains single unique time-series dataset.
      v [target_dataset_file_ext_unique]: time-series dataset files share single unique file format.
      v [target_dataset_rows_unique]: time-series target dataset rows are unique.

---

    Code
      res_oo
    Message
      
      -- oracle-output.csv ----
      
      v [target_dataset_exists]: oracle-output dataset detected.
      v [target_dataset_unique]: 'target-data' directory contains single unique oracle-output dataset.
      v [target_dataset_file_ext_unique]: oracle-output dataset files share single unique file format.
      v [target_dataset_rows_unique]: oracle-output target dataset rows are unique.

# validate_target_dataset works on muli-file target data

    Code
      res_ts
    Message
      
      -- time-series ----
      
      v [target_dataset_exists]: time-series dataset detected.
      v [target_dataset_unique]: 'target-data' directory contains single unique time-series dataset.
      v [target_dataset_file_ext_unique]: time-series dataset files share single unique file format.
      v [target_dataset_rows_unique]: time-series target dataset rows are unique.

---

    Code
      res_oo
    Message
      
      -- oracle-output ----
      
      v [target_dataset_exists]: oracle-output dataset detected.
      v [target_dataset_unique]: 'target-data' directory contains single unique oracle-output dataset.
      v [target_dataset_file_ext_unique]: oracle-output dataset files share single unique file format.
      v [target_dataset_rows_unique]: oracle-output target dataset rows are unique.

# validate_target_dataset returns appropriately when detecting errors

    Code
      mussing_res_ts
    Message
      
      -- time-series ----
      
      (x) [target_dataset_exists]: time-series dataset not detected.

---

    Code
      dup_res_ts
    Message
      
      -- time-series ----
      
      v [target_dataset_exists]: time-series dataset detected.
      (x) [target_dataset_unique]: 'target-data' directory must contain single unique time-series dataset.  Multiple time-series datasets found: 'time-series' and 'time-series.csv'

