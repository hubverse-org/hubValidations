# Check target data rows are all unique

Check that there are no duplicate rows in target data files being
validated.

## Usage

``` r
check_target_tbl_rows_unique(
  target_tbl,
  target_type = c("time-series", "oracle-output"),
  file_path,
  hub_path,
  config_target_data = NULL
)
```

## Arguments

- target_tbl:

  A tibble/data.frame of the contents of the target data file being
  validated.

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

- config_target_data:

  Optional. A `target-data.json` config object. If provided, validation
  uses deterministic schema from config. If `NULL` (default), validation
  uses inference from `tasks.json`.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

Row uniqueness is determined by checking for duplicate combinations of
key columns (excluding value columns).

**With `target-data.json` config:** Columns to check are determined from
the config's `observable_unit` specification. For `oracle-output` data
with output type IDs, the `output_type` and `output_type_id` columns are
also included in the uniqueness check.

**Without `target-data.json` config:** For `time-series` data, if
versioned, multiple observations are allowed so long as they have
different `as_of` values. The `as_of` column is therefore included when
determining duplicates. For `oracle-output` data, there should be only a
single observation, regardless of the `as_of` value, so the column is
not included when determining duplicates.
