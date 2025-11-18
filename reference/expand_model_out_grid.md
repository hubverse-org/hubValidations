# Create expanded grid of valid task ID and output type value combinations

Create expanded grid of valid task ID and output type value combinations

## Usage

``` r
expand_model_out_grid(
  config_tasks,
  round_id,
  required_vals_only = FALSE,
  force_output_types = FALSE,
  all_character = FALSE,
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date"),
  as_arrow_table = FALSE,
  bind_model_tasks = TRUE,
  include_sample_ids = FALSE,
  compound_taskid_set = NULL,
  output_types = NULL,
  derived_task_ids = get_config_derived_task_ids(config_tasks, round_id)
)
```

## Arguments

- config_tasks:

  a list version of the content's of a hub's `tasks.json` config file,
  accessed through the `"config_tasks"` attribute of a
  `<hub_connection>` object or function
  [`hubUtils::read_config()`](https://hubverse-org.github.io/hubUtils/reference/read_config.html).

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

- all_character:

  Logical. Whether to return all character column.

- output_type_id_datatype:

  character string. One of `"from_config"`, `"auto"`, `"character"`,
  `"double"`, `"integer"`, `"logical"`, `"Date"`. Defaults to
  `"from_config"` which uses the setting in the
  `output_type_id_datatype` property in the `tasks.json` config file if
  available. If the property is not set in the config, the argument
  falls back to `"auto"` which determines the `output_type_id` data type
  automatically from the `tasks.json` config file as the simplest data
  type required to represent all output type ID values across all output
  types in the hub. When only point estimate output types (where
  `output_type_id`s are `NA`,) are being collected by a hub, the
  `output_type_id` column is assigned a `character` data type when
  auto-determined. Other data type values can be used to override
  automatic determination. Note that attempting to coerce
  `output_type_id` to a data type that is not valid for the data (e.g.
  trying to coerce`"character"` values to `"double"`) will likely result
  in an error or potentially unexpected behaviour so use with care.

- as_arrow_table:

  Logical. Whether to return an arrow table. Defaults to `FALSE`.

- bind_model_tasks:

  Logical. Whether to bind expanded grids of values from multiple
  modeling tasks into a single tibble/arrow table or return a list.

- include_sample_ids:

  Logical. Whether to include sample identifiers in the `output_type_id`
  column.

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
  contain `NA`s. Defaults to extracting derived task IDs from
  `config_tasks`. See
  [`get_config_derived_task_ids()`](https://hubverse-org.github.io/hubValidations/reference/get_config_derived_task_ids.md)
  for more details.

## Value

If `bind_model_tasks = TRUE` (default) a tibble or arrow table
containing all possible task ID and related output type ID value
combinations. If `bind_model_tasks = FALSE`, a list containing a tibble
or arrow table for each round modeling task.

Columns are coerced to data types according to the hub schema, unless
`all_character = TRUE`. If `all_character = TRUE`, all columns are
returned as character which can be faster when large expanded grids are
expected. If `required_vals_only = TRUE`, values are limited to the
combinations of required values only.

Note that if `required_vals_only = TRUE` and an optional output type is
requested through `output_types`, a zero row grid will be returned. If
all output types are requested however (i.e. when `output_types = NULL`)
and they are all optional, a grid of required task ID values only will
be returned. However, whenever `force_output_types = TRUE`, all output
types are treated as required.

## Details

When a round is set to `round_id_from_variable: true`, the value of the
task ID from which round IDs are derived (i.e. the task ID specified in
`round_id` property of `config_tasks`) is set to the value of the
`round_id` argument in the returned output.

When sample output types are included in the output and
`include_sample_ids = TRUE`, the `output_type_id` column contains
example sample indexes which are useful for identifying the compound
task ID structure of multivariate sampling distributions in particular,
i.e. which combinations of task ID values represent individual samples.

## Examples

``` r
hub_con <- hubData::connect_hub(
  system.file("testhubs/flusight", package = "hubUtils")
)
config_tasks <- attr(hub_con, "config_tasks")
expand_model_out_grid(config_tasks, round_id = "2023-01-02")
#> # A tibble: 3,132 × 6
#>    forecast_date target              horizon location output_type output_type_id
#>    <date>        <chr>                 <int> <chr>    <chr>       <chr>         
#>  1 2023-01-02    wk flu hosp rate c…       2 US       pmf         large_decrease
#>  2 2023-01-02    wk flu hosp rate c…       1 US       pmf         large_decrease
#>  3 2023-01-02    wk flu hosp rate c…       2 01       pmf         large_decrease
#>  4 2023-01-02    wk flu hosp rate c…       1 01       pmf         large_decrease
#>  5 2023-01-02    wk flu hosp rate c…       2 02       pmf         large_decrease
#>  6 2023-01-02    wk flu hosp rate c…       1 02       pmf         large_decrease
#>  7 2023-01-02    wk flu hosp rate c…       2 04       pmf         large_decrease
#>  8 2023-01-02    wk flu hosp rate c…       1 04       pmf         large_decrease
#>  9 2023-01-02    wk flu hosp rate c…       2 05       pmf         large_decrease
#> 10 2023-01-02    wk flu hosp rate c…       1 05       pmf         large_decrease
#> # ℹ 3,122 more rows
expand_model_out_grid(
  config_tasks,
  round_id = "2023-01-02",
  required_vals_only = TRUE
)
#> # A tibble: 28 × 5
#>    forecast_date horizon location output_type output_type_id
#>    <date>          <int> <chr>    <chr>       <chr>         
#>  1 2023-01-02          2 US       pmf         large_decrease
#>  2 2023-01-02          2 US       pmf         decrease      
#>  3 2023-01-02          2 US       pmf         stable        
#>  4 2023-01-02          2 US       pmf         increase      
#>  5 2023-01-02          2 US       pmf         large_increase
#>  6 2023-01-02          2 US       quantile    0.01          
#>  7 2023-01-02          2 US       quantile    0.025         
#>  8 2023-01-02          2 US       quantile    0.05          
#>  9 2023-01-02          2 US       quantile    0.1           
#> 10 2023-01-02          2 US       quantile    0.15          
#> # ℹ 18 more rows
# Specifying a round in a hub with multiple round configurations.
hub_con <- hubData::connect_hub(
  system.file("testhubs/simple", package = "hubUtils")
)
config_tasks <- attr(hub_con, "config_tasks")
expand_model_out_grid(config_tasks, round_id = "2022-10-01")
#> # A tibble: 5,184 × 6
#>    origin_date target          horizon location output_type output_type_id
#>    <date>      <chr>             <int> <chr>    <chr>                <dbl>
#>  1 2022-10-01  wk inc flu hosp       1 US       mean                    NA
#>  2 2022-10-01  wk inc flu hosp       2 US       mean                    NA
#>  3 2022-10-01  wk inc flu hosp       3 US       mean                    NA
#>  4 2022-10-01  wk inc flu hosp       4 US       mean                    NA
#>  5 2022-10-01  wk inc flu hosp       1 01       mean                    NA
#>  6 2022-10-01  wk inc flu hosp       2 01       mean                    NA
#>  7 2022-10-01  wk inc flu hosp       3 01       mean                    NA
#>  8 2022-10-01  wk inc flu hosp       4 01       mean                    NA
#>  9 2022-10-01  wk inc flu hosp       1 02       mean                    NA
#> 10 2022-10-01  wk inc flu hosp       2 02       mean                    NA
#> # ℹ 5,174 more rows
# Later round_id maps to round config that includes additional task ID 'age_group'.
expand_model_out_grid(config_tasks, round_id = "2022-10-29")
#> # A tibble: 25,920 × 7
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
# Coerce all columns to character
expand_model_out_grid(config_tasks,
  round_id = "2022-10-29",
  all_character = TRUE
)
#> # A tibble: 25,920 × 7
#>    origin_date target      horizon location age_group output_type output_type_id
#>    <chr>       <chr>       <chr>   <chr>    <chr>     <chr>       <chr>         
#>  1 2022-10-29  wk inc flu… 1       US       65+       mean        NA            
#>  2 2022-10-29  wk inc flu… 2       US       65+       mean        NA            
#>  3 2022-10-29  wk inc flu… 3       US       65+       mean        NA            
#>  4 2022-10-29  wk inc flu… 4       US       65+       mean        NA            
#>  5 2022-10-29  wk inc flu… 1       01       65+       mean        NA            
#>  6 2022-10-29  wk inc flu… 2       01       65+       mean        NA            
#>  7 2022-10-29  wk inc flu… 3       01       65+       mean        NA            
#>  8 2022-10-29  wk inc flu… 4       01       65+       mean        NA            
#>  9 2022-10-29  wk inc flu… 1       02       65+       mean        NA            
#> 10 2022-10-29  wk inc flu… 2       02       65+       mean        NA            
#> # ℹ 25,910 more rows
# Return arrow table
expand_model_out_grid(config_tasks,
  round_id = "2022-10-29",
  all_character = TRUE,
  as_arrow_table = TRUE
)
#> Table
#> 25920 rows x 7 columns
#> $origin_date <string>
#> $target <string>
#> $horizon <string>
#> $location <string>
#> $age_group <string>
#> $output_type <string>
#> $output_type_id <string>
# Hub with sample output type
config_tasks <- read_config_file(system.file("config", "tasks.json",
  package = "hubValidations"
))
expand_model_out_grid(config_tasks,
  round_id = "2022-12-26"
)
#> # A tibble: 42 × 6
#>    forecast_date target              horizon location output_type output_type_id
#>    <date>        <chr>                 <int> <chr>    <chr>       <chr>         
#>  1 2022-12-26    wk ahead inc flu h…       2 US       sample      NA            
#>  2 2022-12-26    wk ahead inc flu h…       1 US       sample      NA            
#>  3 2022-12-26    wk ahead inc flu h…       2 01       sample      NA            
#>  4 2022-12-26    wk ahead inc flu h…       1 01       sample      NA            
#>  5 2022-12-26    wk ahead inc flu h…       2 02       sample      NA            
#>  6 2022-12-26    wk ahead inc flu h…       1 02       sample      NA            
#>  7 2022-12-26    wk ahead inc flu h…       2 US       mean        NA            
#>  8 2022-12-26    wk ahead inc flu h…       1 US       mean        NA            
#>  9 2022-12-26    wk ahead inc flu h…       2 01       mean        NA            
#> 10 2022-12-26    wk ahead inc flu h…       1 01       mean        NA            
#> # ℹ 32 more rows
# Include sample IDS
expand_model_out_grid(config_tasks,
  round_id = "2022-12-26",
  include_sample_ids = TRUE
)
#> # A tibble: 42 × 6
#>    forecast_date target              horizon location output_type output_type_id
#>    <date>        <chr>                 <int> <chr>    <chr>       <chr>         
#>  1 2022-12-26    wk ahead inc flu h…       2 US       mean        NA            
#>  2 2022-12-26    wk ahead inc flu h…       1 US       mean        NA            
#>  3 2022-12-26    wk ahead inc flu h…       2 01       mean        NA            
#>  4 2022-12-26    wk ahead inc flu h…       1 01       mean        NA            
#>  5 2022-12-26    wk ahead inc flu h…       2 02       mean        NA            
#>  6 2022-12-26    wk ahead inc flu h…       1 02       mean        NA            
#>  7 2022-12-26    wk ahead inc flu h…       2 US       sample      s1            
#>  8 2022-12-26    wk ahead inc flu h…       1 US       sample      s2            
#>  9 2022-12-26    wk ahead inc flu h…       2 01       sample      s3            
#> 10 2022-12-26    wk ahead inc flu h…       1 01       sample      s4            
#> # ℹ 32 more rows
# Hub with sample output type and compound task ID structure
config_tasks <- read_config_file(
  system.file("config", "tasks-comp-tid.json", package = "hubValidations")
)
expand_model_out_grid(config_tasks,
  round_id = "2022-12-26",
  include_sample_ids = TRUE
)
#> # A tibble: 42 × 6
#>    forecast_date target              horizon location output_type output_type_id
#>    <date>        <chr>                 <int> <chr>    <chr>       <chr>         
#>  1 2022-12-26    wk ahead inc flu h…       2 US       mean        NA            
#>  2 2022-12-26    wk ahead inc flu h…       1 US       mean        NA            
#>  3 2022-12-26    wk ahead inc flu h…       2 01       mean        NA            
#>  4 2022-12-26    wk ahead inc flu h…       1 01       mean        NA            
#>  5 2022-12-26    wk ahead inc flu h…       2 02       mean        NA            
#>  6 2022-12-26    wk ahead inc flu h…       1 02       mean        NA            
#>  7 2022-12-26    wk ahead inc flu h…       2 US       sample      1             
#>  8 2022-12-26    wk ahead inc flu h…       2 01       sample      1             
#>  9 2022-12-26    wk ahead inc flu h…       2 02       sample      1             
#> 10 2022-12-26    wk ahead inc flu h…       1 US       sample      2             
#> # ℹ 32 more rows
# Override config compound task ID set
# Create coarser compound task ID set for the first modeling task which contains
# samples
expand_model_out_grid(config_tasks,
  round_id = "2022-12-26",
  include_sample_ids = TRUE,
  compound_taskid_set = list(
    c("forecast_date", "target"),
    NULL
  )
)
#> # A tibble: 42 × 6
#>    forecast_date target              horizon location output_type output_type_id
#>    <date>        <chr>                 <int> <chr>    <chr>       <chr>         
#>  1 2022-12-26    wk ahead inc flu h…       2 US       mean        NA            
#>  2 2022-12-26    wk ahead inc flu h…       1 US       mean        NA            
#>  3 2022-12-26    wk ahead inc flu h…       2 01       mean        NA            
#>  4 2022-12-26    wk ahead inc flu h…       1 01       mean        NA            
#>  5 2022-12-26    wk ahead inc flu h…       2 02       mean        NA            
#>  6 2022-12-26    wk ahead inc flu h…       1 02       mean        NA            
#>  7 2022-12-26    wk ahead inc flu h…       2 US       sample      1             
#>  8 2022-12-26    wk ahead inc flu h…       1 US       sample      1             
#>  9 2022-12-26    wk ahead inc flu h…       2 01       sample      1             
#> 10 2022-12-26    wk ahead inc flu h…       1 01       sample      1             
#> # ℹ 32 more rows
expand_model_out_grid(config_tasks,
  round_id = "2022-12-26",
  include_sample_ids = TRUE,
  compound_taskid_set = list(
    NULL,
    NULL
  )
)
#> # A tibble: 42 × 6
#>    forecast_date target              horizon location output_type output_type_id
#>    <date>        <chr>                 <int> <chr>    <chr>       <chr>         
#>  1 2022-12-26    wk ahead inc flu h…       2 US       mean        NA            
#>  2 2022-12-26    wk ahead inc flu h…       1 US       mean        NA            
#>  3 2022-12-26    wk ahead inc flu h…       2 01       mean        NA            
#>  4 2022-12-26    wk ahead inc flu h…       1 01       mean        NA            
#>  5 2022-12-26    wk ahead inc flu h…       2 02       mean        NA            
#>  6 2022-12-26    wk ahead inc flu h…       1 02       mean        NA            
#>  7 2022-12-26    wk ahead inc flu h…       2 US       sample      1             
#>  8 2022-12-26    wk ahead inc flu h…       1 US       sample      2             
#>  9 2022-12-26    wk ahead inc flu h…       2 01       sample      3             
#> 10 2022-12-26    wk ahead inc flu h…       1 01       sample      4             
#> # ℹ 32 more rows
# Subset output types
config_tasks <- read_config(
  system.file("testhubs", "samples", package = "hubValidations")
)
expand_model_out_grid(config_tasks,
  round_id = "2022-10-29",
  include_sample_ids = TRUE,
  bind_model_tasks = FALSE,
  output_types = c("sample", "pmf"),
)
#> [[1]]
#> # A tibble: 2,560 × 7
#>    reference_date target            horizon location target_end_date output_type
#>    <date>         <chr>               <int> <chr>    <date>          <chr>      
#>  1 2022-10-29     wk flu hosp rate…       0 US       2022-10-22      pmf        
#>  2 2022-10-29     wk flu hosp rate…       1 US       2022-10-22      pmf        
#>  3 2022-10-29     wk flu hosp rate…       2 US       2022-10-22      pmf        
#>  4 2022-10-29     wk flu hosp rate…       3 US       2022-10-22      pmf        
#>  5 2022-10-29     wk flu hosp rate…       0 01       2022-10-22      pmf        
#>  6 2022-10-29     wk flu hosp rate…       1 01       2022-10-22      pmf        
#>  7 2022-10-29     wk flu hosp rate…       2 01       2022-10-22      pmf        
#>  8 2022-10-29     wk flu hosp rate…       3 01       2022-10-22      pmf        
#>  9 2022-10-29     wk flu hosp rate…       0 02       2022-10-22      pmf        
#> 10 2022-10-29     wk flu hosp rate…       1 02       2022-10-22      pmf        
#> # ℹ 2,550 more rows
#> # ℹ 1 more variable: output_type_id <chr>
#> 
#> [[2]]
#> # A tibble: 640 × 7
#>    reference_date target          horizon location target_end_date output_type
#>    <date>         <chr>             <int> <chr>    <date>          <chr>      
#>  1 2022-10-29     wk inc flu hosp       0 US       2022-10-22      sample     
#>  2 2022-10-29     wk inc flu hosp       1 US       2022-10-22      sample     
#>  3 2022-10-29     wk inc flu hosp       2 US       2022-10-22      sample     
#>  4 2022-10-29     wk inc flu hosp       3 US       2022-10-22      sample     
#>  5 2022-10-29     wk inc flu hosp       0 US       2022-10-29      sample     
#>  6 2022-10-29     wk inc flu hosp       1 US       2022-10-29      sample     
#>  7 2022-10-29     wk inc flu hosp       2 US       2022-10-29      sample     
#>  8 2022-10-29     wk inc flu hosp       3 US       2022-10-29      sample     
#>  9 2022-10-29     wk inc flu hosp       0 US       2022-11-05      sample     
#> 10 2022-10-29     wk inc flu hosp       1 US       2022-11-05      sample     
#> # ℹ 630 more rows
#> # ℹ 1 more variable: output_type_id <chr>
#> 
expand_model_out_grid(config_tasks,
  round_id = "2022-10-29",
  include_sample_ids = TRUE,
  bind_model_tasks = TRUE,
  output_types = "sample",
)
#> # A tibble: 640 × 7
#>    reference_date target          horizon location target_end_date output_type
#>    <date>         <chr>             <int> <chr>    <date>          <chr>      
#>  1 2022-10-29     wk inc flu hosp       0 US       2022-10-22      sample     
#>  2 2022-10-29     wk inc flu hosp       1 US       2022-10-22      sample     
#>  3 2022-10-29     wk inc flu hosp       2 US       2022-10-22      sample     
#>  4 2022-10-29     wk inc flu hosp       3 US       2022-10-22      sample     
#>  5 2022-10-29     wk inc flu hosp       0 US       2022-10-29      sample     
#>  6 2022-10-29     wk inc flu hosp       1 US       2022-10-29      sample     
#>  7 2022-10-29     wk inc flu hosp       2 US       2022-10-29      sample     
#>  8 2022-10-29     wk inc flu hosp       3 US       2022-10-29      sample     
#>  9 2022-10-29     wk inc flu hosp       0 US       2022-11-05      sample     
#> 10 2022-10-29     wk inc flu hosp       1 US       2022-11-05      sample     
#> # ℹ 630 more rows
#> # ℹ 1 more variable: output_type_id <chr>
# Ignore derived task IDs
expand_model_out_grid(config_tasks,
  round_id = "2022-10-29",
  include_sample_ids = TRUE,
  bind_model_tasks = FALSE,
  output_types = "sample",
  derived_task_ids = "target_end_date"
)
#> [[1]]
#> # A tibble: 0 × 0
#> 
#> [[2]]
#> # A tibble: 20 × 7
#>    reference_date target          horizon location target_end_date output_type
#>    <date>         <chr>             <int> <chr>    <date>          <chr>      
#>  1 2022-10-29     wk inc flu hosp       0 US       NA              sample     
#>  2 2022-10-29     wk inc flu hosp       1 US       NA              sample     
#>  3 2022-10-29     wk inc flu hosp       2 US       NA              sample     
#>  4 2022-10-29     wk inc flu hosp       3 US       NA              sample     
#>  5 2022-10-29     wk inc flu hosp       0 01       NA              sample     
#>  6 2022-10-29     wk inc flu hosp       1 01       NA              sample     
#>  7 2022-10-29     wk inc flu hosp       2 01       NA              sample     
#>  8 2022-10-29     wk inc flu hosp       3 01       NA              sample     
#>  9 2022-10-29     wk inc flu hosp       0 02       NA              sample     
#> 10 2022-10-29     wk inc flu hosp       1 02       NA              sample     
#> 11 2022-10-29     wk inc flu hosp       2 02       NA              sample     
#> 12 2022-10-29     wk inc flu hosp       3 02       NA              sample     
#> 13 2022-10-29     wk inc flu hosp       0 04       NA              sample     
#> 14 2022-10-29     wk inc flu hosp       1 04       NA              sample     
#> 15 2022-10-29     wk inc flu hosp       2 04       NA              sample     
#> 16 2022-10-29     wk inc flu hosp       3 04       NA              sample     
#> 17 2022-10-29     wk inc flu hosp       0 05       NA              sample     
#> 18 2022-10-29     wk inc flu hosp       1 05       NA              sample     
#> 19 2022-10-29     wk inc flu hosp       2 05       NA              sample     
#> 20 2022-10-29     wk inc flu hosp       3 05       NA              sample     
#> # ℹ 1 more variable: output_type_id <chr>
#> 
# Return only required values
hub_path <- system.file("testhubs", "v4", "simple", package = "hubUtils")
config_tasks <- read_config(hub_path)
# Return required output types and output_types_ids only
expand_model_out_grid(
  config_tasks = config_tasks,
  round_id = "2022-10-22",
  required_vals_only = TRUE
)
#> # A tibble: 23 × 6
#>    origin_date target          horizon age_group output_type output_type_id
#>    <date>      <chr>             <int> <chr>     <chr>                <dbl>
#>  1 2022-10-22  wk inc flu hosp       1 65+       quantile             0.01 
#>  2 2022-10-22  wk inc flu hosp       1 65+       quantile             0.025
#>  3 2022-10-22  wk inc flu hosp       1 65+       quantile             0.05 
#>  4 2022-10-22  wk inc flu hosp       1 65+       quantile             0.1  
#>  5 2022-10-22  wk inc flu hosp       1 65+       quantile             0.15 
#>  6 2022-10-22  wk inc flu hosp       1 65+       quantile             0.2  
#>  7 2022-10-22  wk inc flu hosp       1 65+       quantile             0.25 
#>  8 2022-10-22  wk inc flu hosp       1 65+       quantile             0.3  
#>  9 2022-10-22  wk inc flu hosp       1 65+       quantile             0.35 
#> 10 2022-10-22  wk inc flu hosp       1 65+       quantile             0.4  
#> # ℹ 13 more rows
# Force all output types to be required
expand_model_out_grid(
  config_tasks = config_tasks,
  round_id = "2022-10-22",
  required_vals_only = TRUE,
  force_output_types = TRUE
)
#> # A tibble: 24 × 6
#>    origin_date target          horizon age_group output_type output_type_id
#>    <date>      <chr>             <int> <chr>     <chr>                <dbl>
#>  1 2022-10-22  wk inc flu hosp       1 65+       mean                NA    
#>  2 2022-10-22  wk inc flu hosp       1 65+       quantile             0.01 
#>  3 2022-10-22  wk inc flu hosp       1 65+       quantile             0.025
#>  4 2022-10-22  wk inc flu hosp       1 65+       quantile             0.05 
#>  5 2022-10-22  wk inc flu hosp       1 65+       quantile             0.1  
#>  6 2022-10-22  wk inc flu hosp       1 65+       quantile             0.15 
#>  7 2022-10-22  wk inc flu hosp       1 65+       quantile             0.2  
#>  8 2022-10-22  wk inc flu hosp       1 65+       quantile             0.25 
#>  9 2022-10-22  wk inc flu hosp       1 65+       quantile             0.3  
#> 10 2022-10-22  wk inc flu hosp       1 65+       quantile             0.35 
#> # ℹ 14 more rows
# Sub-setting for an optional output type returns an empty data frame
expand_model_out_grid(
  config_tasks = config_tasks,
  round_id = "2022-10-22",
  output_types = "mean",
  required_vals_only = TRUE
)
#> data frame with 0 columns and 0 rows
# force_output_types on an optional output type forces all output_type_id values
# to be required
expand_model_out_grid(
  config_tasks = config_tasks,
  round_id = "2022-10-22",
  output_types = "mean",
  required_vals_only = TRUE,
  force_output_types = TRUE
)
#> # A tibble: 1 × 6
#>   origin_date target          horizon age_group output_type output_type_id
#>   <date>      <chr>             <int> <chr>     <chr>                <dbl>
#> 1 2022-10-22  wk inc flu hosp       1 65+       mean                    NA
# Ignore derived task IDs
hub_path <- system.file("testhubs", "v4", "flusight", package = "hubUtils")
config_tasks <- read_config(hub_path)
# Defaults to using derived_task_ids from config
expand_model_out_grid(config_tasks, round_id = "2023-05-08")
#> # A tibble: 3,132 × 7
#>    forecast_date target  horizon target_date location output_type output_type_id
#>    <date>        <chr>     <int> <date>      <chr>    <chr>       <chr>         
#>  1 2023-05-08    wk flu…       2 NA          US       pmf         large_decrease
#>  2 2023-05-08    wk flu…       1 NA          US       pmf         large_decrease
#>  3 2023-05-08    wk flu…       2 NA          01       pmf         large_decrease
#>  4 2023-05-08    wk flu…       1 NA          01       pmf         large_decrease
#>  5 2023-05-08    wk flu…       2 NA          02       pmf         large_decrease
#>  6 2023-05-08    wk flu…       1 NA          02       pmf         large_decrease
#>  7 2023-05-08    wk flu…       2 NA          04       pmf         large_decrease
#>  8 2023-05-08    wk flu…       1 NA          04       pmf         large_decrease
#>  9 2023-05-08    wk flu…       2 NA          05       pmf         large_decrease
#> 10 2023-05-08    wk flu…       1 NA          05       pmf         large_decrease
#> # ℹ 3,122 more rows
# Can be overridden by argument derived_task_ids
expand_model_out_grid(config_tasks,
  round_id = "2023-05-08",
  derived_task_ids = NULL
)
#> # A tibble: 72,036 × 7
#>    forecast_date target  horizon target_date location output_type output_type_id
#>    <date>        <chr>     <int> <date>      <chr>    <chr>       <chr>         
#>  1 2023-05-08    wk flu…       2 2022-12-19  US       pmf         large_decrease
#>  2 2023-05-08    wk flu…       1 2022-12-19  US       pmf         large_decrease
#>  3 2023-05-08    wk flu…       2 2022-12-26  US       pmf         large_decrease
#>  4 2023-05-08    wk flu…       1 2022-12-26  US       pmf         large_decrease
#>  5 2023-05-08    wk flu…       2 2023-01-02  US       pmf         large_decrease
#>  6 2023-05-08    wk flu…       1 2023-01-02  US       pmf         large_decrease
#>  7 2023-05-08    wk flu…       2 2023-01-09  US       pmf         large_decrease
#>  8 2023-05-08    wk flu…       1 2023-01-09  US       pmf         large_decrease
#>  9 2023-05-08    wk flu…       2 2023-01-16  US       pmf         large_decrease
#> 10 2023-05-08    wk flu…       1 2023-01-16  US       pmf         large_decrease
#> # ℹ 72,026 more rows
```
