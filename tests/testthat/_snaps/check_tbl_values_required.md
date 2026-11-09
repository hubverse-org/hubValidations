# check_tbl_values_required works with 1 model task & completely opt cols

    Code
      check_tbl_values_required(tbl_chr, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Required task ID/output type/output type ID combinations all present.

---

    Code
      missing_req_block
    Output
      <error/check_failure>
      Error:
      ! Required task ID/output type/output type ID combinations missing.  See `missing` attribute for details.

# check_tbl_values_required works with 2 separate model tasks & completely missing cols

    Code
      check_tbl_values_required(tbl_chr, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Required task ID/output type/output type ID combinations all present.

---

    Code
      missing_required
    Output
      <error/check_failure>
      Error:
      ! Required task ID/output type/output type ID combinations missing.  See `missing` attribute for details.

# check_tbl_values_required works with v3 spec samples

    Code
      check_tbl_values_required(tbl_chr = tbl_chr, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      Required task ID/output type/output type ID combinations all present.

---

    Code
      check_tbl_values_required(tbl_chr = tbl_chr, round_id = round_id, file_path = file_path,
        hub_path = hub_path)
    Output
      <error/check_failure>
      Error:
      ! Required task ID/output type/output type ID combinations missing.  See `missing` attribute for details.

# Ignoring derived_task_ids in check_tbl_values_required works

    Code
      check_tbl_values_required(tbl_chr, round_id, file_path, hub_path,
        derived_task_ids = "target_end_date")
    Output
      <message/check_success>
      Message:
      Required task ID/output type/output type ID combinations all present.

# (#123) check_tbl_values_required works with all optional output types

    Code
      opt_output_type_ids_result
    Output
      <error/check_failure>
      Error:
      ! Required task ID/output type/output type ID combinations missing.  See `missing` attribute for details.

---

    Code
      check_for_errors(validate_submission(hub_path, file_path,
        skip_submit_window_check = TRUE))
    Message
      
      -- UMass-HMLR/2024-10-02-UMass-HMLR.parquet ----
      
      x [req_vals]: Required task ID/output type/output type ID combinations missing.  See `missing` attribute for details.
    Condition
      Error in `check_for_errors()`:
      ! 
      The validation checks produced some failures/errors reported above.

