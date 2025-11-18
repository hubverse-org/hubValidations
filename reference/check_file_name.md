# Check a model output file name can be correctly parsed.

Check a model output file name can be correctly parsed.

## Usage

``` r
check_file_name(file_path)
```

## Arguments

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
