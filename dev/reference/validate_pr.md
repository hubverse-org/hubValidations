# Validate Pull Request

Validates model output and model metadata files in a Pull Request.

## Usage

``` r
validate_pr(
  hub_path = ".",
  gh_repo,
  pr_number,
  round_id_col = NULL,
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date"),
  validations_cfg_path = NULL,
  skip_submit_window_check = FALSE,
  file_modification_check = c("error", "failure", "warn", "message", "none"),
  allow_submit_window_mods = TRUE,
  submit_window_ref_date_from = c("file", "file_path"),
  derived_task_ids = NULL
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

- gh_repo:

  GitHub repository address in the format `username/repo`

- pr_number:

  Number of the pull request to validate

- round_id_col:

  Character string. The name of the column containing `round_id`s. Only
  required if files contain a column that contains `round_id` details
  but has not been configured via `round_id_from_variable: true` and
  `round_id:` in in hub `tasks.json` config file.

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

- validations_cfg_path:

  Path to `validations.yml` file. If `NULL` defaults to
  `hub-config/validations.yml`.

- skip_submit_window_check:

  Logical. Whether to skip the submission window check.

- file_modification_check:

  Character string. Whether to perform check and what to return when
  modification/deletion of a previously submitted model output file or
  deletion of a previously submitted model metadata file is detected in
  PR:

  - `"error"`: Appends a `<error/check_error>` condition class object
    for each applicable modified/deleted file.

  - `"warning"`: Appends a `<error/check_failure>` condition class
    object for each applicable modified/deleted file.

  - `"message"`: Appends a `<message/check_info>` condition class object
    for each applicable modified/deleted file.

  - `"none"`: No modification/deletion checks performed.

- allow_submit_window_mods:

  Logical. Whether to allow modifications/deletions of model output
  files within their submission windows. Defaults to `TRUE`.

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
  depend on other task IDs) to ignore. Columns for such task ids will
  contain `NA`s. If `NULL`, defaults to extracting derived task IDs from
  hub `task.json`. See
  [`get_hub_derived_task_ids()`](https://hubverse-org.github.io/hubUtils/reference/get_hub_timezone.html)
  for more details.

## Value

An object of class `hub_validations`.

## Details

Only model output and model metadata files are individually validated
using
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_submission.md)
or
[`validate_model_metadata()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_metadata.md)
respectively although as part of checks, hub config files are also
validated. Any other files included in the PR are ignored but flagged in
a message.

By default, modifications (which include renaming) and deletions of
previously submitted model output files and deletions or renaming of
previously submitted model metadata files are not allowed and return a
`<error/check_error>` condition class object for each applicable
modified/deleted file. This behaviour can be modified through arguments
`file_modification_check`, which controls whether modification/deletion
checks are performed and what is returned if modifications/deletions are
detected, and `allow_submit_window_mods`, which controls whether
modifications/deletions of model output files are allowed within their
submission windows.

Note that to establish **relative** submission windows when performing
modification/deletion checks and `allow_submit_window_mods` is `TRUE`,
the reference date is taken as the `round_id` extracted from the file
path (i.e. `submit_window_ref_date_from` is always set to
`"file_path"`). This is because we cannot extract dates from columns of
deleted files. If hub submission window reference dates do not match
round IDs in file paths, currently `allow_submit_window_mods` will not
work correctly and is best set to `FALSE`. This only relates to
hubs/rounds where submission windows are determined relative to a
reference date and not when explicit submission window start and end
dates are provided in the config.

Finally, note that it is **necessary for `derived_task_ids` to be
specified if any task IDs with `required` values have dependent derived
task IDs**. If this is the case and derived task IDs are not specified,
the dependent nature of derived task ID values will result in **false
validation errors when validating required values**.

### Checks on model output files

Details of checks performed by
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_submission.md)

| Name                    | Check                                                                                                                                                                                  | Early return | Fail output   | Extra info                                                                                                                                                                                                                           |
|:------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| valid_config            | Hub config valid                                                                                                                                                                       | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| submission_time         | Current time within file submission window                                                                                                                                             | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| file_exists             | File exists at \`file_path\` provided                                                                                                                                                  | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| file_name               | File name valid                                                                                                                                                                        | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| file_location           | File located in correct team directory                                                                                                                                                 | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| round_id_valid          | File round ID is valid hub round IDs                                                                                                                                                   | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| file_format             | File format is accepted hub/round format                                                                                                                                               | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| file_n                  | Number of submission files per round per team does not exceed allowed number                                                                                                           | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| metadata_exists         | Model metadata file exists in expected location                                                                                                                                        | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| file_read               | File can be read without errors                                                                                                                                                        | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| valid_round_id_col      | Round ID var from config exists in data column names. Skipped if \`round_id_from_var\` is FALSE in config.                                                                             | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| unique_round_id         | Round ID column contains a single unique round ID. Skipped if \`round_id_from_var\` is FALSE in config.                                                                                | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| match_round_id          | Round ID from file contents matches round ID from file name. Skipped if \`round_id_from_var\` is FALSE in config.                                                                      | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| colnames                | File column names match expected column names for round (i.e. task ID names + hub standard column names)                                                                               | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| col_types               | File column types match expected column types from config. Mainly applicable to parquet & arrow files.                                                                                 | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| valid_vals              | Columns (excluding the \`value\` and any derived task ID columns) contain valid combinations of task ID / output type / output type ID values                                          | TRUE         | check_error   | error_tbl: table of invalid task ID/output type/output type ID value combinations                                                                                                                                                    |
| derived_task_id_vals    | Derived task ID columns contain valid values.                                                                                                                                          | FALSE        | check_failure | errors: named list of derived task ID values. Each element contains the invalid values for each derived task ID that failed the check.                                                                                               |
| rows_unique             | Columns (excluding the \`value\` and any derived task ID columns) contain unique combinations of task ID / output type / output type ID values                                         | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| req_vals                | Columns (excluding the \`value\` and any derived task ID columns) contain all required combinations of task ID / output type / output type ID values                                   | FALSE        | check_failure | missing_df: table of missing task ID/output type/output type ID value combinations                                                                                                                                                   |
| value_col_valid         | Values in \`value\` column are coercible to data type configured for each output type                                                                                                  | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| value_col_non_desc      | Values in \`value\` column are non-decreasing as output_type_ids increase for all unique task ID /output type value combinations. Applies to \`quantile\` or \`cdf\` output types only | FALSE        | check_failure | error_tbl: table of rows affected                                                                                                                                                                                                    |
| value_col_sum1          | Values in the \`value\` column of \`pmf\` output type data for each unique task ID combination sum to 1.                                                                               | FALSE        | check_failure | error_tbl: table of rows affected                                                                                                                                                                                                    |
| spl_compound_taskid_set | Sample compound task id sets for each modeling task match or are coarser than the expected set defined in tasks.json config.                                                           | TRUE         | check_error   | errors: list containing item for each failing modeling task. Exact structure dependent on type of validation failure. See check function documentation for more details.                                                             |
| spl_compound_tid        | Samples contain single unique values for each compound task ID within individual samples (v3 and above schema only).                                                                   | TRUE         | check_error   | errors: list containing item for each sample failing validation with breakdown of unique values for each compound task ID.                                                                                                           |
| spl_non_compound_tid    | Samples contain single unique combination of non-compound task ID values across all samples (v3 and above schema only).                                                                | TRUE         | check_error   | errors: list containing item for each modeling task with vectors of output type ids of samples failing validation and example table of most frequent non-compound task ID value combination across all samples in the modeling task. |
| spl_n                   | Number of samples for a given compound idx falls within accepted compound task range (v3 and above schema only).                                                                       | FALSE        | check_failure | errors: list containing item for each compound_idx failing validation with sample count, metadata on expected samples and example table of expected structure for samples belonging to the compound idx in question.                 |

### Checks on model metadata files

Details of checks performed by
[`validate_model_metadata()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_metadata.md)

| Name                    | Check                                                                                                                   | Early return | Fail output   | Extra info | optional |
|:------------------------|:------------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-----------|:---------|
| metadata_schema_exists  | A model metadata schema file exists in \`hub-config\` directory.                                                        | TRUE         | check_error   |            | FALSE    |
| metadata_file_exists    | A file with name provided to argument \`file_path\` exists at the expected location (the \`model-metadata\` directory). | TRUE         | check_error   |            | FALSE    |
| metadata_file_ext       | The metadata file has correct extension (yaml or yml).                                                                  | TRUE         | check_error   |            | FALSE    |
| metadata_file_location  | The metadata file has been saved to correct location.                                                                   | TRUE         | check_failure |            | FALSE    |
| metadata_matches_schema | The contents of the metadata file match the hub's model metadata schema                                                 | TRUE         | check_error   |            | FALSE    |
| metadata_file_name      | The metadata filename matches the model ID specified in the contents of the file.                                       | TRUE         | check_error   |            | FALSE    |
| NA                      | The number of metadata files submitted by a single team does not exceed the maximum number allowed.                     | FALSE        | check_failure |            | TRUE     |

## Examples

``` r
if (FALSE) { # \dontrun{
validate_pr(
  hub_path = ".",
  gh_repo = "hubverse-org/ci-testhub-simple",
  pr_number = 3
)
} # }
```
