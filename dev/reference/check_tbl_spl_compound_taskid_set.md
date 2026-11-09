# Check model output data tbl sample compound task id sets for each modeling task match or are coarser than the expected set defined in the config.

This check detects the compound task ID sets of samples, implied by the
`output_type_id` and task ID values, and checks them for compliance with
the `compound_taskid_set` defined for each round modeling task in the
`tasks.json` config. Samples in a modeling task may have different
compound task ID sets, as long as each matches or is coarser than the
configured set. See the Compound modeling tasks section.

## Usage

``` r
check_tbl_spl_compound_taskid_set(
  tbl_chr,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
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

If the check fails, the output of the check includes an `errors`
element, a list of items, one for each modeling task failing validation.
The structure depends on the reason the check failed.

If the check failed because task IDs the hub does not accept as compound
task IDs were identified as such (i.e. samples describe "finer" compound
modeling tasks) for a given model task, the `errors` object will be a
list with one element for each finer compound task ID set detected, with
the following structure:

- `config_comp_tids`: the `compound_taskid_set` the modeling task config
  expects.

- `invalid_tbl_comp_tids`: the names of invalid compound task IDs.

- `tbl_comp_tids`: the finer compound task ID set detected in the tbl.

- `output_type_ids`: The output type IDs of the samples with that
  compound task ID set.

The name of each element is the index identifying the config modeling
task the sample is associated with `mt_id`. See [hubverse documentation
on
samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
for more details.

## Compound modeling tasks

Samples are validated against the configured `compound_taskid_set` only.
Each combination of configured compound task ID values is one compound
modeling task, identified in check output by its `compound_idx`. A
sample that matches the configured set covers one compound modeling
task. A coarser sample covers several. The sample checks split a coarser
sample into one part per compound modeling task, and validate and count
each part as a sample of that compound modeling task. A finer sample
covers only part of a compound modeling task, so it fails.

For example, take a configured `compound_taskid_set` of `reference_date`
and `location`. Each compound modeling task is then one location for one
reference date, and a sample that matches the configured set is a
trajectory across horizons for one location.

- A sample with a compound task ID set of `reference_date` only is
  coarser. It is joint across locations as well as horizons. If it
  covers locations `A1` and `A2`, it is validated as one sample for `A1`
  and one for `A2`.

- A sample with a compound task ID set of `reference_date`, `location`
  and `horizon` is finer. It covers one horizon of a trajectory, and
  fails.

The other sample checks refer to this example.
