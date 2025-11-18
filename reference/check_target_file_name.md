# Check that a hive-partitioned target data file name can be correctly parsed.

Check that a hive-partitioned target data file name can be correctly
parsed.

## Usage

``` r
check_target_file_name(file_path)
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
