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
      <error/check_failure>
      Error:
      ! Number of samples per compound idx not consistent.  Sample numbers supplied per compound idx vary between 100 and 99.  See `errors` attribute for details.

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
      <error/check_failure>
      Error:
      ! Required samples per compound idx task not present.  File contains less than the minimum required number of samples per task for compound task ID values (reference_date: 2022-10-22, location: US), (reference_date: 2022-10-22, location: 01), (reference_date: 2022-10-22, location: 02), (reference_date: 2022-10-22, location: 04), and (reference_date: 2022-10-22, location: 05). See `errors` attribute for details.

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
      
      

# Overriding compound_taskid_set in check_tbl_spl_n works

    Code
      res
    Output
      <error/check_failure>
      Error:
      ! Required samples per compound idx task not present.  File contains less than the minimum required number of samples per task for compound task ID values (reference_date: 2022-10-22, horizon: 0, location: US, variant: AA, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 01, variant: AA, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 02, variant: AA, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 04, variant: AA, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 05, variant: AA, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: US, variant: BB, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 01, variant: BB, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 02, variant: BB, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 04, variant: BB, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 05, variant: BB, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: US, variant: CC, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 01, variant: CC, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 02, variant: CC, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 04, variant: CC, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 05, variant: CC, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: US, variant: DD, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 01, variant: DD, target_end_date: 2022-10-22), (reference_date: 2022-10-22, horizon: 0, location: 02, variant: DD, target_end_date: 2022-10-22), ..., (reference_date: 2022-10-22, horizon: 3, location: 04, variant: DD, target_end_date: 2022-11-12), and (reference_date: 2022-10-22, horizon: 3, location: 05, variant: DD, target_end_date: 2022-11-12). See `errors` attribute for details.

---

    Code
      check_tbl_spl_n(tbl_coarse, round_id, file_path, hub_path, compound_taskid_set = compound_taskid_set)
    Output
      <error/check_failure>
      Error:
      ! Required samples per compound idx task not present.  File contains less than the minimum required number of samples per task for compound task ID values (reference_date: 2022-10-22, horizon: 0), (reference_date: 2022-10-22, horizon: 1), (reference_date: 2022-10-22, horizon: 2), and (reference_date: 2022-10-22, horizon: 3). See `errors` attribute for details.

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
      <error/check_failure>
      Error:
      ! Number of samples per compound idx not consistent.  Sample numbers supplied per compound idx vary between 9 and 10.  See `errors` attribute for details.

# Ignoring derived_task_ids in check_tbl_spl_n works

    Code
      check_tbl_spl_n(tbl, round_id, file_path, hub_path, derived_task_ids = "target_end_date")
    Output
      <message/check_success>
      Message:
      Required samples per compound idx task present.

