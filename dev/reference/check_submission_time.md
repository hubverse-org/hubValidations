# Checks submission is within the valid submission window for a given round.

Checks submission is within the valid submission window for a given
round.

## Usage

``` r
check_submission_time(
  hub_path,
  file_path,
  ref_date_from = c("file", "file_path")
)
```

## Arguments

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

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

- ref_date_from:

  whether to get the reference date around which relative submission
  windows will be determined from the file's `file_path` round ID or the
  `file` contents themselves. `file` requires that the file can be read.
  Only applicable when a round is configured to determine the submission
  windows relative to the value in a date column in model output files.
  Not applicable when explicit submission window start and end dates are
  provided in the hub's config.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
