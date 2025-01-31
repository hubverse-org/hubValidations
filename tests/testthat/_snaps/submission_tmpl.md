# submission_tmpl works correctly

    Code
      str(submission_tmpl(hub_path, round_id = "2023-01-30"))
    Output
      tibble [3,132 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:3132], format: "2023-01-30" "2023-01-30" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : int [1:3132] 2 1 2 1 2 1 2 1 2 1 ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...
       $ value         : num [1:3132] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(submission_tmpl(hub_path, round_id = "2023-01-16"))
    Output
      tibble [3,132 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:3132], format: "2023-01-16" "2023-01-16" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : int [1:3132] 2 1 2 1 2 1 2 1 2 1 ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...
       $ value         : num [1:3132] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(submission_tmpl(hub_path, round_id = "2023-01-16", required_vals_only = TRUE))
    Output
      tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : 'Date' num(0) 
       $ target        : chr(0) 
       $ horizon       : int(0) 
       $ location      : chr(0) 
       $ output_type   : chr(0) 
       $ output_type_id: chr(0) 
       $ value         : num(0) 

---

    Code
      str(submission_tmpl(hub_path, round_id = "2023-01-16", required_vals_only = TRUE,
        complete_cases_only = FALSE))
    Message
      ! Column "target" whose values are all optional included as all `NA` column.
      ! Round contains more than one modeling task (n = 2)
      i See Hub's 'tasks.json' file for details of optional task
        ID/output_type/output_type ID value combinations.
    Output
      tibble [28 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:28], format: "2023-01-16" "2023-01-16" ...
       $ target        : chr [1:28] NA NA NA NA ...
       $ horizon       : int [1:28] 2 2 2 2 2 2 2 2 2 2 ...
       $ location      : chr [1:28] "US" "US" "US" "US" ...
       $ output_type   : chr [1:28] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:28] "large_decrease" "decrease" "stable" "increase" ...
       $ value         : num [1:28] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(submission_tmpl(hub_path, round_id = "2022-10-01"))
    Output
      tibble [5,184 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:5184], format: "2022-10-01" "2022-10-01" ...
       $ target        : chr [1:5184] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:5184] 1 2 3 4 1 2 3 4 1 2 ...
       $ location      : chr [1:5184] "US" "US" "US" "US" ...
       $ output_type   : chr [1:5184] "mean" "mean" "mean" "mean" ...
       $ output_type_id: num [1:5184] NA NA NA NA NA NA NA NA NA NA ...
       $ value         : int [1:5184] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(submission_tmpl(hub_path, round_id = "2022-10-01", required_vals_only = TRUE,
        complete_cases_only = FALSE))
    Message
      ! Column "location" whose values are all optional included as all `NA` column.
      i See Hub's 'tasks.json' file for details of optional task
        ID/output_type/output_type ID value combinations.
    Output
      tibble [23 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-01" "2022-10-01" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ location      : chr [1:23] NA NA NA NA ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:23] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(submission_tmpl(hub_path, round_id = "2022-10-29", required_vals_only = TRUE,
        complete_cases_only = FALSE))
    Message
      ! Column "location" whose values are all optional included as all `NA` column.
      i See Hub's 'tasks.json' file for details of optional task
        ID/output_type/output_type ID value combinations.
    Output
      tibble [23 x 8] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:23], format: "2022-10-29" "2022-10-29" ...
       $ target        : chr [1:23] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:23] 1 1 1 1 1 1 1 1 1 1 ...
       $ location      : chr [1:23] NA NA NA NA ...
       $ age_group     : chr [1:23] "65+" "65+" "65+" "65+" ...
       $ output_type   : chr [1:23] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:23] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:23] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      str(submission_tmpl(hub_path, round_id = "2022-10-29", required_vals_only = TRUE))
    Output
      tibble [0 x 8] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : 'Date' num(0) 
       $ target        : chr(0) 
       $ horizon       : int(0) 
       $ location      : chr(0) 
       $ age_group     : chr(0) 
       $ output_type   : chr(0) 
       $ output_type_id: num(0) 
       $ value         : int(0) 

---

    Code
      submission_tmpl(config_path, round_id = "2022-12-26")
    Output
      # A tibble: 42 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      s1                NA
       8 2022-12-26    wk ahead inc~       1 US       sample      s2                NA
       9 2022-12-26    wk ahead inc~       2 01       sample      s3                NA
      10 2022-12-26    wk ahead inc~       1 01       sample      s4                NA
      # i 32 more rows

---

    Code
      submission_tmpl(config_path, round_id = "2022-12-26")
    Output
      # A tibble: 42 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      1                 NA
       8 2022-12-26    wk ahead inc~       2 01       sample      1                 NA
       9 2022-12-26    wk ahead inc~       2 02       sample      1                 NA
      10 2022-12-26    wk ahead inc~       1 US       sample      2                 NA
      # i 32 more rows

---

    Code
      submission_tmpl(config_path, round_id = "2022-12-26") %>% dplyr::filter(.data$
        output_type == "sample")
    Output
      # A tibble: 6 x 7
        forecast_date target         horizon location output_type output_type_id value
        <date>        <chr>            <int> <chr>    <chr>       <chr>          <dbl>
      1 2022-12-26    wk ahead inc ~       2 US       sample      1                 NA
      2 2022-12-26    wk ahead inc ~       2 01       sample      1                 NA
      3 2022-12-26    wk ahead inc ~       2 02       sample      1                 NA
      4 2022-12-26    wk ahead inc ~       1 US       sample      2                 NA
      5 2022-12-26    wk ahead inc ~       1 01       sample      2                 NA
      6 2022-12-26    wk ahead inc ~       1 02       sample      2                 NA

---

    Code
      submission_tmpl(config_path, round_id = "2022-12-26", compound_taskid_set = list(
        c("forecast_date", "target"), NULL))
    Output
      # A tibble: 42 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      1                 NA
       8 2022-12-26    wk ahead inc~       1 US       sample      1                 NA
       9 2022-12-26    wk ahead inc~       2 01       sample      1                 NA
      10 2022-12-26    wk ahead inc~       1 01       sample      1                 NA
      # i 32 more rows

---

    Code
      submission_tmpl(config_path, round_id = "2022-12-26", compound_taskid_set = list(
        c("forecast_date"), NULL))
    Output
      # A tibble: 42 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      1                 NA
       8 2022-12-26    wk ahead inc~       1 US       sample      1                 NA
       9 2022-12-26    wk ahead inc~       2 01       sample      1                 NA
      10 2022-12-26    wk ahead inc~       1 01       sample      1                 NA
      # i 32 more rows

---

    Code
      submission_tmpl(config_path, round_id = "2022-12-26", compound_taskid_set = list(
        NULL, NULL))
    Output
      # A tibble: 42 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      1                 NA
       8 2022-12-26    wk ahead inc~       1 US       sample      2                 NA
       9 2022-12-26    wk ahead inc~       2 01       sample      3                 NA
      10 2022-12-26    wk ahead inc~       1 01       sample      4                 NA
      # i 32 more rows

# submission_tmpl works correctly with deprecated args

    Code
      str(submission_tmpl(hub_con = hub_con, round_id = "2023-01-30"))
    Output
      tibble [3,132 x 7] (S3: tbl_df/tbl/data.frame)
       $ forecast_date : Date[1:3132], format: "2023-01-30" "2023-01-30" ...
       $ target        : chr [1:3132] "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" "wk flu hosp rate change" ...
       $ horizon       : int [1:3132] 2 1 2 1 2 1 2 1 2 1 ...
       $ location      : chr [1:3132] "US" "US" "01" "01" ...
       $ output_type   : chr [1:3132] "pmf" "pmf" "pmf" "pmf" ...
       $ output_type_id: chr [1:3132] "large_decrease" "large_decrease" "large_decrease" "large_decrease" ...
       $ value         : num [1:3132] NA NA NA NA NA NA NA NA NA NA ...

---

    Code
      submission_tmpl(config_tasks = read_config_file(system.file("config",
        "tasks.json", package = "hubValidations")), round_id = "2022-12-26")
    Output
      # A tibble: 42 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      s1                NA
       8 2022-12-26    wk ahead inc~       1 US       sample      s2                NA
       9 2022-12-26    wk ahead inc~       2 01       sample      s3                NA
      10 2022-12-26    wk ahead inc~       1 01       sample      s4                NA
      # i 32 more rows

# submission_tmpl errors correctly

    Code
      submission_tmpl(config_path, round_id = "2022-12-26", compound_taskid_set = list(
        c("forecast_date", "target", "random_var"), NULL))
    Condition
      Error in `expand_model_out_grid()`:
      x "random_var" is not valid task ID.
      i The `compound_taskid_set` must be a subset of "forecast_date", "target", "horizon", and "location".

# submission_tmpl output type subsetting works

    Code
      submission_tmpl(config_path, round_id = "2022-12-26", output_types = "sample")
    Output
      # A tibble: 6 x 7
        forecast_date target         horizon location output_type output_type_id value
        <date>        <chr>            <int> <chr>    <chr>       <chr>          <dbl>
      1 2022-12-26    wk ahead inc ~       2 US       sample      1                 NA
      2 2022-12-26    wk ahead inc ~       2 01       sample      1                 NA
      3 2022-12-26    wk ahead inc ~       2 02       sample      1                 NA
      4 2022-12-26    wk ahead inc ~       1 US       sample      2                 NA
      5 2022-12-26    wk ahead inc ~       1 01       sample      2                 NA
      6 2022-12-26    wk ahead inc ~       1 02       sample      2                 NA

---

    Code
      submission_tmpl(config_path, round_id = "2022-12-26", output_types = c("mean",
        "sample"))
    Output
      # A tibble: 12 x 7
         forecast_date target        horizon location output_type output_type_id value
         <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
       1 2022-12-26    wk ahead inc~       2 US       mean        <NA>              NA
       2 2022-12-26    wk ahead inc~       1 US       mean        <NA>              NA
       3 2022-12-26    wk ahead inc~       2 01       mean        <NA>              NA
       4 2022-12-26    wk ahead inc~       1 01       mean        <NA>              NA
       5 2022-12-26    wk ahead inc~       2 02       mean        <NA>              NA
       6 2022-12-26    wk ahead inc~       1 02       mean        <NA>              NA
       7 2022-12-26    wk ahead inc~       2 US       sample      1                 NA
       8 2022-12-26    wk ahead inc~       2 01       sample      1                 NA
       9 2022-12-26    wk ahead inc~       2 02       sample      1                 NA
      10 2022-12-26    wk ahead inc~       1 US       sample      2                 NA
      11 2022-12-26    wk ahead inc~       1 01       sample      2                 NA
      12 2022-12-26    wk ahead inc~       1 02       sample      2                 NA

# submission_tmpl ignoring derived task ids works

    Code
      submission_tmpl(hub_path, round_id = "2022-10-22", output_types = "sample",
        derived_task_ids = "target_end_date", complete_cases_only = FALSE)
    Output
      # A tibble: 80 x 9
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
      # i 2 more variables: output_type_id <chr>, value <dbl>

