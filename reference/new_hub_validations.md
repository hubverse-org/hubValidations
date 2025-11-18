# Create new or convert list to `hub_validations` S3 class object

Create new or convert list to `hub_validations` S3 class object

## Usage

``` r
new_hub_validations(...)

as_hub_validations(x)
```

## Arguments

- ...:

  named elements to be included. Each element must be an object which
  inherits from class `<hub_check>`.

- x:

  a list of named elements. Each element must be an object which
  inherits from class `<hub_check>`.

## Value

an S3 object of class `<hub_validations>`.

## Functions

- `new_hub_validations()`: Create new `<hub_validations>` S3 class
  object

- `as_hub_validations()`: Convert list to `<hub_validations>` S3 class
  object

## Examples

``` r
new_hub_validations()
#> Empty <hub_validations>

hub_path <- system.file("testhubs/simple", package = "hubValidations")
file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
new_hub_validations(
  file_exists = check_file_exists(file_path, hub_path),
  file_name = check_file_name(file_path)
)
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
x <- list(
  file_exists = check_file_exists(file_path, hub_path),
  file_name = check_file_name(file_path)
)
as_hub_validations(x)
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
```
