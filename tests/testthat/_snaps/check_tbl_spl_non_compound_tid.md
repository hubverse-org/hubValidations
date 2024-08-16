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
      <error/check_error>
      Error:
      ! Task ID combinations of non compound task id values not consistent across modeling task samples.  Samples "1" and "102" do not match most frequent non compound task ID combination for their modeling task. See `errors` attribute for details.

---

    Code
      error_check$errors
    Output
      [[1]]
      [[1]]$mt_id
      [1] 2
      
      [[1]]$output_type_ids
      [1] "1"   "102"
      
      [[1]]$frequent
      # A tibble: 3 x 3
        target          horizon target_end_date
        <chr>           <chr>   <chr>          
      1 wk inc flu hosp 0       2022-10-22     
      2 wk inc flu hosp 1       2022-10-29     
      3 wk inc flu hosp 2       2022-11-05     
      
      

# Overriding compound_taskid_set in check_tbl_spl_compound_tid works

    Code
      str(check_tbl_spl_non_compound_tid(tbl_coarse, round_id, file_path, hub_path))
    Output
      List of 5
       $ message       : chr "Task ID combinations of non compound task id values consistent across modeling task samples. \n "
       $ where         : chr "flu-base/2022-10-22-flu-base.csv"
       $ errors        : NULL
       $ call          : chr "check_tbl_spl_non_compound_tid"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

---

    Code
      check_tbl_spl_non_compound_tid(tbl_coarse, round_id, file_path, hub_path,
        compound_taskid_set = compound_taskid_set)
    Output
      <message/check_success>
      Message:
      Task ID combinations of non compound task id values consistent across modeling task samples.

# Ignoring derived_task_ids in check_tbl_spl_compound_tid works

    Code
      check_tbl_spl_non_compound_tid(tbl, round_id, file_path, hub_path,
        derived_task_ids = "target_end_date")
    Output
      <message/check_success>
      Message:
      Task ID combinations of non compound task id values consistent across modeling task samples.

