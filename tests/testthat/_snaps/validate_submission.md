# validate_submission works

    Code
      res[[file_path]][["file_exists"]]
    Output
      <error/check_error>
      Error:
      ! File does not exist at path 'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv'.

---

    Code
      res[[file_path]][["file_location"]]
    Output
      <error/check_failure>
      Error:
      ! File directory name must match `model_id` metadata in file name.  File should be submitted to directory "hub-baseline" not "team1-goodmodel"

---

    Code
      res[[file_path]][["match_round_id"]]
    Output
      <error/check_error>
      Error:
      ! All `round_id_col` "origin_date" values must match submission `round_id` from file name.  `round_id` value 2022-10-08 does not match submission `round_id` "2022-10-15"

---

    Code
      res[[file_path]][["valid_round_id_col"]]
    Output
      <error/check_failure>
      Error:
      ! `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", and "location" not "random_col".

---

    Code
      res[[file_path]][["unique_round_id"]]
    Output
      <error/check_error>
      Error:
      ! `round_id_col` name must be valid.  Must be one of "origin_date", "target", "horizon", and "location" not "random_col".

# validate_submission submission within window works

    Code
      res
    Output
      <message/check_success>
      Message:
      Submission time is within accepted submission window for round.

# validate_submission submission outside window fails correctly

    Code
      res
    Output
      <error/check_failure>
      Error:
      ! Submission time must be within accepted submission window for round.  Current time "2023-10-08 18:01:00 UTC" is outside window 2022-10-02 EDT--2022-10-09 23:59:59 EDT.

# validate_submission works with v3 samples.

    Code
      v[[file_path_1]]$spl_compound_taskid_set$compound_taskid_set
    Output
      $`1`
      NULL
      
      $`2`
      [1] "reference_date"  "horizon"         "location"        "variant"        
      [5] "target_end_date"
      

---

    Code
      v_rl[[file_path_2]]$spl_compound_taskid_set$compound_taskid_set
    Output
      $`1`
      NULL
      
      $`2`
      [1] "reference_date" "location"      
      

---

    Code
      v_rh[[file_path_3]]$spl_compound_taskid_set$compound_taskid_set
    Output
      $`1`
      NULL
      
      $`2`
      [1] "reference_date"  "horizon"         "target_end_date"
      

# validate_submission handles overriding output type id data type correctly.

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = file_path_1,
      skip_submit_window_check = TRUE)[[file_path_1]][["col_types"]]
    Output
      <error/check_failure>
      Error:
      ! Column data types do not match hub schema.  `output_type_id` should be "character" not "double".

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = file_path_1,
      skip_submit_window_check = TRUE, output_type_id_datatype = "double")[[
        file_path_1]][["col_types"]]
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = file_path_1,
      skip_submit_window_check = TRUE, output_type_id_datatype = "auto")[[
        file_path_1]][["col_types"]]
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = file_path_1,
      skip_submit_window_check = TRUE, output_type_id_datatype = "character")[[
        file_path_1]][["col_types"]]
    Output
      <error/check_failure>
      Error:
      ! Column data types do not match hub schema.  `output_type_id` should be "character" not "double".

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = file_path_2,
      skip_submit_window_check = TRUE)[[file_path_2]][["col_types"]]
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = file_path_2,
      skip_submit_window_check = TRUE, output_type_id_datatype = "double")[[
        file_path_2]][["col_types"]]
    Output
      <error/check_failure>
      Error:
      ! Column data types do not match hub schema.  `output_type_id` should be "double" not "character".

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = file_path_2,
      skip_submit_window_check = TRUE, output_type_id_datatype = "character")[[
        file_path_2]][["col_types"]]
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

# validate_submission validates derived task ID values

    Code
      res[["valid_vals"]]
    Output
      <error/check_error>
      Error:
      ! `tbl` contains invalid values/value combinations.  Column `target_end_date` contains invalid value "2092-10-22".

# validate_submission returns check_failure when duplicate files per round exist

    Code
      dup_model_out_val[[dup_file_path]][["file_n"]]
    Output
      <error/check_failure>
      Error:
      ! Number of accepted model output files per round exceeded.  Should be 1 but pre-existing round submission file "team1-goodmodel/2022-10-08-team1-goodmodel.parquet" found in team directory.

# validate_submission works with v4 flusight (contains derived_task_ids)

    Code
      check_for_errors(v4_missing_meta)
    Message
      
      -- hub-baseline/2023-05-08-hub-baseline.parquet ----
      
      x [metadata_exists]: Metadata file does not exist at path 'model-metadata/hub-baseline.yml' or 'model-metadata/hub-baseline.yaml'.
    Condition
      Error in `check_for_errors()`:
      ! 
      The validation checks produced some failures/errors reported above.

