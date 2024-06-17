# check_tbl_spl_compound_tid works

    Code
      check_tbl_spl_compound_tid(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Each sample compound task ID contains single, unique value.

---

    Code
      check_tbl_spl_compound_tid(tbl_error, round_id, file_path, hub_path)
    Output
      <error/check_error>
      Error:
      ! Each sample compound task ID does not contain single, unique value.  Sample "1" does not contain unique compound task ID combinations. See `errors` attribute for details.

---

    Code
      error_check$errors
    Output
      [[1]]
      [[1]]$mt_id
      [1] 2
      
      [[1]]$output_type_id
      [1] "1"
      
      [[1]]$values
      [[1]]$values$location
      [1] "02" "01"
      
      
      

