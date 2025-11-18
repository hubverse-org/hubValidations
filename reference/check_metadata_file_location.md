# Check that the metadata file is being submitted to the correct folder

Check that the metadata file is being submitted to the correct folder

## Usage

``` r
check_metadata_file_location(file_path)
```

## Arguments

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-metadata directory.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
