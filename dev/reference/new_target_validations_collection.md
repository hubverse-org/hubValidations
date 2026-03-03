# Create new or convert list to `target_validations_collection` S3 class object

A `target_validations_collection` is a container for target validation
results from multiple validation subjects. It is a named list where each
element is a `target_validations` object. Names are automatically
extracted from the `where` attribute of each `target_validations`
object. If multiple `target_validations` objects have the same `where`
value, they are merged using
[`combine()`](https://hubverse-org.github.io/hubValidations/dev/reference/combine.md).
Empty `target_validations` objects are ignored.

## Usage

``` r
new_target_validations_collection(...)

as_target_validations_collection(x)
```

## Arguments

- ...:

  `target_validations` objects to be included.

- x:

  a list where each element is a `target_validations` object.

## Value

an S3 object of class `<target_validations_collection>`. Elements are
named by their `where` attribute (e.g.,
`collection[["path/to/file.csv"]]`).

## Functions

- `new_target_validations_collection()`: Create new
  `<target_validations_collection>` S3 class object

- `as_target_validations_collection()`: Convert list to
  `<target_validations_collection>` S3 class object

## Examples

``` r
new_target_validations_collection()
#> Empty <target_validations_collection>

# Create validations for two different files
file_path_1 <- "time-series.csv"
validations_1 <- new_target_validations(
  target_file_name = check_target_file_name(file_path_1),
  target_file_ext_valid = check_target_file_ext_valid(file_path_1)
)

file_path_2 <- "other-data.csv"
validations_2 <- new_target_validations(
  target_file_name = check_target_file_name(file_path_2),
  target_file_ext_valid = check_target_file_ext_valid(file_path_2)
)

# Combine into a collection
collection <- new_target_validations_collection(validations_1, validations_2)

# Print the collection
collection
#> 
#> ── time-series.csv ────
#> 
#> ℹ [target_file_name]: Target file path not hive-partitioned. Check skipped.
#> ✔ [target_file_ext_valid]: Target data file extension is valid.
#> 
#> ── other-data.csv ────
#> 
#> ℹ [target_file_name]: Target file path not hive-partitioned. Check skipped.
#> ✔ [target_file_ext_valid]: Target data file extension is valid.

# Get file paths (element names)
names(collection)
#> [1] "time-series.csv" "other-data.csv" 

# Access validations for a specific file
collection[[file_path_1]]
#> 
#> ── time-series.csv ────
#> 
#> ℹ [target_file_name]: Target file path not hive-partitioned. Check skipped.
#> ✔ [target_file_ext_valid]: Target data file extension is valid.

# Access a specific check within a file's validations
collection[["time-series.csv"]]$target_file_name
#> <message/check_info>
#> Message:
#> Target file path not hive-partitioned. Check skipped.
```
