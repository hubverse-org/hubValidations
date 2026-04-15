# Check that individual sample output_type_ids do not span multiple model tasks

Check that individual sample output_type_ids do not span multiple model
tasks

## Usage

``` r
check_tbl_spl_mt_unique(
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
  depend on other task IDs) to ignore during validation. Defaults to
  extracting derived task IDs from hub `task.json`. See
  [`get_hub_derived_task_ids()`](https://hubverse-org.github.io/hubUtils/reference/get_hub_timezone.html)
  for more details.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

Different model tasks can have different sample configurations
(`compound_taskid_set`, `min/max_samples_per_task`, etc.), so samples
should be entirely independent across model tasks. This check verifies
that no sample `output_type_id` appears in more than one model task.

Output of the check includes an `errors` element, a list with the
following structure:

- `mt_ids`: Integer vector of model task indices the overlapping samples
  span.

- `output_type_ids`: Character vector of sample `output_type_id`s that
  appear in multiple model tasks.
