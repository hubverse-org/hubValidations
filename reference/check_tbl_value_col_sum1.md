# Check that `pmf` output type values of model output data sum to 1.

Checks that values in the `value` column of `pmf` output type data for
each unique task ID combination sum to 1. Check only performed if `tbl`
contains `pmf` output type data. If not, the check is skipped and a
`<message/check_info>` condition class object is returned.

## Usage

``` r
check_tbl_value_col_sum1(tbl, file_path)
```

## Arguments

- tbl:

  a tibble/data.frame of the contents of the file being validated.

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
