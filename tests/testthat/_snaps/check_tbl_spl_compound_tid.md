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
      
      
      

# Overriding compound_taskid_set in check_tbl_spl_compound_tid works

    Code
      str(check_tbl_spl_compound_tid(tbl_coarse, round_id, file_path, hub_path))
    Output
      List of 7
       $ message       : chr "Each sample compound task ID does not contain single, unique value. \n Samples \"1\", \"2\", \"3\", and \"4\" d"| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "flu-base/2022-10-22-flu-base.csv"
       $ errors        :List of 4
        ..$ :List of 3
        .. ..$ mt_id         : int 2
        .. ..$ output_type_id: chr "1"
        .. ..$ values        :List of 2
        .. .. ..$ location: chr [1:5] "US" "01" "02" "04" ...
        .. .. ..$ variant : chr [1:4] "AA" "BB" "CC" "DD"
        ..$ :List of 3
        .. ..$ mt_id         : int 2
        .. ..$ output_type_id: chr "2"
        .. ..$ values        :List of 2
        .. .. ..$ location: chr [1:5] "US" "01" "02" "04" ...
        .. .. ..$ variant : chr [1:4] "AA" "BB" "CC" "DD"
        ..$ :List of 3
        .. ..$ mt_id         : int 2
        .. ..$ output_type_id: chr "3"
        .. ..$ values        :List of 2
        .. .. ..$ location: chr [1:5] "US" "01" "02" "04" ...
        .. .. ..$ variant : chr [1:4] "AA" "BB" "CC" "DD"
        ..$ :List of 3
        .. ..$ mt_id         : int 2
        .. ..$ output_type_id: chr "4"
        .. ..$ values        :List of 2
        .. .. ..$ location: chr [1:5] "US" "01" "02" "04" ...
        .. .. ..$ variant : chr [1:4] "AA" "BB" "CC" "DD"
       $ call          : chr "check_tbl_spl_compound_tid"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

---

    Code
      check_tbl_spl_compound_tid(tbl_coarse, round_id, file_path, hub_path,
        compound_taskid_set = compound_taskid_set)
    Output
      <message/check_success>
      Message:
      Each sample compound task ID contains single, unique value.

