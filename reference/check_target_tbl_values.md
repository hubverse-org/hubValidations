# Check that task ID columns in a target data file have valid task ID values

Check is only performed when the target data file contains columns that
map onto task IDs or output types defined in the hub configuration.

## Usage

``` r
check_target_tbl_values(
  target_tbl_chr,
  target_type = c("time-series", "oracle-output"),
  file_path,
  hub_path,
  date_col = NULL,
  allow_extra_dates = FALSE,
  config_target_data = NULL
)
```

## Arguments

- target_tbl_chr:

  A tibble/data.frame of the contents of the target data file being
  validated. All columns should be coerced to character.

- target_type:

  Type of target data to retrieve matching files. One of "time-series"
  or "oracle-output". Defaults to "time-series".

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

- date_col:

  Optional. Name of the date column (e.g., "target_end_date"). Only used
  when target-data.json config does not exist. When target-data.json
  exists, date column is extracted from config (this parameter is
  ignored). If cannot determine date column, date relaxation is skipped.

- allow_extra_dates:

  Logical. If TRUE and target_type is "time-series", allows date values
  not in tasks.json. Other task ID columns are still strictly validated.
  Ignored for oracle-output (always strict).

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
