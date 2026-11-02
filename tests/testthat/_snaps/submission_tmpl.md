# submission_tmpl works correctly with path to hub

    Code
      x <- submission_tmpl(hub_path, round_id = "2023-01-16", required_vals_only = TRUE,
        complete_cases_only = FALSE)
    Message
      ! Column "target" whose values are all optional included as all `NA` column.
      ! Round contains more than one modeling task (n = 2)
      i See Hub's 'tasks.json' file for details of optional task
        ID/output_type/output_type ID value combinations.

---

    Code
      x <- submission_tmpl(hub_path, round_id = "2022-10-01", required_vals_only = TRUE,
        complete_cases_only = FALSE)
    Message
      ! Column "location" whose values are all optional included as all `NA` column.
      i See Hub's 'tasks.json' file for details of optional task
        ID/output_type/output_type ID value combinations.

---

    Code
      x <- submission_tmpl(hub_path, round_id = "2022-10-29", required_vals_only = TRUE,
        complete_cases_only = FALSE)
    Message
      ! Column "location" whose values are all optional included as all `NA` column.
      i See Hub's 'tasks.json' file for details of optional task
        ID/output_type/output_type ID value combinations.

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

# submission_tmpl handles samples correctly

    Code
      dplyr::filter(tmpl, .data$output_type == "sample")
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
      x[is_spl, ]
    Output
      # A tibble: 6 x 7
        forecast_date target         horizon location output_type output_type_id value
        <date>        <chr>            <int> <chr>    <chr>       <chr>          <dbl>
      1 2022-12-26    wk ahead inc ~       2 US       sample      1                 NA
      2 2022-12-26    wk ahead inc ~       1 US       sample      1                 NA
      3 2022-12-26    wk ahead inc ~       2 01       sample      1                 NA
      4 2022-12-26    wk ahead inc ~       1 01       sample      1                 NA
      5 2022-12-26    wk ahead inc ~       2 02       sample      1                 NA
      6 2022-12-26    wk ahead inc ~       1 02       sample      1                 NA

---

    Code
      x[is_spl, ]
    Output
      # A tibble: 6 x 7
        forecast_date target         horizon location output_type output_type_id value
        <date>        <chr>            <int> <chr>    <chr>       <chr>          <dbl>
      1 2022-12-26    wk ahead inc ~       2 US       sample      1                 NA
      2 2022-12-26    wk ahead inc ~       1 US       sample      1                 NA
      3 2022-12-26    wk ahead inc ~       2 01       sample      1                 NA
      4 2022-12-26    wk ahead inc ~       1 01       sample      1                 NA
      5 2022-12-26    wk ahead inc ~       2 02       sample      1                 NA
      6 2022-12-26    wk ahead inc ~       1 02       sample      1                 NA

---

    Code
      x[is_spl, ]
    Output
      # A tibble: 6 x 7
        forecast_date target         horizon location output_type output_type_id value
        <date>        <chr>            <int> <chr>    <chr>       <chr>          <dbl>
      1 2022-12-26    wk ahead inc ~       2 US       sample      1                 NA
      2 2022-12-26    wk ahead inc ~       1 US       sample      2                 NA
      3 2022-12-26    wk ahead inc ~       2 01       sample      3                 NA
      4 2022-12-26    wk ahead inc ~       1 01       sample      4                 NA
      5 2022-12-26    wk ahead inc ~       2 02       sample      5                 NA
      6 2022-12-26    wk ahead inc ~       1 02       sample      6                 NA

