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
#> ── simple ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
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
#> ✔ [file_read]: File could be read successfully.
#> ✔ [valid_round_id_col]: `round_id_col` name is valid.
#> ✔ [unique_round_id]: `round_id` column "origin_date" contains a single, unique
#>   round ID value.
#> ✔ [match_round_id]: All `round_id_col` "origin_date" values match submission
#>   `round_id` from file name.
#> ✔ [colnames]: Column names are consistent with expected round task IDs and std
#>   column names.
#> ✔ [col_types]: Column data types match hub schema.
#> ✔ [valid_vals]: `tbl` contains valid values/value combinations.
#> ℹ [derived_task_id_vals]: No derived task IDs to check. Skipping derived task
#>   ID value check.
#> ✔ [rows_unique]: All combinations of task ID
#>   column/`output_type`/`output_type_id` values are unique.
#> ✔ [req_vals]: Required task ID/output type/output type ID combinations all
#>   present.
#> ✔ [value_col_valid]: Values in column `value` all valid with respect to
#>   modeling task config.
#> ✔ [value_col_non_desc]: Quantile or cdf `value` values increase when ordered by
#>   `output_type_id`.
#> ℹ [value_col_sum1]: No pmf output types to check for sum of 1. Check skipped.
#> ✖ [submission_time]: Submission time must be within accepted submission window
#>   for round.  Current time "2026-01-13 15:04:23 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.

# Show check-level warnings (if any)
print(v, show_check_warnings = TRUE)
#> 
#> ── simple ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
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
#> ✔ [file_read]: File could be read successfully.
#> ✔ [valid_round_id_col]: `round_id_col` name is valid.
#> ✔ [unique_round_id]: `round_id` column "origin_date" contains a single, unique
#>   round ID value.
#> ✔ [match_round_id]: All `round_id_col` "origin_date" values match submission
#>   `round_id` from file name.
#> ✔ [colnames]: Column names are consistent with expected round task IDs and std
#>   column names.
#> ✔ [col_types]: Column data types match hub schema.
#> ✔ [valid_vals]: `tbl` contains valid values/value combinations.
#> ℹ [derived_task_id_vals]: No derived task IDs to check. Skipping derived task
#>   ID value check.
#> ✔ [rows_unique]: All combinations of task ID
#>   column/`output_type`/`output_type_id` values are unique.
#> ✔ [req_vals]: Required task ID/output type/output type ID combinations all
#>   present.
#> ✔ [value_col_valid]: Values in column `value` all valid with respect to
#>   modeling task config.
#> ✔ [value_col_non_desc]: Quantile or cdf `value` values increase when ordered by
#>   `output_type_id`.
#> ℹ [value_col_sum1]: No pmf output types to check for sum of 1. Check skipped.
#> ✖ [submission_time]: Submission time must be within accepted submission window
#>   for round.  Current time "2026-01-13 15:04:23 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.

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
#> ── simple ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
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
#> ✔ [file_read]: File could be read successfully.
#> ✔ [valid_round_id_col]: `round_id_col` name is valid.
#> ✔ [unique_round_id]: `round_id` column "origin_date" contains a single, unique
#>   round ID value.
#> ✔ [match_round_id]: All `round_id_col` "origin_date" values match submission
#>   `round_id` from file name.
#> ✔ [colnames]: Column names are consistent with expected round task IDs and std
#>   column names.
#> ✔ [col_types]: Column data types match hub schema.
#> ✔ [valid_vals]: `tbl` contains valid values/value combinations.
#> ℹ [derived_task_id_vals]: No derived task IDs to check. Skipping derived task
#>   ID value check.
#> ✔ [rows_unique]: All combinations of task ID
#>   column/`output_type`/`output_type_id` values are unique.
#> ✔ [req_vals]: Required task ID/output type/output type ID combinations all
#>   present.
#> ✔ [value_col_valid]: Values in column `value` all valid with respect to
#>   modeling task config.
#> ✔ [value_col_non_desc]: Quantile or cdf `value` values increase when ordered by
#>   `output_type_id`.
#> ℹ [value_col_sum1]: No pmf output types to check for sum of 1. Check skipped.
#> ✖ [submission_time]: Submission time must be within accepted submission window
#>   for round.  Current time "2026-01-13 15:04:23 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.
```
