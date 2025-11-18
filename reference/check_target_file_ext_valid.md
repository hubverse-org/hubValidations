# Check that a target data file has a valid extension.

Note that files which are part of a hive partitioned dataset must have
parquet file extension only.

## Usage

``` r
check_target_file_ext_valid(file_path)
```

## Arguments

- file_path:

  A character string representing the path to the target data file
  relative to the `target-data` directory.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
