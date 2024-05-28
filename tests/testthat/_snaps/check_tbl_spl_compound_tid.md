# check_tbl_spl_compound_tid works

    Code
      check_tbl_spl_compound_tid(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Task ID combinations across compound idx samples consistent.

---

    Code
      check_tbl_spl_compound_tid(tbl_error, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Task ID combinations across compound idx samples not consistent.  Sample "1" does not match most prevalent task ID combination for its compound idx. See `errors` attribute for details.

---

    Code
      error_check$errors
    Output
      $`2`
      $`2`$compound_idx
      [1] "2"
      
      $`2`$prevalent_task_ids
      # A tibble: 3 x 5
        location reference_date horizon target_end_date target         
        <chr>    <chr>          <chr>   <chr>           <chr>          
      1 01       2022-10-22     0       2022-10-22      wk inc flu hosp
      2 01       2022-10-22     1       2022-10-29      wk inc flu hosp
      3 01       2022-10-22     2       2022-11-05      wk inc flu hosp
      
      $`2`$mismatches
      [1] "1"
      
      

