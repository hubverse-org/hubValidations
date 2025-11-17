# Check that oracle values in an oracle output target data file are valid

This check is only performed when the target data file contains an
`output_type_id` column and `cdf` or `pmf` output types. It verifies
that distributional output type (`cdf` and `pmf`) oracle values meet the
following criteria:

- `oracle_value` values are either `0` or `1`.

- `pmf` oracle values sum to `1` for each observation unit.

- `cdf` oracle values are non-decreasing for each observation unit when
  sorted by the `output_type_id` set defined in the hub config.

## Usage

``` r
check_target_tbl_oracle_value(
  target_tbl,
  target_type = c("oracle-output", "time-series"),
  file_path,
  hub_path
)
```

## Arguments

- target_tbl:

  A tibble/data.frame of the contents of the target data file being
  validated.

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

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
