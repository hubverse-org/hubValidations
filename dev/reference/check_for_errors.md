# Raise conditions stored in validation objects

Checks validation objects for errors and raises conditions if any are
found. Works with `hub_validations` and `hub_validations_collection`
objects, as well as their subclasses (`target_validations` and
`target_validations_collection`). Can be used in CI workflows to signal
validation failures, or locally to summarise validation results.

## Usage

``` r
check_for_errors(x, verbose = FALSE, show_warnings = FALSE)
```

## Arguments

- x:

  A `hub_validations` or `hub_validations_collection` object (including
  subclasses `target_validations` and `target_validations_collection`).

- verbose:

  Logical. If `TRUE`, print the results of all checks prior to raising
  condition and summarising validation object check results.

- show_warnings:

  Logical. If `TRUE`, print check-level warnings inline with their
  checks. Validation-level warnings are always printed. Default `FALSE`.

## Value

An error if one of the elements of `x` is of class `check_failure`,
`check_error`, `check_exec_error` or `check_exec_warning`. `TRUE`
invisibly otherwise.

## Details

For more details on these classes, see [article on `<hub_validations>`
S3 class
objects](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).

## See also

[`validate_submission()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_submission.md),
[`validate_pr()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_pr.md),
[`validate_target_submission()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_target_submission.md),
[`validate_target_pr()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_target_pr.md)
