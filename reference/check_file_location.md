# Check file is being submitted to the correct folder

Checks that the `model_id` metadata in the file name matches the
directory name the file is being submitted to.

## Usage

``` r
check_file_location(file_path)
```

## Arguments

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
