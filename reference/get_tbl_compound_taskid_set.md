# Detect the compound_taskid_set for a tbl for each modeling task in a given round.

Detect the compound_taskid_set for a tbl for each modeling task in a
given round.

## Usage

``` r
get_tbl_compound_taskid_set(
  tbl,
  config_tasks,
  round_id,
  compact = TRUE,
  error = TRUE,
  derived_task_ids = get_config_derived_task_ids(config_tasks, round_id)
)
```

## Arguments

- tbl:

  a tibble/data.frame of the contents of the file being validated.
  Column types must **all be character**.

- config_tasks:

  a list representantion of the `tasks.json` config file.

- round_id:

  Character string. The round ID.

- compact:

  Logical. If TRUE, the output will be compacted to remove NULL
  elements.

- error:

  Logical. If TRUE, an error will be thrown if the compound task ID set
  is not valid. If FALSE and an error is detected, the detected compound
  task ID set will be returned with error attributes attached.

- derived_task_ids:

  Character vector of derived task ID names (task IDs whose values
  depend on other task IDs) to ignore. Columns for such task ids will
  contain `NA`s. Defaults to extracting derived task IDs from
  `config_tasks`. See
  [`get_config_derived_task_ids()`](https://hubverse-org.github.io/hubValidations/reference/get_config_derived_task_ids.md)
  for more details.

## Value

A list of vectors of compound task IDs detected in the tbl, one for each
modeling task in the round. If `compact` is TRUE, modeling tasks
returning NULL elements will be removed.

## Examples

``` r
hub_path <- system.file("testhubs/samples", package = "hubValidations")
file_path <- "flu-base/2022-10-22-flu-base.csv"
round_id <- "2022-10-22"
tbl <- read_model_out_file(
  file_path = file_path,
  hub_path = hub_path,
  coerce_types = "chr"
)
config_tasks <- read_config(hub_path, "tasks")
get_tbl_compound_taskid_set(tbl, config_tasks, round_id)
#> $`2`
#> [1] "reference_date" "location"      
#> 
get_tbl_compound_taskid_set(tbl, config_tasks, round_id,
  compact = FALSE
)
#> $`1`
#> NULL
#> 
#> $`2`
#> [1] "reference_date" "location"      
#> 
```
