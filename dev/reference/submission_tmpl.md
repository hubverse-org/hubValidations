# Create a model output submission file template

Create a model output submission file template

## Usage

``` r
submission_tmpl(
  path,
  round_id,
  required_vals_only = FALSE,
  force_output_types = FALSE,
  complete_cases_only = TRUE,
  compound_taskid_set = NULL,
  output_types = NULL,
  derived_task_ids = NULL,
  hub_con = deprecated(),
  config_tasks = deprecated()
)
```

## Arguments

- path:

  Character string. Can be one of:

  - a path to a local fully configured hub directory

  - a path to a local `tasks.json` file.

  - a URL to the repository of a fully configured hub on GitHub.

  - a URL to the **raw contents** of a `tasks.json` file on GitHub.

  - a `<SubTreeFileSystem>` class object pointing to the root of an S3
    cloud hub.

  - a `<SubTreeFileSystem>` class object pointing to a `tasks.json`
    config file in an S3 cloud hub, relative to the hub's root
    directory.

  See examples for more details.

- round_id:

  Character string. Round identifier. If the round is set to
  `round_id_from_variable: true`, IDs are values of the task ID defined
  in the round's `round_id` property of `config_tasks`. Otherwise should
  match round's `round_id` value in config. Ignored if hub contains only
  a single round.

- required_vals_only:

  Logical. Whether to return only combinations of Task ID and related
  output type ID required values.

- force_output_types:

  Logical. Whether to force all output types to be required. If `TRUE`,
  all output type ID values are treated as required regardless of the
  value of the `is_required` property. Useful for creating grids of
  required values for optional output types.

- complete_cases_only:

  Logical. If `TRUE` (default) and `required_vals_only = TRUE`, only
  rows with complete cases of combinations of required values are
  returned. If `FALSE`, rows with incomplete cases of combinations of
  required values are included in the output.

- compound_taskid_set:

  List of character vectors, one for each modeling task in the round.
  Can be used to override the compound task ID set defined in the
  config. If `NULL` is provided for a given modeling task, a compound
  task ID set of all task IDs is used.

- output_types:

  Character vector of output type names to include. Use to subset for
  grids for specific output types.

- derived_task_ids:

  Character vector of derived task ID names (task IDs whose values
  depend on other task IDs) to ignore. Columns for such task ids will
  contain `NA`s. If `NULL`, defaults to extracting derived task IDs from
  `config_tasks` or the `config_tasks` attribute of `hub_con`. See
  [`get_config_derived_task_ids()`](https://hubverse-org.github.io/hubValidations/dev/reference/get_config_derived_task_ids.md)
  for more details.

- hub_con:

  **\[deprecated\]** Use `path` instead. A `⁠<hub_connection>⁠` class
  object.

- config_tasks:

  **\[deprecated\]** Use `path` instead. A list version of the content's
  of a hub's `tasks.json` config file, accessed through the
  `"config_tasks"` attribute of a `<hub_connection>` object or function
  [`read_config()`](https://hubverse-org.github.io/hubUtils/reference/read_config.html).

## Value

a tibble template containing an expanded grid of valid task ID and
output type ID value combinations for a given submission round and
output type. If `required_vals_only = TRUE`, values are limited to the
combination of required values only.

## Details

For task IDs where all values are optional, by default, columns are
created as columns of `NA`s when `required_vals_only = TRUE`. When such
columns exist, the function returns a tibble with zero rows, as no
complete cases of required value combinations exists. *(Note that
determination of complete cases does excludes valid `NA`
`output_type_id` values in `"mean"` and `"median"` output types).* To
return a template of incomplete required cases, which includes `NA`
columns, use `complete_cases_only = FALSE`.

To include output types that are optional in the submission template
when `required_vals_only = TRUE` and `complete_cases_only = FALSE`, use
`force_output_types = TRUE`. Use this in combination with sub-setting
for output types you plan to submit via argument `output_types` to
create a submission template customised to your submission plans. *Tip:
to ensure you create a template with all required output types, it's a
good idea to first run the functions without subsetting or forcing
output types and examing the unique values in `output_type` to check
which output types are required.*

When sample output types are included in the output, the
`output_type_id` column contains example sample indexes which are useful
for identifying the compound task ID structure of multivariate sampling
distributions in particular, i.e. which combinations of task ID values
represent individual samples.

When a round is set to `round_id_from_variable: true`, the value of the
task ID from which round IDs are derived (i.e. the task ID specified in
`round_id` property of `config_tasks`) is set to the value of the
`round_id` argument in the returned output.

## Examples

``` r
hub_path <- system.file("testhubs/flusight", package = "hubUtils")
submission_tmpl(hub_path, round_id = "2023-01-02")
#> # A tibble: 3,132 × 7
#>    forecast_date target        horizon location output_type output_type_id value
#>    <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
#>  1 2023-01-02    wk flu hosp …       2 US       pmf         large_decrease    NA
#>  2 2023-01-02    wk flu hosp …       1 US       pmf         large_decrease    NA
#>  3 2023-01-02    wk flu hosp …       2 01       pmf         large_decrease    NA
#>  4 2023-01-02    wk flu hosp …       1 01       pmf         large_decrease    NA
#>  5 2023-01-02    wk flu hosp …       2 02       pmf         large_decrease    NA
#>  6 2023-01-02    wk flu hosp …       1 02       pmf         large_decrease    NA
#>  7 2023-01-02    wk flu hosp …       2 04       pmf         large_decrease    NA
#>  8 2023-01-02    wk flu hosp …       1 04       pmf         large_decrease    NA
#>  9 2023-01-02    wk flu hosp …       2 05       pmf         large_decrease    NA
#> 10 2023-01-02    wk flu hosp …       1 05       pmf         large_decrease    NA
#> # ℹ 3,122 more rows
# Return required values only
submission_tmpl(
  hub_path,
  round_id = "2023-01-02",
  required_vals_only = TRUE
)
#> # A tibble: 0 × 7
#> # ℹ 7 variables: forecast_date <date>, target <chr>, horizon <int>,
#> #   location <chr>, output_type <chr>, output_type_id <chr>, value <dbl>
submission_tmpl(
  hub_path,
  round_id = "2023-01-02",
  required_vals_only = TRUE,
  complete_cases_only = FALSE
)
#> ! Column "target" whose values are all optional included as all `NA` column.
#> ! Round contains more than one modeling task (n = 2)
#> ℹ See Hub's tasks.json file for details of optional task
#>   ID/output_type/output_type ID value combinations.
#> # A tibble: 28 × 7
#>    forecast_date target horizon location output_type output_type_id value
#>    <date>        <chr>    <int> <chr>    <chr>       <chr>          <dbl>
#>  1 2023-01-02    NA           2 US       pmf         large_decrease    NA
#>  2 2023-01-02    NA           2 US       pmf         decrease          NA
#>  3 2023-01-02    NA           2 US       pmf         stable            NA
#>  4 2023-01-02    NA           2 US       pmf         increase          NA
#>  5 2023-01-02    NA           2 US       pmf         large_increase    NA
#>  6 2023-01-02    NA           2 US       quantile    0.01              NA
#>  7 2023-01-02    NA           2 US       quantile    0.025             NA
#>  8 2023-01-02    NA           2 US       quantile    0.05              NA
#>  9 2023-01-02    NA           2 US       quantile    0.1               NA
#> 10 2023-01-02    NA           2 US       quantile    0.15              NA
#> # ℹ 18 more rows
# Specify a round in a hub with multiple rounds
hub_path <- system.file("testhubs/simple", package = "hubUtils")
submission_tmpl(hub_path, round_id = "2022-10-01")
#> # A tibble: 5,184 × 7
#>    origin_date target          horizon location output_type output_type_id value
#>    <date>      <chr>             <int> <chr>    <chr>                <dbl> <int>
#>  1 2022-10-01  wk inc flu hosp       1 US       mean                    NA    NA
#>  2 2022-10-01  wk inc flu hosp       2 US       mean                    NA    NA
#>  3 2022-10-01  wk inc flu hosp       3 US       mean                    NA    NA
#>  4 2022-10-01  wk inc flu hosp       4 US       mean                    NA    NA
#>  5 2022-10-01  wk inc flu hosp       1 01       mean                    NA    NA
#>  6 2022-10-01  wk inc flu hosp       2 01       mean                    NA    NA
#>  7 2022-10-01  wk inc flu hosp       3 01       mean                    NA    NA
#>  8 2022-10-01  wk inc flu hosp       4 01       mean                    NA    NA
#>  9 2022-10-01  wk inc flu hosp       1 02       mean                    NA    NA
#> 10 2022-10-01  wk inc flu hosp       2 02       mean                    NA    NA
#> # ℹ 5,174 more rows
submission_tmpl(hub_path, round_id = "2022-10-29")
#> # A tibble: 25,920 × 8
#>    origin_date target      horizon location age_group output_type output_type_id
#>    <date>      <chr>         <int> <chr>    <chr>     <chr>                <dbl>
#>  1 2022-10-29  wk inc flu…       1 US       65+       mean                    NA
#>  2 2022-10-29  wk inc flu…       2 US       65+       mean                    NA
#>  3 2022-10-29  wk inc flu…       3 US       65+       mean                    NA
#>  4 2022-10-29  wk inc flu…       4 US       65+       mean                    NA
#>  5 2022-10-29  wk inc flu…       1 01       65+       mean                    NA
#>  6 2022-10-29  wk inc flu…       2 01       65+       mean                    NA
#>  7 2022-10-29  wk inc flu…       3 01       65+       mean                    NA
#>  8 2022-10-29  wk inc flu…       4 01       65+       mean                    NA
#>  9 2022-10-29  wk inc flu…       1 02       65+       mean                    NA
#> 10 2022-10-29  wk inc flu…       2 02       65+       mean                    NA
#> # ℹ 25,910 more rows
#> # ℹ 1 more variable: value <int>
# Subset for a specific output type
hub_path <- system.file("testhubs", "samples", package = "hubValidations")
submission_tmpl(
  hub_path,
  round_id = "2022-12-17",
  output_types = "sample"
)
#> # A tibble: 640 × 8
#>    reference_date target          horizon location target_end_date output_type
#>    <date>         <chr>             <int> <chr>    <date>          <chr>      
#>  1 2022-12-17     wk inc flu hosp       0 US       2022-10-22      sample     
#>  2 2022-12-17     wk inc flu hosp       1 US       2022-10-22      sample     
#>  3 2022-12-17     wk inc flu hosp       2 US       2022-10-22      sample     
#>  4 2022-12-17     wk inc flu hosp       3 US       2022-10-22      sample     
#>  5 2022-12-17     wk inc flu hosp       0 US       2022-10-29      sample     
#>  6 2022-12-17     wk inc flu hosp       1 US       2022-10-29      sample     
#>  7 2022-12-17     wk inc flu hosp       2 US       2022-10-29      sample     
#>  8 2022-12-17     wk inc flu hosp       3 US       2022-10-29      sample     
#>  9 2022-12-17     wk inc flu hosp       0 US       2022-11-05      sample     
#> 10 2022-12-17     wk inc flu hosp       1 US       2022-11-05      sample     
#> # ℹ 630 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <dbl>
# Create a template from the path to a tasks config file
config_path <- system.file("config", "tasks.json",
  package = "hubValidations"
)
submission_tmpl(
  config_path,
  round_id = "2022-12-26"
)
#> # A tibble: 42 × 7
#>    forecast_date target        horizon location output_type output_type_id value
#>    <date>        <chr>           <int> <chr>    <chr>       <chr>          <dbl>
#>  1 2022-12-26    wk ahead inc…       2 US       mean        NA                NA
#>  2 2022-12-26    wk ahead inc…       1 US       mean        NA                NA
#>  3 2022-12-26    wk ahead inc…       2 01       mean        NA                NA
#>  4 2022-12-26    wk ahead inc…       1 01       mean        NA                NA
#>  5 2022-12-26    wk ahead inc…       2 02       mean        NA                NA
#>  6 2022-12-26    wk ahead inc…       1 02       mean        NA                NA
#>  7 2022-12-26    wk ahead inc…       2 US       sample      s1                NA
#>  8 2022-12-26    wk ahead inc…       1 US       sample      s2                NA
#>  9 2022-12-26    wk ahead inc…       2 01       sample      s3                NA
#> 10 2022-12-26    wk ahead inc…       1 01       sample      s4                NA
#> # ℹ 32 more rows
# Hub with sample output type and compound task ID structure
config_path <- system.file("config", "tasks-comp-tid.json",
  package = "hubValidations"
)
submission_tmpl(
  config_path,
  round_id = "2022-12-26",
  output_types = "sample"
)
#> # A tibble: 6 × 7
#>   forecast_date target         horizon location output_type output_type_id value
#>   <date>        <chr>            <int> <chr>    <chr>       <chr>          <dbl>
#> 1 2022-12-26    wk ahead inc …       2 US       sample      1                 NA
#> 2 2022-12-26    wk ahead inc …       2 01       sample      1                 NA
#> 3 2022-12-26    wk ahead inc …       2 02       sample      1                 NA
#> 4 2022-12-26    wk ahead inc …       1 US       sample      2                 NA
#> 5 2022-12-26    wk ahead inc …       1 01       sample      2                 NA
#> 6 2022-12-26    wk ahead inc …       1 02       sample      2                 NA
# Override config compound task ID set
# Create coarser compound task ID set for the first modeling task which contains
# samples
submission_tmpl(
  config_path,
  round_id = "2022-12-26",
  output_types = "sample",
  compound_taskid_set = list(
    c("forecast_date", "target"),
    NULL
  )
)
#> # A tibble: 6 × 7
#>   forecast_date target         horizon location output_type output_type_id value
#>   <date>        <chr>            <int> <chr>    <chr>       <chr>          <dbl>
#> 1 2022-12-26    wk ahead inc …       2 US       sample      1                 NA
#> 2 2022-12-26    wk ahead inc …       1 US       sample      1                 NA
#> 3 2022-12-26    wk ahead inc …       2 01       sample      1                 NA
#> 4 2022-12-26    wk ahead inc …       1 01       sample      1                 NA
#> 5 2022-12-26    wk ahead inc …       2 02       sample      1                 NA
#> 6 2022-12-26    wk ahead inc …       1 02       sample      1                 NA
# Derive a template with ignored derived task ID. Useful to avoid creating
# a template with invalid derived task ID value combinations.
hub_path <- system.file("testhubs", "flusight", package = "hubValidations")
submission_tmpl(
  hub_path,
  round_id = "2022-12-12",
  output_types = "pmf",
  derived_task_ids = "target_end_date",
  complete_cases_only = FALSE
)
#> # A tibble: 540 × 8
#>    forecast_date target_end_date target             horizon location output_type
#>    <date>        <date>          <chr>                <int> <chr>    <chr>      
#>  1 2022-12-12    NA              wk flu hosp rate …       2 US       pmf        
#>  2 2022-12-12    NA              wk flu hosp rate …       1 US       pmf        
#>  3 2022-12-12    NA              wk flu hosp rate …       2 01       pmf        
#>  4 2022-12-12    NA              wk flu hosp rate …       1 01       pmf        
#>  5 2022-12-12    NA              wk flu hosp rate …       2 02       pmf        
#>  6 2022-12-12    NA              wk flu hosp rate …       1 02       pmf        
#>  7 2022-12-12    NA              wk flu hosp rate …       2 04       pmf        
#>  8 2022-12-12    NA              wk flu hosp rate …       1 04       pmf        
#>  9 2022-12-12    NA              wk flu hosp rate …       2 05       pmf        
#> 10 2022-12-12    NA              wk flu hosp rate …       1 05       pmf        
#> # ℹ 530 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <dbl>
# Force optional output type, in this case "mean".
submission_tmpl(
  hub_path,
  round_id = "2022-12-12",
  required_vals_only = TRUE,
  output_types = c("pmf", "quantile", "mean"),
  force_output_types = TRUE,
  derived_task_ids = "target_end_date",
  complete_cases_only = FALSE
)
#> ! Columns "target_end_date" and "target" whose values are all optional included
#>   as all `NA` columns.
#> ! Round contains more than one modeling task (n = 2)
#> ℹ See Hub's tasks.json file for details of optional task
#>   ID/output_type/output_type ID value combinations.
#> # A tibble: 29 × 8
#>    forecast_date target_end_date target horizon location output_type
#>    <date>        <date>          <chr>    <int> <chr>    <chr>      
#>  1 2022-12-12    NA              NA           2 US       pmf        
#>  2 2022-12-12    NA              NA           2 US       pmf        
#>  3 2022-12-12    NA              NA           2 US       pmf        
#>  4 2022-12-12    NA              NA           2 US       pmf        
#>  5 2022-12-12    NA              NA           2 US       pmf        
#>  6 2022-12-12    NA              NA           2 US       quantile   
#>  7 2022-12-12    NA              NA           2 US       quantile   
#>  8 2022-12-12    NA              NA           2 US       quantile   
#>  9 2022-12-12    NA              NA           2 US       quantile   
#> 10 2022-12-12    NA              NA           2 US       quantile   
#> # ℹ 19 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <dbl>
# Create a template from a URL to fully configured hub repository on GitHub
submission_tmpl(
  path = "https://github.com/hubverse-org/example-simple-forecast-hub",
  round_id = "2022-11-28",
  output_types = "quantile"
)
#> # A tibble: 26,082 × 7
#>    origin_date target         horizon location output_type output_type_id value
#>    <date>      <chr>            <int> <chr>    <chr>                <dbl> <int>
#>  1 2022-11-28  inc covid hosp      -6 US       quantile              0.01    NA
#>  2 2022-11-28  inc covid hosp      -5 US       quantile              0.01    NA
#>  3 2022-11-28  inc covid hosp      -4 US       quantile              0.01    NA
#>  4 2022-11-28  inc covid hosp      -3 US       quantile              0.01    NA
#>  5 2022-11-28  inc covid hosp      -2 US       quantile              0.01    NA
#>  6 2022-11-28  inc covid hosp      -1 US       quantile              0.01    NA
#>  7 2022-11-28  inc covid hosp       0 US       quantile              0.01    NA
#>  8 2022-11-28  inc covid hosp       1 US       quantile              0.01    NA
#>  9 2022-11-28  inc covid hosp       2 US       quantile              0.01    NA
#> 10 2022-11-28  inc covid hosp       3 US       quantile              0.01    NA
#> # ℹ 26,072 more rows
# Create a template from a URL to the raw contents of a tasks.json file on
# GitHub
config_raw_url <- paste0(
  "https://raw.githubusercontent.com/hubverse-org/",
  "example-simple-forecast-hub/refs/heads/main/hub-config/tasks.json"
)
submission_tmpl(
  path = config_raw_url,
  round_id = "2022-11-28",
  output_types = "quantile"
)
#> # A tibble: 26,082 × 7
#>    origin_date target         horizon location output_type output_type_id value
#>    <date>      <chr>            <int> <chr>    <chr>                <dbl> <int>
#>  1 2022-11-28  inc covid hosp      -6 US       quantile              0.01    NA
#>  2 2022-11-28  inc covid hosp      -5 US       quantile              0.01    NA
#>  3 2022-11-28  inc covid hosp      -4 US       quantile              0.01    NA
#>  4 2022-11-28  inc covid hosp      -3 US       quantile              0.01    NA
#>  5 2022-11-28  inc covid hosp      -2 US       quantile              0.01    NA
#>  6 2022-11-28  inc covid hosp      -1 US       quantile              0.01    NA
#>  7 2022-11-28  inc covid hosp       0 US       quantile              0.01    NA
#>  8 2022-11-28  inc covid hosp       1 US       quantile              0.01    NA
#>  9 2022-11-28  inc covid hosp       2 US       quantile              0.01    NA
#> 10 2022-11-28  inc covid hosp       3 US       quantile              0.01    NA
#> # ℹ 26,072 more rows
# Create submission file using config file from AWS S3 bucket hub
# Use `s3_bucket()` to create a path to the hub's root directory
s3_hub_path <- arrow::s3_bucket("hubverse/hubutils/testhubs/simple/")
submission_tmpl(
  path = s3_hub_path,
  round_id = "2022-10-01",
  output_types = "quantile"
)
#> ℹ Updating superseded URL `Infectious-Disease-Modeling-hubs` to `hubverse-org`
#> # A tibble: 4,968 × 7
#>    origin_date target          horizon location output_type output_type_id value
#>    <date>      <chr>             <int> <chr>    <chr>                <dbl> <int>
#>  1 2022-10-01  wk inc flu hosp       1 US       quantile              0.01    NA
#>  2 2022-10-01  wk inc flu hosp       2 US       quantile              0.01    NA
#>  3 2022-10-01  wk inc flu hosp       3 US       quantile              0.01    NA
#>  4 2022-10-01  wk inc flu hosp       4 US       quantile              0.01    NA
#>  5 2022-10-01  wk inc flu hosp       1 01       quantile              0.01    NA
#>  6 2022-10-01  wk inc flu hosp       2 01       quantile              0.01    NA
#>  7 2022-10-01  wk inc flu hosp       3 01       quantile              0.01    NA
#>  8 2022-10-01  wk inc flu hosp       4 01       quantile              0.01    NA
#>  9 2022-10-01  wk inc flu hosp       1 02       quantile              0.01    NA
#> 10 2022-10-01  wk inc flu hosp       2 02       quantile              0.01    NA
#> # ℹ 4,958 more rows
# Use `path()` method to create a path to the tasks.json file relative to the
# the S3 cloud hub's root directory
s3_config_path <- s3_hub_path$path("hub-config/tasks.json")
submission_tmpl(
  path = s3_config_path,
  round_id = "2022-10-01",
  output_types = "quantile"
)
#> ℹ Updating superseded URL `Infectious-Disease-Modeling-hubs` to `hubverse-org`
#> # A tibble: 4,968 × 7
#>    origin_date target          horizon location output_type output_type_id value
#>    <date>      <chr>             <int> <chr>    <chr>                <dbl> <int>
#>  1 2022-10-01  wk inc flu hosp       1 US       quantile              0.01    NA
#>  2 2022-10-01  wk inc flu hosp       2 US       quantile              0.01    NA
#>  3 2022-10-01  wk inc flu hosp       3 US       quantile              0.01    NA
#>  4 2022-10-01  wk inc flu hosp       4 US       quantile              0.01    NA
#>  5 2022-10-01  wk inc flu hosp       1 01       quantile              0.01    NA
#>  6 2022-10-01  wk inc flu hosp       2 01       quantile              0.01    NA
#>  7 2022-10-01  wk inc flu hosp       3 01       quantile              0.01    NA
#>  8 2022-10-01  wk inc flu hosp       4 01       quantile              0.01    NA
#>  9 2022-10-01  wk inc flu hosp       1 02       quantile              0.01    NA
#> 10 2022-10-01  wk inc flu hosp       2 02       quantile              0.01    NA
#> # ℹ 4,958 more rows
```
