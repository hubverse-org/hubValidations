# expand_model_out_grid works correctly

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2023-01-02"))
    Output
      tibble [3,132 x 6] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:3132], format: "2023-01-02" "2023-01-02" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : int [1:3132] 2 1 2 1 2 1 2 1 2 1 ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...

---

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE))
    Output
      tibble [28 x 5] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:28], format: "2023-01-02" "2023-01-02" ...
       $ horizon       : int [1:28] 2 2 2 2 2 2 2 2 2 2 ...
       $ location      : chr [1:28] "US" "US" "US" "US" ...
       $ output_type   : chr [1:28] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:28] "large_decrease" "decrease" "stable" "increase" ...

---

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2022-10-01"))
    Output
      tibble [5,184 x 6] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:5184], format: "2022-10-01" "2022-10-01" ...
       $ target        : chr [1:5184] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:5184] 1 2 3 4 1 2 3 4 1 2 ...
       $ location      : chr [1:5184] "US" "US" "US" "US" ...
       $ output_type   : chr [1:5184] "mean" "mean" "mean" "mean" ...
       $ output_type_id: num [1:5184] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2022-10-01",
        required_vals_only = TRUE))
    Output
      tibble [23 x 5] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-01" "2022-10-01" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...

---

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2022-10-29",
        required_vals_only = TRUE))
    Output
      tibble [23 x 6] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-29" "2022-10-29" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ age_group     : chr [1:23] "65+" "65+" "65+" "65+" ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...

---

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2022-10-29",
        required_vals_only = TRUE, all_character = TRUE))
    Output
      tibble [23 x 6] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : chr [1:23] "2022-10-29" "2022-10-29" "2022-10-29" "2022-10-29" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : chr [1:23] "1" "1" "1" "1" ...
       $ age_group     : chr [1:23] "65+" "65+" "65+" "65+" ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: chr [1:23] "0.01" "0.025" "0.05" "0.1" ...

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-10-29",
        required_vals_only = TRUE, as_arrow_table = TRUE)
    Output
      Table
      23 rows x 6 columns
      $origin_date <date32[day]>
      $target <string>
      $horizon <int32>
      $age_group <string>
      $output_type <string>
      $output_type_id <double>
      
      See $metadata for additional Schema metadata

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-10-29",
        required_vals_only = TRUE, all_character = TRUE, as_arrow_table = TRUE)
    Output
      Table
      23 rows x 6 columns
      $origin_date <string>
      $target <string>
      $horizon <string>
      $age_group <string>
      $output_type <string>
      $output_type_id <string>

---

    Code
      str(expand_model_out_grid(jsonlite::fromJSON(test_path("testdata", "configs",
        "both_null_tasks.json"), simplifyVector = TRUE, simplifyDataFrame = FALSE),
      round_id = "2023-11-26") %>% dplyr::filter(is.na(horizon)))
    Output
      tibble [24 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:24], format: "2023-11-26" "2023-11-26" ...
       $ target        : chr [1:24] "peak time hosp" "peak time hosp" "peak time hosp" "peak time hosp" ...
       $ horizon       : int [1:24] NA NA NA NA NA NA NA NA NA NA ...
       $ location      : chr [1:24] "US" "01" "02" "US" ...
       $ age_group     : chr [1:24] "0-130" "0-130" "0-130" "0-0.99" ...
       $ output_type   : chr [1:24] "cdf" "cdf" "cdf" "cdf" ...
       $ output_type_id: num [1:24] 1 1 1 1 1 1 1 1 1 1 ...

---

    Code
      str(expand_model_out_grid(jsonlite::fromJSON(test_path("testdata", "configs",
        "both_null_tasks_swap.json"), simplifyVector = TRUE, simplifyDataFrame = FALSE),
      round_id = "2023-11-26") %>% dplyr::filter(is.na(horizon)))
    Output
      tibble [24 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:24], format: "2023-11-26" "2023-11-26" ...
       $ target        : chr [1:24] "peak time hosp" "peak time hosp" "peak time hosp" "peak time hosp" ...
       $ horizon       : int [1:24] NA NA NA NA NA NA NA NA NA NA ...
       $ location      : chr [1:24] "US" "01" "02" "US" ...
       $ age_group     : chr [1:24] "0-130" "0-130" "0-130" "0-0.99" ...
       $ output_type   : chr [1:24] "cdf" "cdf" "cdf" "cdf" ...
       $ output_type_id: num [1:24] 1 1 1 1 1 1 1 1 1 1 ...

# expand_model_out_grid output controls work correctly

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2023-01-02", all_character = TRUE))
    Output
      tibble [3,132 x 6] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : chr [1:3132] "2023-01-02" "2023-01-02" "2023-01-02" "2023-01-02" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : chr [1:3132] "2" "1" "2" "1" ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2023-01-02", all_character = TRUE,
        as_arrow_table = TRUE)
    Output
      Table
      3132 rows x 6 columns
      $forecast_date <string>
      $target <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>

---

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE, all_character = TRUE))
    Output
      tibble [28 x 5] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : chr [1:28] "2023-01-02" "2023-01-02" "2023-01-02" "2023-01-02" ...
       $ horizon       : chr [1:28] "2" "2" "2" "2" ...
       $ location      : chr [1:28] "US" "US" "US" "US" ...
       $ output_type   : chr [1:28] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:28] "large_decrease" "decrease" "stable" "increase" ...

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE, all_character = TRUE, as_arrow_table = TRUE)
    Output
      Table
      28 rows x 5 columns
      $forecast_date <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>

---

    Code
      str(expand_model_out_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE, all_character = TRUE, as_arrow_table = FALSE,
        bind_model_tasks = FALSE))
    Output
      List of 2
       $ : tibble [5 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : chr [1:5] "2023-01-02" "2023-01-02" "2023-01-02" "2023-01-02" ...
        ..$ horizon       : chr [1:5] "2" "2" "2" "2" ...
        ..$ location      : chr [1:5] "US" "US" "US" "US" ...
        ..$ output_type   : chr [1:5] "pmf" "pmf" "pmf" "pmf" ...
        ..$ output_type_id: chr [1:5] "large_decrease" "decrease" "stable" "increase" ...
       $ : tibble [23 x 5] (S3: tbl_df/tbl/data.frame)
        ..$ forecast_date : chr [1:23] "2023-01-02" "2023-01-02" "2023-01-02" "2023-01-02" ...
        ..$ horizon       : chr [1:23] "2" "2" "2" "2" ...
        ..$ location      : chr [1:23] "US" "US" "US" "US" ...
        ..$ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
        ..$ output_type_id: chr [1:23] "0.01" "0.025" "0.05" "0.1" ...

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2023-01-02",
        required_vals_only = TRUE, all_character = TRUE, as_arrow_table = TRUE,
        bind_model_tasks = FALSE)
    Output
      [[1]]
      Table
      5 rows x 5 columns
      $forecast_date <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>
      
      [[2]]
      Table
      23 rows x 5 columns
      $forecast_date <string>
      $horizon <string>
      $location <string>
      $output_type <string>
      $output_type_id <string>
      

# expand_model_out_grid output controls with samples work correctly

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26")
    Output
      # A tibble: 42 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>       <chr>         
       1 2022-12-26    wk ahead inc flu h~       2 US       sample      <NA>          
       2 2022-12-26    wk ahead inc flu h~       1 US       sample      <NA>          
       3 2022-12-26    wk ahead inc flu h~       2 01       sample      <NA>          
       4 2022-12-26    wk ahead inc flu h~       1 01       sample      <NA>          
       5 2022-12-26    wk ahead inc flu h~       2 02       sample      <NA>          
       6 2022-12-26    wk ahead inc flu h~       1 02       sample      <NA>          
       7 2022-12-26    wk ahead inc flu h~       2 US       mean        <NA>          
       8 2022-12-26    wk ahead inc flu h~       1 US       mean        <NA>          
       9 2022-12-26    wk ahead inc flu h~       2 01       mean        <NA>          
      10 2022-12-26    wk ahead inc flu h~       1 01       mean        <NA>          
      # i 32 more rows

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE) %>% dplyr::filter(.data$output_type == "sample")
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
        include_sample_ids = TRUE, required_vals_only = TRUE, as_arrow_table = TRUE)
    Condition
      Warning:
      The compound task ID target has all optional values. Representation of compound sample modeling tasks is not fully specified.
    Output
      Table
      6 rows x 5 columns
      $forecast_date <date32[day]>
      $horizon <int32>
      $location <string>
      $output_type <string>
      $output_type_id <string>
      
      See $metadata for additional Schema metadata

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, bind_model_tasks = FALSE)
    Output
      [[1]]
      # A tibble: 12 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>       <chr>         
       1 2022-12-26    wk ahead inc flu h~       2 US       mean        <NA>          
       2 2022-12-26    wk ahead inc flu h~       1 US       mean        <NA>          
       3 2022-12-26    wk ahead inc flu h~       2 01       mean        <NA>          
       4 2022-12-26    wk ahead inc flu h~       1 01       mean        <NA>          
       5 2022-12-26    wk ahead inc flu h~       2 02       mean        <NA>          
       6 2022-12-26    wk ahead inc flu h~       1 02       mean        <NA>          
       7 2022-12-26    wk ahead inc flu h~       2 US       sample      1             
       8 2022-12-26    wk ahead inc flu h~       2 01       sample      1             
       9 2022-12-26    wk ahead inc flu h~       2 02       sample      1             
      10 2022-12-26    wk ahead inc flu h~       1 US       sample      2             
      11 2022-12-26    wk ahead inc flu h~       1 01       sample      2             
      12 2022-12-26    wk ahead inc flu h~       1 02       sample      2             
      
      [[2]]
      # A tibble: 30 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>       <chr>         
       1 2022-12-26    wk flu hosp rate c~       2 US       pmf         large_decrease
       2 2022-12-26    wk flu hosp rate c~       1 US       pmf         large_decrease
       3 2022-12-26    wk flu hosp rate c~       2 01       pmf         large_decrease
       4 2022-12-26    wk flu hosp rate c~       1 01       pmf         large_decrease
       5 2022-12-26    wk flu hosp rate c~       2 02       pmf         large_decrease
       6 2022-12-26    wk flu hosp rate c~       1 02       pmf         large_decrease
       7 2022-12-26    wk flu hosp rate c~       2 US       pmf         decrease      
       8 2022-12-26    wk flu hosp rate c~       1 US       pmf         decrease      
       9 2022-12-26    wk flu hosp rate c~       2 01       pmf         decrease      
      10 2022-12-26    wk flu hosp rate c~       1 01       pmf         decrease      
      # i 20 more rows
      

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
      expand_model_out_grid(config_tasks, round_id = "2022-12-26")
    Output
      # A tibble: 66 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>       <chr>         
       1 2022-12-26    wk ahead inc flu h~       2 US       sample      1             
       2 2022-12-26    wk ahead inc flu h~       1 US       sample      1             
       3 2022-12-26    wk ahead inc flu h~       2 01       sample      1             
       4 2022-12-26    wk ahead inc flu h~       1 01       sample      1             
       5 2022-12-26    wk ahead inc flu h~       2 02       sample      1             
       6 2022-12-26    wk ahead inc flu h~       1 02       sample      1             
       7 2022-12-26    wk ahead inc flu h~       2 US       sample      2             
       8 2022-12-26    wk ahead inc flu h~       1 US       sample      2             
       9 2022-12-26    wk ahead inc flu h~       2 01       sample      2             
      10 2022-12-26    wk ahead inc flu h~       1 01       sample      2             
      # i 56 more rows

---

    Code
      expand_model_out_grid(hubUtils::read_config_file(test_path("testdata",
        "configs", "tasks-samples-2mt.json")), round_id = "2022-12-26",
      include_sample_ids = TRUE) %>% dplyr::filter(.data$output_type == "sample")
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
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, compound_taskid_set = list(c("forecast_date",
          "target"), NULL))
    Output
      # A tibble: 42 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>       <chr>         
       1 2022-12-26    wk ahead inc flu h~       2 US       mean        <NA>          
       2 2022-12-26    wk ahead inc flu h~       1 US       mean        <NA>          
       3 2022-12-26    wk ahead inc flu h~       2 01       mean        <NA>          
       4 2022-12-26    wk ahead inc flu h~       1 01       mean        <NA>          
       5 2022-12-26    wk ahead inc flu h~       2 02       mean        <NA>          
       6 2022-12-26    wk ahead inc flu h~       1 02       mean        <NA>          
       7 2022-12-26    wk ahead inc flu h~       2 US       sample      1             
       8 2022-12-26    wk ahead inc flu h~       1 US       sample      1             
       9 2022-12-26    wk ahead inc flu h~       2 01       sample      1             
      10 2022-12-26    wk ahead inc flu h~       1 01       sample      1             
      # i 32 more rows

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, compound_taskid_set = list(c("forecast_date",
          "target", "horizon", "location"), NULL))
    Output
      # A tibble: 42 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>       <chr>         
       1 2022-12-26    wk ahead inc flu h~       2 US       mean        <NA>          
       2 2022-12-26    wk ahead inc flu h~       1 US       mean        <NA>          
       3 2022-12-26    wk ahead inc flu h~       2 01       mean        <NA>          
       4 2022-12-26    wk ahead inc flu h~       1 01       mean        <NA>          
       5 2022-12-26    wk ahead inc flu h~       2 02       mean        <NA>          
       6 2022-12-26    wk ahead inc flu h~       1 02       mean        <NA>          
       7 2022-12-26    wk ahead inc flu h~       2 US       sample      1             
       8 2022-12-26    wk ahead inc flu h~       1 US       sample      2             
       9 2022-12-26    wk ahead inc flu h~       2 01       sample      3             
      10 2022-12-26    wk ahead inc flu h~       1 01       sample      4             
      # i 32 more rows

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, compound_taskid_set = list(NULL, NULL))
    Output
      # A tibble: 42 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>       <chr>         
       1 2022-12-26    wk ahead inc flu h~       2 US       mean        <NA>          
       2 2022-12-26    wk ahead inc flu h~       1 US       mean        <NA>          
       3 2022-12-26    wk ahead inc flu h~       2 01       mean        <NA>          
       4 2022-12-26    wk ahead inc flu h~       1 01       mean        <NA>          
       5 2022-12-26    wk ahead inc flu h~       2 02       mean        <NA>          
       6 2022-12-26    wk ahead inc flu h~       1 02       mean        <NA>          
       7 2022-12-26    wk ahead inc flu h~       2 US       sample      1             
       8 2022-12-26    wk ahead inc flu h~       1 US       sample      2             
       9 2022-12-26    wk ahead inc flu h~       2 01       sample      3             
      10 2022-12-26    wk ahead inc flu h~       1 01       sample      4             
      # i 32 more rows

# expand_model_out_grid output type subsetting works

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, bind_model_tasks = FALSE, output_types = c("pmf",
          "sample"), )
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
      # A tibble: 30 x 6
         forecast_date target              horizon location output_type output_type_id
         <date>        <chr>                 <int> <chr>    <chr>       <chr>         
       1 2022-12-26    wk flu hosp rate c~       2 US       pmf         large_decrease
       2 2022-12-26    wk flu hosp rate c~       1 US       pmf         large_decrease
       3 2022-12-26    wk flu hosp rate c~       2 01       pmf         large_decrease
       4 2022-12-26    wk flu hosp rate c~       1 01       pmf         large_decrease
       5 2022-12-26    wk flu hosp rate c~       2 02       pmf         large_decrease
       6 2022-12-26    wk flu hosp rate c~       1 02       pmf         large_decrease
       7 2022-12-26    wk flu hosp rate c~       2 US       pmf         decrease      
       8 2022-12-26    wk flu hosp rate c~       1 US       pmf         decrease      
       9 2022-12-26    wk flu hosp rate c~       2 01       pmf         decrease      
      10 2022-12-26    wk flu hosp rate c~       1 01       pmf         decrease      
      # i 20 more rows
      

---

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

# expand_model_out_grid derived_task_ids ignoring works

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-10-22",
        include_sample_ids = FALSE, bind_model_tasks = TRUE, output_types = "sample",
        derived_task_ids = "target_end_date")
    Output
      # A tibble: 80 x 8
         reference_date target    horizon location variant target_end_date output_type
         <date>         <chr>       <int> <chr>    <chr>   <date>          <chr>      
       1 2022-10-22     wk inc f~       0 US       AA      NA              sample     
       2 2022-10-22     wk inc f~       1 US       AA      NA              sample     
       3 2022-10-22     wk inc f~       2 US       AA      NA              sample     
       4 2022-10-22     wk inc f~       3 US       AA      NA              sample     
       5 2022-10-22     wk inc f~       0 01       AA      NA              sample     
       6 2022-10-22     wk inc f~       1 01       AA      NA              sample     
       7 2022-10-22     wk inc f~       2 01       AA      NA              sample     
       8 2022-10-22     wk inc f~       3 01       AA      NA              sample     
       9 2022-10-22     wk inc f~       0 02       AA      NA              sample     
      10 2022-10-22     wk inc f~       1 02       AA      NA              sample     
      # i 70 more rows
      # i 1 more variable: output_type_id <chr>

---

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
      ! "location" and "variant" have required task ID values. Ignored.

# expand_model_out_grid errors correctly

    Code
      expand_model_out_grid(config_tasks, round_id = "random_round_id")
    Condition
      Error in `hubUtils::get_round_idx()`:
      ! `round_id` must be one of "2022-10-01", "2022-10-08", "2022-10-15", "2022-10-22", or "2022-10-29", not "random_round_id".

---

    Code
      expand_model_out_grid(config_tasks)
    Condition
      Error in `checkmate::assert_string()`:
      ! argument "round_id" is missing, with no default

---

    Code
      expand_model_out_grid(config_tasks)
    Condition
      Error in `checkmate::assert_string()`:
      ! argument "round_id" is missing, with no default

---

    Code
      str(expand_model_out_grid(jsonlite::fromJSON(test_path("testdata", "configs",
        "both_null_tasks_all.json"), simplifyVector = TRUE, simplifyDataFrame = FALSE),
      round_id = "2023-11-26") %>% dplyr::filter(is.na(horizon)))
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
      x The length of `compound_taskid_set` (1) must match the number of modeling tasks (2) in the round.

---

    Code
      expand_model_out_grid(config_tasks, round_id = "2022-12-26",
        include_sample_ids = TRUE, compound_taskid_set = list())
    Condition
      Error in `expand_model_out_grid()`:
      x The length of `compound_taskid_set` (0) must match the number of modeling tasks (2) in the round.

