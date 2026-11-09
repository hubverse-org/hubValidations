# Print results of `validate_...()` function as a bullet list

Prints a formatted summary of validation results. Validation-level
warnings (attached to the `hub_validations` object) are always displayed
prominently in a box at the top. Check-level warnings (attached to
individual checks) are only shown when `show_check_warnings = TRUE`.

## Usage

``` r
# S3 method for class 'hub_validations'
print(x, show_check_warnings = FALSE, ...)
```

## Arguments

- x:

  An object of class `hub_validations` or any of its subclasses.

- show_check_warnings:

  Logical. If `TRUE`, prints check-level warnings inline with their
  checks. Validation-level warnings are always printed. Default `FALSE`.

- ...:

  Unused argument present for class consistency

## Value

Returns `x` invisibly.

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")
v <- validate_submission(
  hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
)

# Default print
print(v)
#> 
#> ── hub-config ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── team1-goodmodel/2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
#> ✔ [file_location]: File directory name matches `model_id` metadata in file
#>   name.
#> ✔ [round_id_valid]: `round_id` is valid.
#> ✔ [file_format]: File is accepted hub format.
#> ✔ [file_n]: Number of accepted model output files per round met.
#> ✔ [metadata_exists]: Metadata file exists at path
#>   model-metadata/team1-goodmodel.yaml.
#> █ [submission_time]: EXEC ERROR: Error in C_force_tz(to_posixct(time), tz,
#>   roll_dst) : CCTZ: Unrecognized output timezone: "US/Eastern"

# Show check-level warnings (if any)
print(v, show_check_warnings = TRUE)
#> 
#> ── hub-config ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── team1-goodmodel/2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
#> ✔ [file_location]: File directory name matches `model_id` metadata in file
#>   name.
#> ✔ [round_id_valid]: `round_id` is valid.
#> ✔ [file_format]: File is accepted hub format.
#> ✔ [file_n]: Number of accepted model output files per round met.
#> ✔ [metadata_exists]: Metadata file exists at path
#>   model-metadata/team1-goodmodel.yaml.
#> █ [submission_time]: EXEC ERROR: Error in C_force_tz(to_posixct(time), tz,
#>   roll_dst) : CCTZ: Unrecognized output timezone: "US/Eastern"

# Example with validation-level warning
v_with_warning <- v
attr(v_with_warning, "warnings") <- list(
  capture_validation_warning(
    msg = "Example validation-level warning message.",
    where = "example"
  )
)
print(v_with_warning)
#> ┌─────────────────────────────────────────────┐
#> │ ⚠ Warnings                                  │
#> │ • Example validation-level warning message. │
#> └─────────────────────────────────────────────┘
#> 
#> 
#> ── hub-config ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── team1-goodmodel/2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
#> ✔ [file_location]: File directory name matches `model_id` metadata in file
#>   name.
#> ✔ [round_id_valid]: `round_id` is valid.
#> ✔ [file_format]: File is accepted hub format.
#> ✔ [file_n]: Number of accepted model output files per round met.
#> ✔ [metadata_exists]: Metadata file exists at path
#>   model-metadata/team1-goodmodel.yaml.
#> █ [submission_time]: EXEC ERROR: Error in C_force_tz(to_posixct(time), tz,
#>   roll_dst) : CCTZ: Unrecognized output timezone: "US/Eastern"
```
