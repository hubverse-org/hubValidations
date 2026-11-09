# Validate a submitted model data file.

Checks both file level properties like file name, extension, location
etc as well as model output data, i.e. the contents of the file.

## Usage

``` r
validate_submission(
  hub_path,
  file_path,
  round_id_col = NULL,
  validations_cfg_path = NULL,
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date"),
  skip_submit_window_check = FALSE,
  skip_check_config = FALSE,
  submit_window_ref_date_from = c("file", "file_path"),
  derived_task_ids = NULL,
  allow_overlapping_samples = FALSE
)
```

## Arguments

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

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

- round_id_col:

  Character string. The name of the column containing `round_id`s.
  Usually, the value of round property `round_id` in hub `tasks.json`
  config file. Defaults to `NULL` and determined from the config if
  applicable.

- validations_cfg_path:

  Path to `validations.yml` file. If `NULL` defaults to
  `hub-config/validations.yml`.

- output_type_id_datatype:

  character string. One of `"from_config"`, `"auto"`, `"character"`,
  `"double"`, `"integer"`, `"logical"`, `"Date"`. Defaults to
  `"from_config"` which uses the setting in the
  `output_type_id_datatype` property in the `tasks.json` config file if
  available. If the property is not set in the config, the argument
  falls back to `"auto"` which determines the `output_type_id` data type
  automatically from the `tasks.json` config file as the simplest data
  type required to represent all output type ID values across all output
  types in the hub. When only point estimate output types (where
  `output_type_id`s are `NA`,) are being collected by a hub, the
  `output_type_id` column is assigned a `character` data type when
  auto-determined. Other data type values can be used to override
  automatic determination. Note that attempting to coerce
  `output_type_id` to a data type that is not valid for the data (e.g.
  trying to coerce`"character"` values to `"double"`) will likely result
  in an error or potentially unexpected behaviour so use with care.

- skip_submit_window_check:

  Logical. Whether to skip the submission window check.

- skip_check_config:

  Logical. Whether to skip the hub config validation check.

- submit_window_ref_date_from:

  whether to get the reference date around which relative submission
  windows will be determined from the file's `file_path` round ID or the
  `file` contents themselves. `file` requires that the file can be read.
  Only applicable when a round is configured to determine the submission
  windows relative to the value in a date column in model output files.
  Not applicable when explicit submission window start and end dates are
  provided in the hub's config.

- derived_task_ids:

  Character vector of derived task ID names (task IDs whose values
  depend on other task IDs). The required values and sample checks leave
  these columns out. If `NULL`, defaults to extracting derived task IDs
  from hub `task.json`. See
  [`get_hub_derived_task_ids()`](https://hubverse-org.github.io/hubUtils/reference/get_hub_timezone.html)
  for more details.

- allow_overlapping_samples:

  Logical. Whether samples may partly overlap, that is, share some
  compound modeling tasks but not all. If `TRUE`, the `spl_overlap`
  check is skipped. See
  [`check_tbl_spl_overlap()`](https://hubverse-org.github.io/hubValidations/dev/reference/check_tbl_spl_overlap.md)
  for details.

## Value

A `hub_validations_collection` object containing validation results
organized by file. The collection includes separate entries for hub
config validation (keyed by `"hub-config"`) and file-specific
validations (keyed by file path).

## Details

Note that it is **necessary for `derived_task_ids` to be specified if
any task IDs with `required` values have dependent derived task IDs**.
If this is the case and derived task IDs are not specified, the
dependent nature of derived task ID values will result in **false
validation errors when validating required values**.

Details of checks performed by `validate_submission()`

| Name | Check | Early return | Fail output | Extra info |
|:---|:---|:---|:---|:---|
| valid_config | Hub config valid | TRUE | check_error |  |
| submission_time | Current time within file submission window | FALSE | check_failure |  |
| file_exists | File exists at \`file_path\` provided | TRUE | check_error |  |
| file_name | File name valid | TRUE | check_error |  |
| file_location | File located in correct team directory | FALSE | check_failure |  |
| round_id_valid | File round ID is valid hub round IDs | TRUE | check_error |  |
| file_format | File format is accepted hub/round format | TRUE | check_error |  |
| file_n | Number of submission files per round per team does not exceed allowed number | FALSE | check_failure |  |
| metadata_exists | Model metadata file exists in expected location | FALSE | check_failure |  |
| file_read | File can be read without errors | TRUE | check_error |  |
| valid_round_id_col | Round ID var from config exists in data column names. Skipped if \`round_id_from_var\` is FALSE in config. | FALSE | check_failure |  |
| unique_round_id | Round ID column contains a single unique round ID. Skipped if \`round_id_from_var\` is FALSE in config. | TRUE | check_error |  |
| match_round_id | Round ID from file contents matches round ID from file name. Skipped if \`round_id_from_var\` is FALSE in config. | TRUE | check_error |  |
| colnames | File column names match expected column names for round (i.e. task ID names + hub standard column names) | TRUE | check_error |  |
| col_types | File column types match expected column types from config. Mainly applicable to parquet & arrow files. | FALSE | check_failure |  |
| valid_vals | Columns (excluding the \`value\` column) contain valid combinations of task ID / output type / output type ID values. Derived task ID values are not checked against the task IDs they are derived from. | TRUE | check_error | error_tbl: table of invalid task ID/output type/output type ID value combinations |
| rows_unique | Columns (excluding the \`value\` and any derived task ID columns) contain unique combinations of task ID / output type / output type ID values | FALSE | check_failure |  |
| req_vals | Columns (excluding the \`value\` and any derived task ID columns) contain all required combinations of task ID / output type / output type ID values | FALSE | check_failure | missing_df: table of missing task ID/output type/output type ID value combinations |
| value_col_valid | Values in \`value\` column are coercible to data type configured for each output type | FALSE | check_failure |  |
| value_col_non_desc | Values in \`value\` column are non-decreasing as output_type_ids increase for all unique task ID /output type value combinations. Applies to \`quantile\` or \`cdf\` output types only | FALSE | check_failure | error_tbl: table of rows affected |
| value_col_sum1 | Values in the \`value\` column of \`pmf\` output type data for each unique task ID combination sum to 1. | FALSE | check_failure | error_tbl: table of rows affected |
| spl_mt_unique | Individual sample output_type_ids do not span multiple model tasks. | TRUE | check_error | errors: list with mt_ids (model task indices the overlapping samples span) and output_type_ids (sample IDs appearing in multiple model tasks). |
| spl_compound_taskid_set | Sample compound task id sets for each modeling task match or are coarser than the expected set defined in tasks.json config. Samples in a modeling task may have different compound task id sets. | TRUE | check_error | errors: list containing item for each failing modeling task. Exact structure dependent on type of validation failure. See check function documentation for more details. |
| spl_overlap | Samples that share a combination of compound task ID values cover the same combinations. Skipped when allow_overlapping_samples is TRUE (v3 and above schema only). | TRUE | check_error | errors: list containing item for each failing modeling task with output type ids of the samples involved and a table of the compound task ID values each covers. |
| spl_non_compound_tid | Samples contain single unique combination of non-compound task ID values across all samples, within each compound task ID value combination they cover (v3 and above schema only). | TRUE | check_error | errors: list containing item for each modeling task with vectors of output type ids of samples failing validation, a table of the compound task ID values they fail for and example table of most frequent non-compound task ID value combination across all samples in the modeling task. |
| spl_n | Number of samples for a given compound idx falls within accepted compound task range. Samples coarser than the configured compound task id set count towards each compound idx they cover (v3 and above schema only). | FALSE | check_failure | errors: list containing item for each compound_idx failing validation with sample count, metadata on expected samples and example table of expected structure for samples belonging to the compound idx in question. |

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")
file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
validate_submission(hub_path, file_path)
#> 
#> ── hub-config ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── team1-goodmodel/2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
#> ✔ [file_location]: File directory name matches `model_id` metadata in file
#>   name.
#> ✔ [round_id_valid]: `round_id` is valid.
#> ✔ [file_format]: File is accepted hub format.
#> ✔ [file_n]: Number of accepted model output files per round met.
#> ✔ [metadata_exists]: Metadata file exists at path
#>   model-metadata/team1-goodmodel.yaml.
#> █ [submission_time]: EXEC ERROR: Error in C_force_tz(to_posixct(time), tz,
#>   roll_dst) : CCTZ: Unrecognized output timezone: "US/Eastern"
```
