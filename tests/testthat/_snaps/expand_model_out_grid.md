# expand_model_out_grid output controls with samples work correctly

    Code
      dplyr::filter(expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE), .data$output_type == "sample")
    Output
      # A tibble: 6 x 6
        forecast_date target               horizon location output_type output_type_id
        <date>        <chr>                  <int> <chr>    <chr>       <chr>         
      1 2022-12-26    wk ahead inc flu ho~       2 US       sample      s1            
      2 2022-12-26    wk ahead inc flu ho~       1 US       sample      s2            
      3 2022-12-26    wk ahead inc flu ho~       2 01       sample      s3            
      4 2022-12-26    wk ahead inc flu ho~       1 01       sample      s4            
      5 2022-12-26    wk ahead inc flu ho~       2 02       sample      s5            
      6 2022-12-26    wk ahead inc flu ho~       1 02       sample      s6            

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, required_vals_only = TRUE, all_character = TRUE)
    Condition
      Warning:
      The compound task ID target has all optional values. Representation of compound sample modeling tasks is not fully specified.
    Output
      # A tibble: 6 x 5
        forecast_date horizon location output_type output_type_id
        <chr>         <chr>   <chr>    <chr>       <chr>         
      1 2022-12-26    2       US       sample      s1            
      2 2022-12-26    2       US       pmf         large_decrease
      3 2022-12-26    2       US       pmf         decrease      
      4 2022-12-26    2       US       pmf         stable        
      5 2022-12-26    2       US       pmf         increase      
      6 2022-12-26    2       US       pmf         large_increase

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, required_vals_only = TRUE)
    Condition
      Warning:
      The compound task ID target has all optional values. Representation of compound sample modeling tasks is not fully specified.
    Output
      # A tibble: 6 x 5
        forecast_date horizon location output_type output_type_id
        <date>          <int> <chr>    <chr>       <chr>         
      1 2022-12-26          2 US       sample      1             
      2 2022-12-26          2 US       pmf         large_decrease
      3 2022-12-26          2 US       pmf         decrease      
      4 2022-12-26          2 US       pmf         stable        
      5 2022-12-26          2 US       pmf         increase      
      6 2022-12-26          2 US       pmf         large_increase

---

    Code
      dplyr::filter(expand_model_out_grid(hubUtils::read_config_file(test_path(
        "testdata", "configs", "tasks-samples-2mt.json")), round_id = "2022-12-26",
      include_sample_ids = TRUE), .data$output_type == "sample")
    Output
      # A tibble: 12 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>                <int>
       1 2022-12-26    wk ahead inc flu h~       2 US       sample                   1
       2 2022-12-26    wk ahead inc flu h~       2 01       sample                   1
       3 2022-12-26    wk ahead inc flu h~       2 02       sample                   1
       4 2022-12-26    wk ahead inc flu h~       1 US       sample                   2
       5 2022-12-26    wk ahead inc flu h~       1 01       sample                   2
       6 2022-12-26    wk ahead inc flu h~       1 02       sample                   2
       7 2022-12-26    wk ahead inc flu d~       2 US       sample                   3
       8 2022-12-26    wk ahead inc flu d~       2 01       sample                   3
       9 2022-12-26    wk ahead inc flu d~       2 02       sample                   3
      10 2022-12-26    wk ahead inc flu d~       1 US       sample                   4
      11 2022-12-26    wk ahead inc flu d~       1 01       sample                   4
      12 2022-12-26    wk ahead inc flu d~       1 02       sample                   4

---

    Code
      x[is_spl, ]
    Output
      # A tibble: 6 x 6
        forecast_date target               horizon location output_type output_type_id
        <date>        <chr>                  <int> <chr>    <chr>       <chr>         
      1 2022-12-26    wk ahead inc flu ho~       2 US       sample      1             
      2 2022-12-26    wk ahead inc flu ho~       1 US       sample      1             
      3 2022-12-26    wk ahead inc flu ho~       2 01       sample      1             
      4 2022-12-26    wk ahead inc flu ho~       1 01       sample      1             
      5 2022-12-26    wk ahead inc flu ho~       2 02       sample      1             
      6 2022-12-26    wk ahead inc flu ho~       1 02       sample      1             

---

    Code
      x[is_spl, ]
    Output
      # A tibble: 6 x 6
        forecast_date target               horizon location output_type output_type_id
        <date>        <chr>                  <int> <chr>    <chr>       <chr>         
      1 2022-12-26    wk ahead inc flu ho~       2 US       sample      1             
      2 2022-12-26    wk ahead inc flu ho~       1 US       sample      2             
      3 2022-12-26    wk ahead inc flu ho~       2 01       sample      3             
      4 2022-12-26    wk ahead inc flu ho~       1 01       sample      4             
      5 2022-12-26    wk ahead inc flu ho~       2 02       sample      5             
      6 2022-12-26    wk ahead inc flu ho~       1 02       sample      6             

---

    Code
      x[is_spl, ]
    Output
      # A tibble: 6 x 6
        forecast_date target               horizon location output_type output_type_id
        <date>        <chr>                  <int> <chr>    <chr>       <chr>         
      1 2022-12-26    wk ahead inc flu ho~       2 US       sample      1             
      2 2022-12-26    wk ahead inc flu ho~       1 US       sample      2             
      3 2022-12-26    wk ahead inc flu ho~       2 01       sample      3             
      4 2022-12-26    wk ahead inc flu ho~       1 01       sample      4             
      5 2022-12-26    wk ahead inc flu ho~       2 02       sample      5             
      6 2022-12-26    wk ahead inc flu ho~       1 02       sample      6             

# expand_model_out_grid output type subsetting works

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, bind_model_tasks = FALSE, output_types = "sample", )
    Output
      [[1]]
      # A tibble: 6 x 6
        forecast_date target               horizon location output_type output_type_id
        <date>        <chr>                  <int> <chr>    <chr>       <chr>         
      1 2022-12-26    wk ahead inc flu ho~       2 US       sample      1             
      2 2022-12-26    wk ahead inc flu ho~       2 01       sample      1             
      3 2022-12-26    wk ahead inc flu ho~       2 02       sample      1             
      4 2022-12-26    wk ahead inc flu ho~       1 US       sample      2             
      5 2022-12-26    wk ahead inc flu ho~       1 01       sample      2             
      6 2022-12-26    wk ahead inc flu ho~       1 02       sample      2             
      
      [[2]]
      # A tibble: 0 x 0
      

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, bind_model_tasks = TRUE, output_types = "sample", )
    Output
      # A tibble: 6 x 6
        forecast_date target               horizon location output_type output_type_id
        <date>        <chr>                  <int> <chr>    <chr>       <chr>         
      1 2022-12-26    wk ahead inc flu ho~       2 US       sample      1             
      2 2022-12-26    wk ahead inc flu ho~       2 01       sample      1             
      3 2022-12-26    wk ahead inc flu ho~       2 02       sample      1             
      4 2022-12-26    wk ahead inc flu ho~       1 US       sample      2             
      5 2022-12-26    wk ahead inc flu ho~       1 01       sample      2             
      6 2022-12-26    wk ahead inc flu ho~       1 02       sample      2             

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = FALSE, bind_model_tasks = TRUE, output_types = c(
          "random", "sample"), )
    Condition
      Error in `expand_model_out_grid()`:
      x "random" is not valid output type.
      i `output_types` must be members of: "sample", "mean", and "pmf"

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = FALSE, bind_model_tasks = FALSE, output_types = c(
          "random"), )
    Condition
      Error in `expand_model_out_grid()`:
      x "random" is not valid output type.
      i `output_types` must be members of: "sample", "mean", and "pmf"

# force_output_types works as expected with v4

    Code
      v4_opt_spls
    Output
      [[1]]
      # A tibble: 0 x 0
      
      [[2]]
      # A tibble: 0 x 0
      

---

    Code
      v4_opt_spls_force
    Output
      [[1]]
      # A tibble: 0 x 0
      
      [[2]]
      # A tibble: 4 x 5
        reference_date location variant output_type output_type_id
        <date>         <chr>    <chr>   <chr>       <chr>         
      1 2022-10-22     US       AA      sample      <NA>          
      2 2022-10-22     01       AA      sample      <NA>          
      3 2022-10-22     US       BB      sample      <NA>          
      4 2022-10-22     01       BB      sample      <NA>          
      

---

    Code
      v4_opt_spls_force_spl_idx
    Output
      [[1]]
      # A tibble: 0 x 0
      
      [[2]]
      # A tibble: 4 x 5
        reference_date location variant output_type output_type_id
        <date>         <chr>    <chr>   <chr>       <chr>         
      1 2022-10-22     US       AA      sample      1             
      2 2022-10-22     01       AA      sample      2             
      3 2022-10-22     US       BB      sample      3             
      4 2022-10-22     01       BB      sample      4             
      

---

    Code
      v4_opt_mdn
    Output
      [[1]]
      # A tibble: 0 x 0
      
      [[2]]
      # A tibble: 0 x 0
      

---

    Code
      v4_opt_mdn_force
    Output
      [[1]]
      # A tibble: 0 x 0
      
      [[2]]
      # A tibble: 4 x 5
        reference_date location variant output_type output_type_id
        <date>         <chr>    <chr>   <chr>       <chr>         
      1 2022-10-22     US       AA      median      <NA>          
      2 2022-10-22     01       AA      median      <NA>          
      3 2022-10-22     US       BB      median      <NA>          
      4 2022-10-22     01       BB      median      <NA>          
      

---

    Code
      v4_opt_qntl
    Output
      [[1]]
      # A tibble: 0 x 0
      
      [[2]]
      # A tibble: 0 x 0
      

---

    Code
      v4_req_only
    Output
      # A tibble: 2 x 3
        forecast_date horizon location
        <date>          <int> <chr>   
      1 2023-04-24          2 US      
      2 2023-04-24          2 US      

# force_output_types works as expected with v3

    Code
      v3_forced
    Output
      # A tibble: 4 x 5
        reference_date location variant output_type output_type_id
        <date>         <chr>    <chr>   <chr>       <chr>         
      1 2022-10-22     US       AA      median      <NA>          
      2 2022-10-22     01       AA      median      <NA>          
      3 2022-10-22     US       BB      median      <NA>          
      4 2022-10-22     01       BB      median      <NA>          

---

    Code
      v3_forced_all
    Output
      # A tibble: 20 x 5
         reference_date location variant output_type output_type_id
         <date>         <chr>    <chr>   <chr>       <chr>         
       1 2022-10-22     US       <NA>    pmf         low           
       2 2022-10-22     01       <NA>    pmf         low           
       3 2022-10-22     US       <NA>    pmf         moderate      
       4 2022-10-22     01       <NA>    pmf         moderate      
       5 2022-10-22     US       <NA>    pmf         high          
       6 2022-10-22     01       <NA>    pmf         high          
       7 2022-10-22     US       <NA>    pmf         very high     
       8 2022-10-22     01       <NA>    pmf         very high     
       9 2022-10-22     US       AA      mean        <NA>          
      10 2022-10-22     01       AA      mean        <NA>          
      11 2022-10-22     US       BB      mean        <NA>          
      12 2022-10-22     01       BB      mean        <NA>          
      13 2022-10-22     US       AA      median      <NA>          
      14 2022-10-22     01       AA      median      <NA>          
      15 2022-10-22     US       BB      median      <NA>          
      16 2022-10-22     01       BB      median      <NA>          
      17 2022-10-22     US       AA      sample      <NA>          
      18 2022-10-22     01       AA      sample      <NA>          
      19 2022-10-22     US       BB      sample      <NA>          
      20 2022-10-22     01       BB      sample      <NA>          

# expand_model_out_grid derived_task_ids ignoring works

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-10-22",
        include_sample_ids = TRUE, bind_model_tasks = TRUE, output_types = "sample",
        derived_task_ids = "target_end_date", required_vals_only = TRUE)
    Condition
      Warning:
      The compound task IDs horizon and target_end_date have all optional values. Representation of compound sample modeling tasks is not fully specified.
    Output
      # A tibble: 4 x 5
        reference_date location variant output_type output_type_id
        <date>         <chr>    <chr>   <chr>       <chr>         
      1 2022-10-22     US       AA      sample      1             
      2 2022-10-22     01       AA      sample      2             
      3 2022-10-22     US       BB      sample      3             
      4 2022-10-22     01       BB      sample      4             

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-10-22",
        include_sample_ids = FALSE, bind_model_tasks = FALSE, output_types = "sample",
        derived_task_ids = c("location", "variant"))
    Condition
      Error in `expand_model_out_grid()`:
      x Derived task IDs cannot have required task ID values.
      ! "location" and "variant" have required task ID values.

# expand_model_out_grid errors correctly

    Code
      expand_model_out_grid(config_tasks, round_id = "random_round_id")
    Condition
      Error in `get_config_derived_task_ids()`:
      ! `round_id` must be one of "2022-10-01", "2022-10-08", "2022-10-15", "2022-10-22", or "2022-10-29", not "random_round_id".

---

    Code
      expand_model_out_grid(config_tasks)
    Condition
      Error in `expand_model_out_grid()`:
      ! argument "round_id" is missing, with no default

---

    Code
      expand_model_out_grid(config_tasks)
    Condition
      Error in `expand_model_out_grid()`:
      ! argument "round_id" is missing, with no default

---

    Code
      dplyr::filter(expand_model_out_grid(jsonlite::fromJSON(test_path("testdata",
        "configs", "both_null_tasks_all.json"), simplifyVector = TRUE,
      simplifyDataFrame = FALSE), round_id = "2023-11-26"), is.na(horizon))
    Condition
      Error in `map2()`:
      i In index: 3.
      i With name: horizon.
      Caused by error:
      ! horizon must be a DataType, not NULL

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, compound_taskid_set = list(c("forecast_date",
          "target", "random_var"), NULL))
    Condition
      Error in `expand_model_out_grid()`:
      x "random_var" is not valid task ID.
      i The `compound_taskid_set` must be a subset of "forecast_date", "target", "horizon", and "location".

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, compound_taskid_set = list(c("forecast_date",
          "target")))
    Condition
      Error in `expand_model_out_grid()`:
      x `compound_taskid_set` must have one element for each modeling task in the round.
      i The round has 2 modeling tasks but `compound_taskid_set` has 1.

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, compound_taskid_set = list())
    Condition
      Error in `expand_model_out_grid()`:
      x `compound_taskid_set` must have one element for each modeling task in the round.
      i The round has 2 modeling tasks but `compound_taskid_set` has 0.

