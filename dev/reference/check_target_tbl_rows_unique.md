# Check target data rows are all unique

Check that there are no duplicate rows in target data files being
validated.

## Usage

``` r
check_target_tbl_rows_unique(
  target_tbl,
  target_type = c("time-series", "oracle-output"),
  file_path,
  hub_path
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

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

If datasets are versioned, multiple observations are allowed in
`time-series` target data, so long as they have different `as_of`
values. The `as_of` column is therefore included when determining
duplicates. In `oracle-output` data, there should be only a single
observation, regardless of the `as_of` value so the column it is not be
included when determining duplicates.
