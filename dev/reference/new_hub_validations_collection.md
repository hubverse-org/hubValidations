# Create new or convert list to `hub_validations_collection` S3 class object

A `hub_validations_collection` is a container for validation results
from multiple validation subjects. It is a named list where each element
is a `hub_validations` object. Names are automatically extracted from
the `where` attribute of each `hub_validations` object. If multiple
`hub_validations` objects have the same `where` value, they are merged
using
[`combine()`](https://hubverse-org.github.io/hubValidations/dev/reference/combine.md).
Empty `hub_validations` objects are ignored.

## Usage

``` r
new_hub_validations_collection(...)

as_hub_validations_collection(x)
```

## Arguments

- ...:

  `hub_validations` objects to be included.

- x:

  a list where each element is a `hub_validations` object.

## Value

an S3 object of class `<hub_validations_collection>`. Elements are named
by their `where` attribute (e.g., `collection[["path/to/file.csv"]]`).

## Functions

- `new_hub_validations_collection()`: Create new
  `<hub_validations_collection>` S3 class object

- `as_hub_validations_collection()`: Convert list to
  `<hub_validations_collection>` S3 class object

## Examples

``` r
new_hub_validations_collection()
#> Empty <hub_validations_collection>

hub_path <- system.file("testhubs/simple", package = "hubValidations")

# Create validations for two different files
file_path_1 <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
validations_1 <- new_hub_validations(
  file_exists = check_file_exists(file_path_1, hub_path),
  file_name = check_file_name(file_path_1)
)

file_path_2 <- "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
validations_2 <- new_hub_validations(
  file_exists = check_file_exists(file_path_2, hub_path),
  file_name = check_file_name(file_path_2)
)

# Combine into a collection
collection <- new_hub_validations_collection(validations_1, validations_2)

# Print the collection
collection
#> 
#> ── team1-goodmodel/2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
#> 
#> ── team1-goodmodel/2022-10-15-team1-goodmodel.csv ────
#> 
#> ⓧ [file_exists]: File does not exist at path
#>   model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-15-team1-goodmodel.csv" is valid.

# Get file paths (element names)
names(collection)
#> [1] "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#> [2] "team1-goodmodel/2022-10-15-team1-goodmodel.csv"

# Access validations for a specific file
collection[[file_path_1]]
#> 
#> ── team1-goodmodel/2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.

# Access validations for a specific file and check
collection$`team1-goodmodel/2022-10-08-team1-goodmodel.csv`$file_exists
#> <message/check_success>
#> Message:
#> File exists at path
#> model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
```
