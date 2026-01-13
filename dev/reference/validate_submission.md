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
  depend on other task IDs) to ignore. Columns for such task ids will
  contain `NA`s. If `NULL`, defaults to extracting derived task IDs from
  hub `task.json`. See
  [`get_hub_derived_task_ids()`](https://hubverse-org.github.io/hubUtils/reference/get_hub_timezone.html)
  for more details.

## Value

An object of class `hub_validations`. Each named element contains a
`hub_check` class object reflecting the result of a given check.
Function will return early if a check returns an error.

For more details on the structure of `<hub_validations>` objects,
including how to access more information on individual checks, see
[article on `<hub_validations>` S3 class
objects](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).

## Details

Note that it is **necessary for `derived_task_ids` to be specified if
any task IDs with `required` values have dependent derived task IDs**.
If this is the case and derived task IDs are not specified, the
dependent nature of derived task ID values will result in **false
validation errors when validating required values**.

Details of checks performed by `validate_submission()`

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

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")
file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
validate_submission(hub_path, file_path)
#> 
#> ── simple ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
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
#> ✔ [file_read]: File could be read successfully.
#> ✔ [valid_round_id_col]: `round_id_col` name is valid.
#> ✔ [unique_round_id]: `round_id` column "origin_date" contains a single, unique
#>   round ID value.
#> ✔ [match_round_id]: All `round_id_col` "origin_date" values match submission
#>   `round_id` from file name.
#> ✔ [colnames]: Column names are consistent with expected round task IDs and std
#>   column names.
#> ✔ [col_types]: Column data types match hub schema.
#> ✔ [valid_vals]: `tbl` contains valid values/value combinations.
#> ℹ [derived_task_id_vals]: No derived task IDs to check. Skipping derived task
#>   ID value check.
#> ✔ [rows_unique]: All combinations of task ID
#>   column/`output_type`/`output_type_id` values are unique.
#> ✔ [req_vals]: Required task ID/output type/output type ID combinations all
#>   present.
#> ✔ [value_col_valid]: Values in column `value` all valid with respect to
#>   modeling task config.
#> ✔ [value_col_non_desc]: Quantile or cdf `value` values increase when ordered by
#>   `output_type_id`.
#> ℹ [value_col_sum1]: No pmf output types to check for sum of 1. Check skipped.
#> ✖ [submission_time]: Submission time must be within accepted submission window
#>   for round.  Current time "2026-01-13 15:43:25 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.
```
