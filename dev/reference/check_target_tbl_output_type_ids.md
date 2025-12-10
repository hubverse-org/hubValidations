# Check that output type ID values in a target data file are valid and complete

This check is only performed when the target data file contains an
`output_type_id` column. It verifies that non-distributional output
types have all NA output type IDs, and that distributional output types
(`cdf`, `pmf`) include the complete output_type_id set defined in the
hub config.

## Usage

``` r
check_target_tbl_output_type_ids(
  target_tbl_chr,
  target_type = c("oracle-output", "time-series"),
  file_path,
  hub_path,
  config_target_data = NULL
)
```

## Arguments

- target_tbl_chr:

  A tibble/data.frame of the contents of the target data file being
  validated. All columns should be coerced to character.

- target_type:

  Type of target data to validate. One of `"time-series"` or
  `"oracle-output"`. Defaults to `"oracle-output"`.

- file_path:

  A character string representing the path to the target data file
  relative to the `target-data` directory.

- hub_path:

  Either a character string path to a local Modeling Hub directory or an
  object of class `<SubTreeFileSystem>` created using functions
  [`s3_bucket()`](https://arrow.apache.org/docs/r/reference/s3_bucket.html)
  or
  [`gs_bucket()`](https://arrow.apache.org/docs/r/reference/gs_bucket.html)
  by providing a string S3 or GCS bucket name or path to a Modeling Hub
  directory stored in the cloud. For more details consult the [Using
  cloud storage (S3,
  GCS)](https://arrow.apache.org/docs/r/articles/fs.html) in the `arrow`
  package. The hub must be fully configured with valid `admin.json` and
  `tasks.json` files within the `hub-config` directory.

- config_target_data:

  Target data configuration object from
  `read_config(hub_path, "target-data")`, or NULL (default) if config
  does not exist. When target-data.json exists, this should be provided
  to enable date column extraction for date relaxation. If NULL and
  date_col is not provided, date relaxation cannot be applied and a
  warning will be issued if allow_extra_dates is TRUE.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

When checking for completeness of distributional output types, data is
grouped by observation unit to verify each unit has the complete set of
output_type_id values.

**With `target-data.json` config:** Observable unit is determined from
the config's `observable_unit` specification.

**Without `target-data.json` config:** Observable unit is inferred from
task ID columns present in the data.

The `as_of` column is NOT included in the grouping. Oracle data is
designed to contain a single version per observable unit with a
one-to-one mapping to model output data.
