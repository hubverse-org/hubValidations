# Raise conditions stored in a `hub_validations` S3 object

This is meant to be used in CI workflows to raise conditions from
`hub_validations` objects but can also be useful locally to summarise
the results of checks contained in a `hub_validations` S3 object.

## Usage

``` r
check_for_errors(x, verbose = FALSE)
```

## Arguments

- x:

  A `hub_validations` object

- verbose:

  Logical. If `TRUE`, print the results of all checks prior to raising
  condition and summarising `hub_validations` S3 object check results.

## Value

An error if one of the elements of `x` is of class `check_failure`,
`check_error`, `check_exec_error` or `check_exec_warning`. `TRUE`
invisibly otherwise.
