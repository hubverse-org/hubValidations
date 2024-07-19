# check_tbl_spl_n works

    Code
      check_tbl_spl_n(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Required samples per compound idx task present.

---

    Code
      check_tbl_spl_n(tbl_const_error, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Number of samples per compound idx not consistent.  Sample numbers supplied per compound idx vary between 100 and 99.  See `errors` attribute for details.

---

    Code
      const_error_check$errors
    Output
      # A tibble: 5 x 3
        compound_idx     n mt_id
        <chr>        <int> <int>
      1 1              100     2
      2 2               99     2
      3 3               99     2
      4 4              100     2
      5 5              100     2

---

    Code
      check_tbl_spl_n(tbl_min_error, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Required samples per compound idx task not present.  File contains less than the minimum required number of samples per task for compound idxs "1", "2", "3", "4", and "5". See `errors` attribute for details.

---

    Code
      min_error_check$errors
    Output
      $`1`
      $`1`$compound_idx
      [1] "1"
      
      $`1`$n
      [1] 99
      
      $`1`$min_samples_per_task
      [1] 100
      
      $`1`$max_samples_per_task
      [1] 100
      
      $`1`$compound_idx_tbl
      # A tibble: 3 x 5
        location reference_date horizon target_end_date target         
        <chr>    <chr>          <chr>   <chr>           <chr>          
      1 US       2022-10-22     0       2022-10-22      wk inc flu hosp
      2 US       2022-10-22     1       2022-10-29      wk inc flu hosp
      3 US       2022-10-22     2       2022-11-05      wk inc flu hosp
      
      
      $`2`
      $`2`$compound_idx
      [1] "2"
      
      $`2`$n
      [1] 99
      
      $`2`$min_samples_per_task
      [1] 100
      
      $`2`$max_samples_per_task
      [1] 100
      
      $`2`$compound_idx_tbl
      # A tibble: 3 x 5
        location reference_date horizon target_end_date target         
        <chr>    <chr>          <chr>   <chr>           <chr>          
      1 01       2022-10-22     0       2022-10-22      wk inc flu hosp
      2 01       2022-10-22     1       2022-10-29      wk inc flu hosp
      3 01       2022-10-22     2       2022-11-05      wk inc flu hosp
      
      
      $`3`
      $`3`$compound_idx
      [1] "3"
      
      $`3`$n
      [1] 99
      
      $`3`$min_samples_per_task
      [1] 100
      
      $`3`$max_samples_per_task
      [1] 100
      
      $`3`$compound_idx_tbl
      # A tibble: 3 x 5
        location reference_date horizon target_end_date target         
        <chr>    <chr>          <chr>   <chr>           <chr>          
      1 02       2022-10-22     0       2022-10-22      wk inc flu hosp
      2 02       2022-10-22     1       2022-10-29      wk inc flu hosp
      3 02       2022-10-22     2       2022-11-05      wk inc flu hosp
      
      
      $`4`
      $`4`$compound_idx
      [1] "4"
      
      $`4`$n
      [1] 99
      
      $`4`$min_samples_per_task
      [1] 100
      
      $`4`$max_samples_per_task
      [1] 100
      
      $`4`$compound_idx_tbl
      # A tibble: 3 x 5
        location reference_date horizon target_end_date target         
        <chr>    <chr>          <chr>   <chr>           <chr>          
      1 04       2022-10-22     0       2022-10-22      wk inc flu hosp
      2 04       2022-10-22     1       2022-10-29      wk inc flu hosp
      3 04       2022-10-22     2       2022-11-05      wk inc flu hosp
      
      
      $`5`
      $`5`$compound_idx
      [1] "5"
      
      $`5`$n
      [1] 99
      
      $`5`$min_samples_per_task
      [1] 100
      
      $`5`$max_samples_per_task
      [1] 100
      
      $`5`$compound_idx_tbl
      # A tibble: 3 x 5
        location reference_date horizon target_end_date target         
        <chr>    <chr>          <chr>   <chr>           <chr>          
      1 05       2022-10-22     0       2022-10-22      wk inc flu hosp
      2 05       2022-10-22     1       2022-10-29      wk inc flu hosp
      3 05       2022-10-22     2       2022-11-05      wk inc flu hosp
      
      

# Overriding compound_taskid_set in check_tbl_spl_compound_tid works

    Code
      str(check_tbl_spl_n(tbl_coarse, round_id, file_path, hub_path))
    Output
      List of 5
       $ message       : chr "Required samples per compound idx task not present.  \n File contains less than the minimum required number of "| __truncated__
       $ where         : chr "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
       $ errors        :List of 4
        ..$ 1 :List of 5
        .. ..$ compound_idx        : chr "1"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 90
        .. ..$ max_samples_per_task: int 100
        .. ..$ compound_idx_tbl    : tibble [100 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr [1:100] "2022-10-22" "2022-10-22" "2022-10-22" "2022-10-22" ...
        .. .. ..$ target         : chr [1:100] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
        .. .. ..$ horizon        : chr [1:100] "0" "0" "0" "0" ...
        .. .. ..$ location       : chr [1:100] "US" "01" "02" "04" ...
        .. .. ..$ variant        : chr [1:100] "AA" "AA" "AA" "AA" ...
        .. .. ..$ target_end_date: chr [1:100] "2022-10-22" "2022-10-22" "2022-10-22" "2022-10-22" ...
        ..$ 10:List of 5
        .. ..$ compound_idx        : chr "10"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 90
        .. ..$ max_samples_per_task: int 100
        .. ..$ compound_idx_tbl    : tibble [100 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr [1:100] "2022-10-22" "2022-10-22" "2022-10-22" "2022-10-22" ...
        .. .. ..$ target         : chr [1:100] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
        .. .. ..$ horizon        : chr [1:100] "1" "1" "1" "1" ...
        .. .. ..$ location       : chr [1:100] "US" "01" "02" "04" ...
        .. .. ..$ variant        : chr [1:100] "AA" "AA" "AA" "AA" ...
        .. .. ..$ target_end_date: chr [1:100] "2022-10-22" "2022-10-22" "2022-10-22" "2022-10-22" ...
        ..$ 11:List of 5
        .. ..$ compound_idx        : chr "11"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 90
        .. ..$ max_samples_per_task: int 100
        .. ..$ compound_idx_tbl    : tibble [100 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr [1:100] "2022-10-22" "2022-10-22" "2022-10-22" "2022-10-22" ...
        .. .. ..$ target         : chr [1:100] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
        .. .. ..$ horizon        : chr [1:100] "2" "2" "2" "2" ...
        .. .. ..$ location       : chr [1:100] "US" "01" "02" "04" ...
        .. .. ..$ variant        : chr [1:100] "AA" "AA" "AA" "AA" ...
        .. .. ..$ target_end_date: chr [1:100] "2022-10-22" "2022-10-22" "2022-10-22" "2022-10-22" ...
        ..$ 12:List of 5
        .. ..$ compound_idx        : chr "12"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 90
        .. ..$ max_samples_per_task: int 100
        .. ..$ compound_idx_tbl    : tibble [100 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr [1:100] "2022-10-22" "2022-10-22" "2022-10-22" "2022-10-22" ...
        .. .. ..$ target         : chr [1:100] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
        .. .. ..$ horizon        : chr [1:100] "3" "3" "3" "3" ...
        .. .. ..$ location       : chr [1:100] "US" "01" "02" "04" ...
        .. .. ..$ variant        : chr [1:100] "AA" "AA" "AA" "AA" ...
        .. .. ..$ target_end_date: chr [1:100] "2022-10-22" "2022-10-22" "2022-10-22" "2022-10-22" ...
       $ call          : chr "check_tbl_spl_n"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

---

    Code
      check_tbl_spl_n(tbl_coarse, round_id, file_path, hub_path, compound_taskid_set = compound_taskid_set)
    Output
      <warning/check_failure>
      Warning:
      Required samples per compound idx task not present.  File contains less than the minimum required number of samples per task for compound idxs "1", "2", "3", and "4". See `errors` attribute for details.

---

    Code
      check_tbl_spl_n(tbl_full, round_id, file_path, hub_path, compound_taskid_set = compound_taskid_set)
    Output
      <message/check_success>
      Message:
      Required samples per compound idx task present.

---

    Code
      check_tbl_spl_n(tbl_minus_1, round_id, file_path, hub_path,
        compound_taskid_set = compound_taskid_set)
    Output
      <warning/check_failure>
      Warning:
      Number of samples per compound idx not consistent.  Sample numbers supplied per compound idx vary between 99 and 100.  See `errors` attribute for details.

