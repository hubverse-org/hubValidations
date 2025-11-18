# Create new or convert list to `target_validations` S3 class object

Create new or convert list to `target_validations` S3 class object

## Usage

``` r
new_target_validations(...)

as_target_validations(x)
```

## Arguments

- ...:

  named elements to be included. Each element must be an object which
  inherits from class `<hub_check>`.

- x:

  a list of named elements. Each element must be an object which
  inherits from class `<hub_check>`.

## Value

an S3 object of class `<target_validations>`.

## Functions

- `new_target_validations()`: Create new `<target_validations>` S3 class
  object

- `as_target_validations()`: Convert list to `<target_validations>` S3
  class object

## Examples

``` r
new_target_validations()
#> Empty <target_validations>

hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
file_path <- "time-series.csv"
new_target_validations(
  target_file_name = check_target_file_name(file_path),
  target_file_ext_valid = check_target_file_ext_valid(file_path)
)
#> 
#> ── time-series.csv ────
#> 
#> ℹ [target_file_name]: Target file path not hive-partitioned. Check skipped.
#> ✔ [target_file_ext_valid]: Target data file extension is valid.
x <- list(
  target_file_name = check_target_file_name(file_path),
  target_file_ext_valid = check_target_file_ext_valid(file_path)
)
as_target_validations(x)
#> 
#> ── time-series.csv ────
#> 
#> ℹ [target_file_name]: Target file path not hive-partitioned. Check skipped.
#> ✔ [target_file_ext_valid]: Target data file extension is valid.
file_path <- "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"
new_target_validations(
  target_file_name = check_target_file_name(file_path),
  target_file_ext_valid = check_target_file_ext_valid(file_path)
)
#> 
#> ── time-series/target=wk%20flu%20hosp%20rate/part-0.parquet ────
#> 
#> ✔ [target_file_name]: Hive-style partition file path segments are valid.
#> ✔ [target_file_ext_valid]: Hive-partitioned target data file extension is
#>   valid.
```
