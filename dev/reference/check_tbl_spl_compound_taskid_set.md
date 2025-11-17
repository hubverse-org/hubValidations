# Check model output data tbl sample compound task id sets for each modeling task match or are coarser than the expected set defined in the config.

This check detects the compound task ID sets of samples, implied by the
`output_type_id` and task ID values, and checks them for internal
consistency and compliance with the `compound_taskid_set` defined for
each round modeling task in the `tasks.json` config.

## Usage

``` r
check_tbl_spl_compound_taskid_set(
  tbl,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path)
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

If the check fails, the output of the check includes an `errors`
element, a list of items, one for each modeling task failing validation.
The structure depends on the reason the check failed.

If the check failed because more that a single unique
`compound_taskid_set` was found for a given model task, the `errors`
object will be a list with one element for each `compound_taskid_set`
detected and will have the following structure:

- `tbl_comp_tids`: a compound task id set detected in the the tbl.

- `output_type_ids`: The output type ID of the sample that does not
  contain a single, unique value for each compound task ID.

If the check failed because task IDs which is not allowed in the config,
were identified as compound task ID (i.e. samples describe "finer"
compound modeling tasks) for a given model task, the `errors` object
will be a list with the structure described above as well as the
additional following elements:

- `config_comp_tids`: the allowed `compound_taskid_set` defined in the
  modeling task config.

- `invalid_tbl_comp_tids`: the names of invalid compound task IDs.

The name of each element is the index identifying the config modeling
task the sample is associated with `mt_id`. See [hubverse documentation
on
samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
for more details.
