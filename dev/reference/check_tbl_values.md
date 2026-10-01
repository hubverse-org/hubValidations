# Check model output data tbl contains valid value combinations

Check model output data tbl contains valid value combinations

## Usage

``` r
check_tbl_values(
  tbl_chr,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = deprecated()
)
```

## Arguments

- tbl_chr:

  a tibble/data.frame of the contents of the file being validated.
  Column types must **all be character**.

- round_id:

  character string. The round identifier.

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

- derived_task_ids:

  **\[deprecated\]** Derived task ID columns are validated like any
  other task ID column, so the argument has no effect.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
