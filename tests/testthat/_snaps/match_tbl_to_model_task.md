# match_tbl_to_model_task works

    Code
      match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22")
    Output
      [[1]]
      # A tibble: 60 x 8
         reference_date target            horizon location target_end_date output_type
         <chr>          <chr>             <chr>   <chr>    <chr>           <chr>      
       1 2022-10-22     wk flu hosp rate~ 0       01       2022-10-22      pmf        
       2 2022-10-22     wk flu hosp rate~ 0       01       2022-10-22      pmf        
       3 2022-10-22     wk flu hosp rate~ 0       01       2022-10-22      pmf        
       4 2022-10-22     wk flu hosp rate~ 0       01       2022-10-22      pmf        
       5 2022-10-22     wk flu hosp rate~ 1       01       2022-10-29      pmf        
       6 2022-10-22     wk flu hosp rate~ 1       01       2022-10-29      pmf        
       7 2022-10-22     wk flu hosp rate~ 1       01       2022-10-29      pmf        
       8 2022-10-22     wk flu hosp rate~ 1       01       2022-10-29      pmf        
       9 2022-10-22     wk flu hosp rate~ 2       01       2022-11-05      pmf        
      10 2022-10-22     wk flu hosp rate~ 2       01       2022-11-05      pmf        
      # i 50 more rows
      # i 2 more variables: output_type_id <chr>, value <chr>
      
      [[2]]
      # A tibble: 1,530 x 8
         reference_date target          horizon location target_end_date output_type
         <chr>          <chr>           <chr>   <chr>    <chr>           <chr>      
       1 2022-10-22     wk inc flu hosp 0       US       2022-10-22      median     
       2 2022-10-22     wk inc flu hosp 1       US       2022-10-29      median     
       3 2022-10-22     wk inc flu hosp 2       US       2022-11-05      median     
       4 2022-10-22     wk inc flu hosp 0       01       2022-10-22      median     
       5 2022-10-22     wk inc flu hosp 1       01       2022-10-29      median     
       6 2022-10-22     wk inc flu hosp 2       01       2022-11-05      median     
       7 2022-10-22     wk inc flu hosp 0       02       2022-10-22      median     
       8 2022-10-22     wk inc flu hosp 1       02       2022-10-29      median     
       9 2022-10-22     wk inc flu hosp 2       02       2022-11-05      median     
      10 2022-10-22     wk inc flu hosp 0       04       2022-10-22      median     
      # i 1,520 more rows
      # i 2 more variables: output_type_id <chr>, value <chr>
      

---

    Code
      match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22",
        output_types = "sample")
    Output
      [[1]]
      NULL
      
      [[2]]
      # A tibble: 1,500 x 8
         reference_date target          horizon location target_end_date output_type
         <chr>          <chr>           <chr>   <chr>    <chr>           <chr>      
       1 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
       2 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
       3 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
       4 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
       5 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
       6 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
       7 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
       8 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
       9 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
      10 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
      # i 1,490 more rows
      # i 2 more variables: output_type_id <chr>, value <chr>
      

---

    Code
      match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22",
        order_by_config = TRUE)
    Output
      [[1]]
      # A tibble: 60 x 8
         reference_date target            horizon location target_end_date output_type
         <chr>          <chr>             <chr>   <chr>    <chr>           <chr>      
       1 2022-10-22     wk flu hosp rate~ 0       US       2022-10-22      pmf        
       2 2022-10-22     wk flu hosp rate~ 0       01       2022-10-22      pmf        
       3 2022-10-22     wk flu hosp rate~ 0       02       2022-10-22      pmf        
       4 2022-10-22     wk flu hosp rate~ 0       04       2022-10-22      pmf        
       5 2022-10-22     wk flu hosp rate~ 0       05       2022-10-22      pmf        
       6 2022-10-22     wk flu hosp rate~ 1       US       2022-10-29      pmf        
       7 2022-10-22     wk flu hosp rate~ 1       01       2022-10-29      pmf        
       8 2022-10-22     wk flu hosp rate~ 1       02       2022-10-29      pmf        
       9 2022-10-22     wk flu hosp rate~ 1       04       2022-10-29      pmf        
      10 2022-10-22     wk flu hosp rate~ 1       05       2022-10-29      pmf        
      # i 50 more rows
      # i 2 more variables: output_type_id <chr>, value <chr>
      
      [[2]]
      # A tibble: 1,530 x 8
         reference_date target          horizon location target_end_date output_type
         <chr>          <chr>           <chr>   <chr>    <chr>           <chr>      
       1 2022-10-22     wk inc flu hosp 0       US       2022-10-22      mean       
       2 2022-10-22     wk inc flu hosp 0       01       2022-10-22      mean       
       3 2022-10-22     wk inc flu hosp 0       02       2022-10-22      mean       
       4 2022-10-22     wk inc flu hosp 0       04       2022-10-22      mean       
       5 2022-10-22     wk inc flu hosp 0       05       2022-10-22      mean       
       6 2022-10-22     wk inc flu hosp 1       US       2022-10-29      mean       
       7 2022-10-22     wk inc flu hosp 1       01       2022-10-29      mean       
       8 2022-10-22     wk inc flu hosp 1       02       2022-10-29      mean       
       9 2022-10-22     wk inc flu hosp 1       04       2022-10-29      mean       
      10 2022-10-22     wk inc flu hosp 1       05       2022-10-29      mean       
      # i 1,520 more rows
      # i 2 more variables: output_type_id <chr>, value <chr>
      

# matching errors when a column it matches on is missing

    Code
      match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22")
    Condition
      Error in `match_tbl_to_model_task()`:
      ! Column "location" must be present in `tbl`.

