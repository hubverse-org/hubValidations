# Check derived task ID columns contain valid values

This check is used to validate that values in any derived task ID
columns matches accepted values for each derived task ID in the config.
Given the dependence of derived task IDs on the values of other values,
it ignores the combinations of derived task ID values with those of
other task IDs and focuses only on identifying values that do not match
the accepted values.

## Usage

``` r
check_tbl_derived_task_id_vals(
  tbl,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
)
```

## Arguments

- tbl:

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

  Character vector of derived task ID names (task IDs whose values
  depend on other task IDs) to ignore. Columns for such task ids will
  contain `NA`s. Defaults to extracting derived task IDs from
  `config_tasks`. See
  [`get_config_derived_task_ids()`](https://hubverse-org.github.io/hubValidations/dev/reference/get_config_derived_task_ids.md)
  for more details.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

If no `derived_task_ids` are specified, the check is skipped and a
`<message/check_info>` condition class object is retuned.

Returned object also inherits from subclass `<hub_check>`.
