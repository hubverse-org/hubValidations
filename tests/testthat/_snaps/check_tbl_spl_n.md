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
      str(check_tbl_spl_n(tbl_coarse, round_id, file_path, hub_path))
    Output
      List of 7
       $ message       : chr "Required samples per compound idx task not present.  \n File contains less than the minimum required number of "| __truncated__
       $ trace         : NULL
       $ parent        : NULL
       $ where         : chr "flu-base/2022-10-22-flu-base.csv"
       $ errors        :List of 80
        ..$ 1  :List of 5
        .. ..$ compound_idx        : chr "1"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 102:List of 5
        .. ..$ compound_idx        : chr "102"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 106:List of 5
        .. ..$ compound_idx        : chr "106"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 110:List of 5
        .. ..$ compound_idx        : chr "110"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 114:List of 5
        .. ..$ compound_idx        : chr "114"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 118:List of 5
        .. ..$ compound_idx        : chr "118"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 122:List of 5
        .. ..$ compound_idx        : chr "122"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 126:List of 5
        .. ..$ compound_idx        : chr "126"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 13 :List of 5
        .. ..$ compound_idx        : chr "13"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 130:List of 5
        .. ..$ compound_idx        : chr "130"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 134:List of 5
        .. ..$ compound_idx        : chr "134"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 138:List of 5
        .. ..$ compound_idx        : chr "138"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 142:List of 5
        .. ..$ compound_idx        : chr "142"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 146:List of 5
        .. ..$ compound_idx        : chr "146"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 150:List of 5
        .. ..$ compound_idx        : chr "150"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 154:List of 5
        .. ..$ compound_idx        : chr "154"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 158:List of 5
        .. ..$ compound_idx        : chr "158"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 163:List of 5
        .. ..$ compound_idx        : chr "163"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 167:List of 5
        .. ..$ compound_idx        : chr "167"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 17 :List of 5
        .. ..$ compound_idx        : chr "17"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 171:List of 5
        .. ..$ compound_idx        : chr "171"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 175:List of 5
        .. ..$ compound_idx        : chr "175"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 179:List of 5
        .. ..$ compound_idx        : chr "179"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 183:List of 5
        .. ..$ compound_idx        : chr "183"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 187:List of 5
        .. ..$ compound_idx        : chr "187"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 191:List of 5
        .. ..$ compound_idx        : chr "191"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 195:List of 5
        .. ..$ compound_idx        : chr "195"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 199:List of 5
        .. ..$ compound_idx        : chr "199"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 203:List of 5
        .. ..$ compound_idx        : chr "203"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 207:List of 5
        .. ..$ compound_idx        : chr "207"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 21 :List of 5
        .. ..$ compound_idx        : chr "21"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 211:List of 5
        .. ..$ compound_idx        : chr "211"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 215:List of 5
        .. ..$ compound_idx        : chr "215"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 219:List of 5
        .. ..$ compound_idx        : chr "219"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 223:List of 5
        .. ..$ compound_idx        : chr "223"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 227:List of 5
        .. ..$ compound_idx        : chr "227"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 231:List of 5
        .. ..$ compound_idx        : chr "231"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 235:List of 5
        .. ..$ compound_idx        : chr "235"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 239:List of 5
        .. ..$ compound_idx        : chr "239"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "2"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-05"
        ..$ 244:List of 5
        .. ..$ compound_idx        : chr "244"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 248:List of 5
        .. ..$ compound_idx        : chr "248"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 25 :List of 5
        .. ..$ compound_idx        : chr "25"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 252:List of 5
        .. ..$ compound_idx        : chr "252"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 256:List of 5
        .. ..$ compound_idx        : chr "256"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 260:List of 5
        .. ..$ compound_idx        : chr "260"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 264:List of 5
        .. ..$ compound_idx        : chr "264"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 268:List of 5
        .. ..$ compound_idx        : chr "268"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 272:List of 5
        .. ..$ compound_idx        : chr "272"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 276:List of 5
        .. ..$ compound_idx        : chr "276"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 280:List of 5
        .. ..$ compound_idx        : chr "280"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 284:List of 5
        .. ..$ compound_idx        : chr "284"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 288:List of 5
        .. ..$ compound_idx        : chr "288"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 29 :List of 5
        .. ..$ compound_idx        : chr "29"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 292:List of 5
        .. ..$ compound_idx        : chr "292"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 296:List of 5
        .. ..$ compound_idx        : chr "296"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 300:List of 5
        .. ..$ compound_idx        : chr "300"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 304:List of 5
        .. ..$ compound_idx        : chr "304"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 308:List of 5
        .. ..$ compound_idx        : chr "308"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 312:List of 5
        .. ..$ compound_idx        : chr "312"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 316:List of 5
        .. ..$ compound_idx        : chr "316"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 320:List of 5
        .. ..$ compound_idx        : chr "320"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "3"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-11-12"
        ..$ 33 :List of 5
        .. ..$ compound_idx        : chr "33"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 37 :List of 5
        .. ..$ compound_idx        : chr "37"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "BB"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 41 :List of 5
        .. ..$ compound_idx        : chr "41"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 45 :List of 5
        .. ..$ compound_idx        : chr "45"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 49 :List of 5
        .. ..$ compound_idx        : chr "49"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 5  :List of 5
        .. ..$ compound_idx        : chr "5"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 53 :List of 5
        .. ..$ compound_idx        : chr "53"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 57 :List of 5
        .. ..$ compound_idx        : chr "57"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "CC"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 61 :List of 5
        .. ..$ compound_idx        : chr "61"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 65 :List of 5
        .. ..$ compound_idx        : chr "65"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 69 :List of 5
        .. ..$ compound_idx        : chr "69"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 73 :List of 5
        .. ..$ compound_idx        : chr "73"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 77 :List of 5
        .. ..$ compound_idx        : chr "77"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "DD"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 82 :List of 5
        .. ..$ compound_idx        : chr "82"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "US"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 86 :List of 5
        .. ..$ compound_idx        : chr "86"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "01"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 9  :List of 5
        .. ..$ compound_idx        : chr "9"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "0"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-22"
        ..$ 90 :List of 5
        .. ..$ compound_idx        : chr "90"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "02"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 94 :List of 5
        .. ..$ compound_idx        : chr "94"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "04"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-29"
        ..$ 98 :List of 5
        .. ..$ compound_idx        : chr "98"
        .. ..$ n                   : int 1
        .. ..$ min_samples_per_task: int 9
        .. ..$ max_samples_per_task: int 10
        .. ..$ compound_idx_tbl    : tibble [1 x 6] (S3: tbl_df/tbl/data.frame)
        .. .. ..$ reference_date : chr "2022-10-22"
        .. .. ..$ target         : chr "wk inc flu hosp"
        .. .. ..$ horizon        : chr "1"
        .. .. ..$ location       : chr "05"
        .. .. ..$ variant        : chr "AA"
        .. .. ..$ target_end_date: chr "2022-10-29"
       $ call          : chr "check_tbl_spl_n"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...

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

