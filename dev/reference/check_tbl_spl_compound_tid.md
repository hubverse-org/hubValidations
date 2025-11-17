# Check model output data tbl samples contain single unique values for each compound task ID within individual samples

Check model output data tbl samples contain single unique values for
each compound task ID within individual samples

## Usage

``` r
check_tbl_spl_compound_tid(
  tbl,
  round_id,
  file_path,
  hub_path,
  compound_taskid_set = NULL,
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

- compound_taskid_set:

  a list of `compound_taskid_set`s (characters vector of compound task
  IDs), one for each modeling task. Used to override the compound task
  ID set in the config file, for example, when validating coarser
  samples.

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

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

Output of the check includes an `errors` element, a list of items, one
for each sample failing validation, with the following structure:

- `mt_id`: Index identifying the config modeling task the sample is
  associated with.

- `output_type_id`: The output type ID of the sample that does not
  contain a single, unique value for each compound task ID.

- `values`: The unique values of each compound task ID. See [hubverse
  documentation on
  samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
  for more details.
