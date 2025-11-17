# Check that any round_id_col name provided or extracted from the hub config is valid.

Check that any round_id_col name provided or extracted from the hub
config is valid.

## Usage

``` r
check_valid_round_id_col(tbl, file_path, hub_path, round_id_col = NULL)
```

## Arguments

- tbl:

  a tibble/data.frame of the contents of the file being validated.

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

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

- round_id_col:

  Character string. The name of the column containing `round_id`s.
  Usually, the value of round property `round_id` in hub `tasks.json`
  config file. Defaults to `NULL` and determined from the config if
  applicable.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

If `round_id_from_variable: false` and no `round_id_col` name is
provided, check is skipped and a `<message/check_info>` condition class
object is returned. Returned object also inherits from subclass
`<hub_check>`.

## Details

This check only applies to files being submitted to rounds where
`round_id_from_variable: true` or where a `round_id_col` name is
explicitly provided. Skipped otherwise.
