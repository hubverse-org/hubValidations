# Check that submitting team does not exceed maximum number of allowed models per team

Check that submitting team does not exceed maximum number of allowed
models per team

## Usage

``` r
opt_check_metadata_team_max_model_n(file_path, hub_path, n_max = 2L)
```

## Arguments

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-metadata directory.

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

- n_max:

  Integer. Number of maximum allowed models per team.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

Should be deployed as part of `validate_model_metadata` optional checks.
