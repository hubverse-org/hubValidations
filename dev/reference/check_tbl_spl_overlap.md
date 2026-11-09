# Check model output data tbl samples that share a compound modeling task cover the same compound modeling tasks

A sample coarser than the configured `compound_taskid_set` covers
several compound modeling tasks. This check fails samples that partly
overlap, that is, share some compound modeling tasks but not all. The
terms are explained in the Compound modeling tasks section of
[`check_tbl_spl_compound_taskid_set()`](https://hubverse-org.github.io/hubValidations/dev/reference/check_tbl_spl_compound_taskid_set.md).

## Usage

``` r
check_tbl_spl_overlap(
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

In the example there, with a configured `compound_taskid_set` of
`reference_date` and `location`, samples joint across locations `A1` and
`A2` can sit alongside samples for location `B` alone. A sample joint
across `A1` and `A2` alongside a sample joint across `A2` and `B` partly
overlaps, and fails.

[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_data.md)
skips this check when `allow_overlapping_samples` is `TRUE`. The other
sample checks then split each sample by location as usual. In the
example, the `A2` rows of the two samples count as two samples for `A2`,
while `A1` and `B` have one each. `min_samples_per_task` and
`max_samples_per_task` apply to these counts, and
[`check_tbl_spl_n()`](https://hubverse-org.github.io/hubValidations/dev/reference/check_tbl_spl_n.md)
fails a file in which locations have different numbers of samples.

If the check fails, the output of the check includes an `errors`
element, a list with one element for each modeling task failing
validation, named by the index of the modeling task in the config. Each
element has the following structure:

- `output_type_ids`: The output type IDs of the samples involved.

- `slices`: a tibble with one row for each sample and compound modeling
  task it covers, giving the sample's `output_type_id`, the
  `compound_idx` and the compound task ID values of the compound
  modeling task.

See [hubverse documentation on
samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
for more details.
