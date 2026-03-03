# Print results of multi-file validation as a hierarchical bullet list

Prints a formatted summary of validation results from multiple files.
Each file's validations are printed under a header showing the file
path. Validation-level warnings (attached to the collection object) are
displayed prominently in a box at the top.

## Usage

``` r
# S3 method for class 'hub_validations_collection'
print(x, show_check_warnings = FALSE, ...)
```

## Arguments

- x:

  An object of class `hub_validations_collection` or its subclasses.

- show_check_warnings:

  Logical. If `TRUE`, prints check-level warnings inline with their
  checks. Validation-level warnings are always printed. Default `FALSE`.

- ...:

  Unused argument present for class consistency

## Value

Returns `x` invisibly.
