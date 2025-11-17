# Match model output `tbl` data to their model tasks in `config_tasks`.

Split and match model output `tbl` data to their corresponding model
tasks in `config_tasks`. Useful for performing model task specific
checks on model output. For v3 samples, the `output_type_id` column is
set to `NA` for `sample` outputs.

## Usage

``` r
match_tbl_to_model_task(
  tbl,
  config_tasks,
  round_id,
  output_types = NULL,
  derived_task_ids = get_config_derived_task_ids(config_tasks, round_id),
  all_character = TRUE
)
```

## Arguments

- tbl:

  a tibble/data.frame of the contents of the file being validated.

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

- output_types:

  Character vector of output type names to include. Use to subset for
  grids for specific output types.

- derived_task_ids:

  Character vector of derived task ID names (task IDs whose values
  depend on other task IDs) to ignore. Columns for such task ids will
  contain `NA`s. Defaults to extracting derived task IDs from
  `config_tasks`. See
  [`get_config_derived_task_ids()`](https://hubverse-org.github.io/hubValidations/dev/reference/get_config_derived_task_ids.md)
  for more details.

- all_character:

  Logical. Whether to return all character column.

## Value

A list containing a `tbl_df` of model output data matched to a model
task with one element per round model task.

## Examples

``` r
hub_path <- system.file("testhubs/samples", package = "hubValidations")
tbl <- read_model_out_file(
  file_path = "flu-base/2022-10-22-flu-base.csv",
  hub_path, coerce_types = "chr"
)
config_tasks <- read_config(hub_path, "tasks")
match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22")
#> [[1]]
#> # A tibble: 60 × 8
#>    reference_date target            horizon location target_end_date output_type
#>    <chr>          <chr>             <chr>   <chr>    <chr>           <chr>      
#>  1 2022-10-22     wk flu hosp rate… 0       US       2022-10-22      pmf        
#>  2 2022-10-22     wk flu hosp rate… 0       01       2022-10-22      pmf        
#>  3 2022-10-22     wk flu hosp rate… 0       02       2022-10-22      pmf        
#>  4 2022-10-22     wk flu hosp rate… 0       04       2022-10-22      pmf        
#>  5 2022-10-22     wk flu hosp rate… 0       05       2022-10-22      pmf        
#>  6 2022-10-22     wk flu hosp rate… 1       US       2022-10-29      pmf        
#>  7 2022-10-22     wk flu hosp rate… 1       01       2022-10-29      pmf        
#>  8 2022-10-22     wk flu hosp rate… 1       02       2022-10-29      pmf        
#>  9 2022-10-22     wk flu hosp rate… 1       04       2022-10-29      pmf        
#> 10 2022-10-22     wk flu hosp rate… 1       05       2022-10-29      pmf        
#> # ℹ 50 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <chr>
#> 
#> [[2]]
#> # A tibble: 1,530 × 8
#>    reference_date target          horizon location target_end_date output_type
#>    <chr>          <chr>           <chr>   <chr>    <chr>           <chr>      
#>  1 2022-10-22     wk inc flu hosp 0       US       2022-10-22      mean       
#>  2 2022-10-22     wk inc flu hosp 0       01       2022-10-22      mean       
#>  3 2022-10-22     wk inc flu hosp 0       02       2022-10-22      mean       
#>  4 2022-10-22     wk inc flu hosp 0       04       2022-10-22      mean       
#>  5 2022-10-22     wk inc flu hosp 0       05       2022-10-22      mean       
#>  6 2022-10-22     wk inc flu hosp 1       US       2022-10-29      mean       
#>  7 2022-10-22     wk inc flu hosp 1       01       2022-10-29      mean       
#>  8 2022-10-22     wk inc flu hosp 1       02       2022-10-29      mean       
#>  9 2022-10-22     wk inc flu hosp 1       04       2022-10-29      mean       
#> 10 2022-10-22     wk inc flu hosp 1       05       2022-10-29      mean       
#> # ℹ 1,520 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <chr>
#> 
match_tbl_to_model_task(tbl, config_tasks,
  round_id = "2022-10-22",
  output_types = "sample"
)
#> [[1]]
#> NULL
#> 
#> [[2]]
#> # A tibble: 1,500 × 8
#>    reference_date target          horizon location target_end_date output_type
#>    <chr>          <chr>           <chr>   <chr>    <chr>           <chr>      
#>  1 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#>  2 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#>  3 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#>  4 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#>  5 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#>  6 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#>  7 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#>  8 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#>  9 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#> 10 2022-10-22     wk inc flu hosp 0       US       2022-10-22      sample     
#> # ℹ 1,490 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <chr>
#> 
```
