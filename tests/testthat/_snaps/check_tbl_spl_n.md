# check_tbl_spl_n works

    Code
      check_tbl_spl_n(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Required samples per compound idx task present.

---

    Code
      check_tbl_spl_n(tbl_error, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Required samples per compound idx task not present.  File contains less ("99") than the minimum required number of samples per task ("100") for compound idx "2". File contains less ("99") than the minimum required number of samples per task ("100") for compound idx "3". See `errors` attribute for details.

---

    Code
      error_check$errors
    Output
      $`2`
      $`2`$compound_idx
      [1] "2"
      
      $`2`$n
      [1] 99
      
      $`2`$min_samples_per_task
      [1] 100
      
      $`2`$min_samples_per_task
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
      
      $`3`$min_samples_per_task
      [1] 100
      
      $`3`$compound_idx_tbl
      # A tibble: 3 x 5
        location reference_date horizon target_end_date target         
        <chr>    <chr>          <chr>   <chr>           <chr>          
      1 02       2022-10-22     0       2022-10-22      wk inc flu hosp
      2 02       2022-10-22     1       2022-10-29      wk inc flu hosp
      3 02       2022-10-22     2       2022-11-05      wk inc flu hosp
      
      

