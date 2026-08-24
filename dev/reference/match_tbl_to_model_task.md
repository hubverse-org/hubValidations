# Match model output data to their model tasks in `config_tasks`.

Useful for performing model task specific checks on model output.

## Usage

``` r
match_tbl_to_model_task(
  tbl,
  config_tasks,
  round_id,
  output_types = NULL,
  derived_task_ids = get_config_derived_task_ids(config_tasks, round_id),
  order_by_config = FALSE
)
```

## Arguments

- tbl:

  a tibble/data.frame of the contents of the file being validated.
  Column types must **all be character**: the config's values are
  converted to character when they are extracted, and are compared
  against this table without further conversion. Every task ID column
  the round defines must be present.

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

  Character vector of derived task ID names, or `NULL` for none. A
  derived task ID's value follows from the values of other task IDs. A
  derived task ID cannot therefore further distinguish a row beyond the
  values of the task IDs it is derived from. Derived task ID columns are
  skipped, and returned unchanged.

- order_by_config:

  Logical. How to order each modeling task's rows. `FALSE`, the default,
  leaves them in the order they were submitted in. `TRUE` sorts them
  into the order the config lists their values in: on `output_type`
  first, so rows of one output type sit together, then on
  `output_type_id`, so they ascend within each, then on the task IDs to
  break ties.

  What is sorted on is each value's position in the config, not the
  value itself. `pmf` categories show why that matters: `"low"`,
  `"moderate"` and `"high"` have no useful alphabetical order, but the
  config lists them in the order they belong in.
  [`check_tbl_value_col_ascending()`](https://hubverse-org.github.io/hubValidations/dev/reference/check_tbl_value_col_ascending.md)
  asks for this order, because it reads values in the order the rows
  arrive in.

  In the config a task ID's values are split into `required` and
  `optional`. Extracting them collapses the two into a single order,
  `required` values first, then `optional` ones, and that is the order
  sorted on.

  Sample rows are ordered by their task ID values only.

## Value

A list with one element per model task in the round, each a `tbl_df` of
the model output rows matched to that model task. A model task that
offers none of the requested `output_types` gets `NULL`. Rows that match
no model task are not returned.

## Details

Sample `output_type_id` values are returned as submitted. The submitter
chooses them, so this function does not check them against the config.

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
#>  1 2022-10-22     wk flu hosp rate… 0       01       2022-10-22      pmf        
#>  2 2022-10-22     wk flu hosp rate… 0       01       2022-10-22      pmf        
#>  3 2022-10-22     wk flu hosp rate… 0       01       2022-10-22      pmf        
#>  4 2022-10-22     wk flu hosp rate… 0       01       2022-10-22      pmf        
#>  5 2022-10-22     wk flu hosp rate… 1       01       2022-10-29      pmf        
#>  6 2022-10-22     wk flu hosp rate… 1       01       2022-10-29      pmf        
#>  7 2022-10-22     wk flu hosp rate… 1       01       2022-10-29      pmf        
#>  8 2022-10-22     wk flu hosp rate… 1       01       2022-10-29      pmf        
#>  9 2022-10-22     wk flu hosp rate… 2       01       2022-11-05      pmf        
#> 10 2022-10-22     wk flu hosp rate… 2       01       2022-11-05      pmf        
#> # ℹ 50 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <chr>
#> 
#> [[2]]
#> # A tibble: 1,530 × 8
#>    reference_date target          horizon location target_end_date output_type
#>    <chr>          <chr>           <chr>   <chr>    <chr>           <chr>      
#>  1 2022-10-22     wk inc flu hosp 0       US       2022-10-22      median     
#>  2 2022-10-22     wk inc flu hosp 1       US       2022-10-29      median     
#>  3 2022-10-22     wk inc flu hosp 2       US       2022-11-05      median     
#>  4 2022-10-22     wk inc flu hosp 0       01       2022-10-22      median     
#>  5 2022-10-22     wk inc flu hosp 1       01       2022-10-29      median     
#>  6 2022-10-22     wk inc flu hosp 2       01       2022-11-05      median     
#>  7 2022-10-22     wk inc flu hosp 0       02       2022-10-22      median     
#>  8 2022-10-22     wk inc flu hosp 1       02       2022-10-29      median     
#>  9 2022-10-22     wk inc flu hosp 2       02       2022-11-05      median     
#> 10 2022-10-22     wk inc flu hosp 0       04       2022-10-22      median     
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
#>  1 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#>  2 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#>  3 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#>  4 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#>  5 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#>  6 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#>  7 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#>  8 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#>  9 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#> 10 2022-10-22     wk inc flu hosp 0       01       2022-10-22      sample     
#> # ℹ 1,490 more rows
#> # ℹ 2 more variables: output_type_id <chr>, value <chr>
#> 
```
