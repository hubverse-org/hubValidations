# check_tbl_spl_mt_unique works with valid single-MT samples

    Code
      check_tbl_spl_mt_unique(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Sample `output_type_id`s are each associated with a single, unique modeling task.

# check_tbl_spl_mt_unique detects samples spanning model tasks

    Code
      check_tbl_spl_mt_unique(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Sample `output_type_id`s are each associated with a single, unique modeling task.

---

    Code
      check_tbl_spl_mt_unique(tbl_error, round_id, file_path, hub_path)
    Output
      <error/check_error>
      Error:
      ! Sample `output_type_id`s span multiple modeling tasks, not a single, unique modeling task.  2 sample `output_type_id`s are associated with multiple modeling tasks: "1" and "2". Different model tasks can have different sample configurations so sample IDs must be unique to a single model task. Use `submission_tmpl()` to generate a template with correct sample ID structure. See `errors` attribute for details.

# check_tbl_spl_mt_unique skips when no v3 samples present

    Code
      check_tbl_spl_mt_unique(tbl_no_spl, round_id, file_path, hub_path)
    Output
      <message/check_info>
      Message:
      No v3 samples found in model output data to check. Skipping `check_tbl_spl_mt_unique` check.

