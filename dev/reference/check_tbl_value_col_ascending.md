# Check that `quantile` and `cdf` output type values of model output data are non-descending

Checks that values in the `value` column for `quantile` and `cdf` output
type data for each unique task ID/output type combination are
non-descending when arranged by increasing `output_type_id` order. Check
only performed if `tbl` contains `quantile` or `cdf` output type data.
If not, the check is skipped and a `<message/check_info>` condition
class object is returned.

## Usage

``` r
check_tbl_value_col_ascending(
  tbl,
  file_path,
  hub_path,
  round_id,
  derived_task_ids = get_hub_derived_task_ids(hub_path)
)
```

## Arguments

- tbl:

  a tibble/data.frame of the contents of the file being validated.
  Column types must **all be character**.

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

- round_id:

  character string. The round identifier.

- derived_task_ids:

  Character vector of derived task ID names (task IDs whose values
  depend on other task IDs) to ignore. Columns for such task ids will
  contain `NA`s. Defaults to extracting derived task IDs from hub
  `task.json`. See
  [`get_hub_derived_task_ids()`](https://hubverse-org.github.io/hubUtils/reference/get_hub_timezone.html)
  for more details.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.
