# get_tbl_compound_taskid_set works

    Code
      get_tbl_compound_taskid_set(tbl, config_tasks, round_id, compact = TRUE, error = TRUE)
    Output
      $`2`
      [1] "reference_date" "location"      
      

---

    Code
      get_tbl_compound_taskid_set(tbl, config_tasks, round_id, compact = FALSE,
        error = TRUE)
    Output
      $`1`
      NULL
      
      $`2`
      [1] "reference_date" "location"      
      

# get_tbl_compound_taskid_set errors correctly

    Code
      get_tbl_compound_taskid_set(tbl_error_dups, config_tasks, round_id, compact = TRUE,
        error = TRUE)
    Condition
      Error in `purrr::map2()`:
      i In index: 2.
      Caused by error in `get_tbl_compound_taskid_set()`:
      x Detected a finer `compound_taskid_set` than the hub accepts.
      ! "horizon" identified as compound task ID in file but not accepted by the hub.
      i Compound task IDs should be one of "reference_date" and "location".

---

    Code
      get_tbl_compound_taskid_set(tbl_error_dups, config_tasks, round_id, compact = TRUE,
        error = FALSE)
    Output
      $`2`
      [1] "reference_date" "horizon"        "location"      
      attr(,"errors")
      attr(,"errors")[[1]]
      attr(,"errors")[[1]]$config_comp_tids
      [1] "reference_date" "location"      
      
      attr(,"errors")[[1]]$invalid_tbl_comp_tids
      [1] "horizon"
      
      attr(,"errors")[[1]]$tbl_comp_tids
      [1] "reference_date" "horizon"        "location"      
      
      attr(,"errors")[[1]]$output_type_ids
      [1] "2"
      
      
      attr(,"msg")
      [1] "Detected a finer `compound_taskid_set` than the hub accepts. \"horizon\" identified as compound task ID in file but not accepted by the hub. Compound task IDs should be one of \"reference_date\" and \"location\"."
      

