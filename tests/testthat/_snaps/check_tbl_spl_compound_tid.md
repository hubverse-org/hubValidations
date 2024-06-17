# check_tbl_spl_compound_tid works

    Code
      check_tbl_spl_compound_tid(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Each sample contains single, unique compound task ID set value combination.

---

    Code
      check_tbl_spl_compound_tid(tbl_error, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Each sample does not contain single, unique compound task ID set value combination.  Sample "1" does not contain unique compound task ID combinations. See `errors` attribute for details.

---

    Code
      error_check$errors
    Output
      [[1]]
      [[1]]$output_type_id
      [1] "1"
      
      [[1]]$mismatches
      [[1]]$mismatches$location
      [1] "02" "01"
      
      
      

