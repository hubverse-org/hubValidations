# Check that targets in a time-series target data file are valid

Check is only performed when the target data type is `time-series`. When
the target task ID is not specified in the config (i.e. hub has single
target and `target_keys = NULL`), the validity of the target is only
checked through the config file. Otherwise, the values in the target
task ID column of `target_tbl` are checked. Note that valid
`time-series` targets must be step ahead and their target type must be
one of `"continuous"`, `"discrete"`, `"binary"` or `"compositional"`. If
the hub contains no valid time-series targets, no time-series target
data should be present and validation of such data will be skipped.

## Usage

``` r
check_target_tbl_ts_targets(
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

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
