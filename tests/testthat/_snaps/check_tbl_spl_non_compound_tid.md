# check_tbl_spl_non_compound_tid works

    Code
      check_tbl_spl_non_compound_tid(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Task ID combinations of non compound task id values consistent across modeling task samples.

---

    Code
      check_tbl_spl_non_compound_tid(tbl_error, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Task ID combinations of non compound task id values not consistent across modeling task samples.  Samples "1" and "102" do not match most prevalent non compound task ID combination for their modeling task. See `errors` attribute for details.

---

    Code
      error_check$errors
    Output
      [[1]]
      [[1]]$mt_id
      [1] 2
      
      [[1]]$mismatches
      [1] "1"   "102"
      
      [[1]]$prevalent
      # A tibble: 3 x 3
        target          horizon target_end_date
        <chr>           <chr>   <chr>          
      1 wk inc flu hosp 0       2022-10-22     
      2 wk inc flu hosp 1       2022-10-29     
      3 wk inc flu hosp 2       2022-11-05     
      
      

