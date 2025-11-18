# Validating submissions locally

``` r
library(hubValidations)
```

## Validating model output files with `validate_submission()`

While most hubs will have automated validation systems set up to check
contributions during submission, `hubValidations` also provides
functionality for validating files locally before submitting them.

For this, **submitting teams can use
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_submission.md)
to validate their model output files prior to submitting.**

The function takes a relative path, relative to the model output
directory, as argument `file_path`, performs a series of standard
validation checks and returns their results in the form of a
`hub_validations` S3 class object.

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")

validate_submission(hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
)
#> 
#> ── simple ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
#> 
#> 
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
#>   for round.  Current time "2025-11-18 15:53:33 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.
```

For more details on the structure of `<hub_validations>` objects,
including how to access more information on individual checks, see
[`vignette("articles/hub-validations-class")`](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.md).

### Validation early return

**Some checks which are critical to downstream checks will cause
validation to stop and return the results of the checks up to and
including the critical check that failed early.**

They generally return a `<error/check_error>` condition class object.
Any problems identified will need to be resolved and the function re-run
for validation to proceed further.

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")

validate_submission(hub_path,
  file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv"
)
#> 
#> ── simple ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> 
#> ── 2022-10-15-hub-baseline.csv ────
#> 
#> 
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-15-hub-baseline.csv.
#> ✔ [file_name]: File name "2022-10-15-hub-baseline.csv" is valid.
#> ✖ [file_location]: File directory name must match `model_id` metadata in file
#>   name.  File should be submitted to directory "hub-baseline" not
#>   "team1-goodmodel"
#> ✔ [round_id_valid]: `round_id` is valid.
#> ✔ [file_format]: File is accepted hub format.
#> ✔ [file_n]: Number of accepted model output files per round met.
#> ✔ [metadata_exists]: Metadata file exists at path
#>   model-metadata/hub-baseline.yml.
#> ✔ [file_read]: File could be read successfully.
#> ✔ [valid_round_id_col]: `round_id_col` name is valid.
#> ✔ [unique_round_id]: `round_id` column "origin_date" contains a single, unique
#>   round ID value.
#> ⓧ [match_round_id]: All `round_id_col` "origin_date" values must match
#>   submission `round_id` from file name.  `round_id` value 2022-10-08 does not
#>   match submission `round_id` "2022-10-15"
#> ✖ [submission_time]: Submission time must be within accepted submission window
#>   for round.  Current time "2025-11-18 15:53:34 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.
```

### Execution Errors

If an execution error occurs in any of the checks, an
`<error/check_exec_error>` is returned instead. For validation purposes,
this results in the same downstream effects as an `<error/check_error>`
object.

### Checking for errors with `check_for_errors()`

You can check whether your file will overall pass validation checks by
passing the `hub_validations` object to
[`check_for_errors()`](https://hubverse-org.github.io/hubValidations/reference/check_for_errors.md).

If validation fails, an error will be thrown and the failing checks will
be summarised.

``` r
validate_submission(hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
) %>%
  check_for_errors()
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
#> 
#> ✖ [submission_time]: Submission time must be within accepted submission window
#>   for round.  Current time "2025-11-18 15:53:35 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.
#> Error in `check_for_errors()`:
#> ! 
#> The validation checks produced some failures/errors reported above.
```

### Skipping the submission window check

If you are preparing your submission prior to the submission window
opening, you might want to skip the submission window check. You can so
by setting argument `skip_submit_window_check` to `TRUE`.

This results in the previous valid file (except for failing the
validation window check) now passing overall validation.

``` r
validate_submission(hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
  skip_submit_window_check = TRUE
) %>%
  check_for_errors()
#> ✔ All validation checks have been successful.
```

### Ignoring derived task IDs to improve validation performance

#### What are derived task IDs?

Derived task IDs are a class of task ID whose values depend on the
values of other task IDs. As such, the **validity of derived task ID
values is dependent on the values of the task IDs they are derived
from** and the validity of value combinations of derived and other task
IDs is much more restricted. A common example of a derived task ID is
`target_end_date` which is most often derived from the `reference_date`
or `origin_date` and `horizon` task ids.

#### How to ignore derived task IDs

**For configs using schema version v4.0.0 and above, derived task IDs
are configured via the hub config and do not need to be ignored
manually**

To check if the hub uses schema version v4.0.0 or above, you can use:

``` r
hubUtils::version_gte("v4.0.0", hub_path = "path/to/hub")
```

Argument **`derived_task_ids`** allows for the specification of **task
IDs that are derived from other task IDs**. Supplying the names of
derived task IDs to argument `derived_task_ids` will ignore them during
validation checks.

Depending on config complexity, this **can often lead to a significant
improvement in validation performance and in some circumstances is
necessary for correct validation**.

Note that, **if any task IDs with `required` values have dependent
derived task IDs, it is essential for `derived_task_ids` to be
specified**. If this is the case and derived task IDs are not specified,
the dependent nature of derived task ID values will result in **false
validation errors when validating required values**.

If you’re unsure if this is the case for your hub or which task IDs are
derived, please consult the hub documentation or contact the hub
administrators.

### `validate_submission` check details

| Name                           | Check                                                                                                                                                                            | Early return | Fail output   | Extra info                                                                                                                                                                                                                           |
|:-------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| valid_config                   | Hub config valid                                                                                                                                                                 | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| submission_time                | Current time within file submission window                                                                                                                                       | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| file_exists                    | File exists at `file_path` provided                                                                                                                                              | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| file_name                      | File name valid                                                                                                                                                                  | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| file_location                  | File located in correct team directory                                                                                                                                           | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| round_id_valid                 | File round ID is valid hub round IDs                                                                                                                                             | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| file_format                    | File format is accepted hub/round format                                                                                                                                         | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| file_n                         | Number of submission files per round per team does not exceed allowed number                                                                                                     | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| metadata_exists                | Model metadata file exists in expected location                                                                                                                                  | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| file_read                      | File can be read without errors                                                                                                                                                  | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| valid_round_id_col             | Round ID var from config exists in data column names. Skipped if `round_id_from_var` is FALSE in config.                                                                         | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| unique_round_id                | Round ID column contains a single unique round ID. Skipped if `round_id_from_var` is FALSE in config.                                                                            | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| match_round_id                 | Round ID from file contents matches round ID from file name. Skipped if `round_id_from_var` is FALSE in config.                                                                  | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| colnames                       | File column names match expected column names for round (i.e. task ID names + hub standard column names)                                                                         | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| col_types                      | File column types match expected column types from config. Mainly applicable to parquet & arrow files.                                                                           | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| valid_vals                     | Columns (excluding the `value` and any derived task ID columns) contain valid combinations of task ID / output type / output type ID values                                      | TRUE         | check_error   | error_tbl: table of invalid task ID/output type/output type ID value combinations                                                                                                                                                    |
| derived_task_id_vals           | Derived task ID columns contain valid values.                                                                                                                                    | FALSE        | check_failure | errors: named list of derived task ID values. Each element contains the invalid values for each derived task ID that failed the check.                                                                                               |
| rows_unique                    | Columns (excluding the `value` and any derived task ID columns) contain unique combinations of task ID / output type / output type ID values                                     | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| req_vals                       | Columns (excluding the `value` and any derived task ID columns) contain all required combinations of task ID / output type / output type ID values                               | FALSE        | check_failure | missing_df: table of missing task ID/output type/output type ID value combinations                                                                                                                                                   |
| value_col_valid                | Values in `value` column are coercible to data type configured for each output type                                                                                              | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| value_col_non_desc             | Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID /output type value combinations. Applies to `quantile` or `cdf` output types only | FALSE        | check_failure | error_tbl: table of rows affected                                                                                                                                                                                                    |
| value_col_sum1                 | Values in the `value` column of `pmf` output type data for each unique task ID combination sum to 1.                                                                             | FALSE        | check_failure | error_tbl: table of rows affected                                                                                                                                                                                                    |
| spl_compound_taskid_set        | Sample compound task id sets for each modeling task match or are coarser than the expected set defined in tasks.json config.                                                     | TRUE         | check_error   | errors: list containing item for each failing modeling task. Exact structure dependent on type of validation failure. See check function documentation for more details.                                                             |
| spl_compound_tid               | Samples contain single unique values for each compound task ID within individual samples (v3 and above schema only).                                                             | TRUE         | check_error   | errors: list containing item for each sample failing validation with breakdown of unique values for each compound task ID.                                                                                                           |
| spl_non_compound_tid           | Samples contain single unique combination of non-compound task ID values across all samples (v3 and above schema only).                                                          | TRUE         | check_error   | errors: list containing item for each modeling task with vectors of output type ids of samples failing validation and example table of most frequent non-compound task ID value combination across all samples in the modeling task. |
| spl_n                          | Number of samples for a given compound idx falls within accepted compound task range (v3 and above schema only).                                                                 | FALSE        | check_failure | errors: list containing item for each compound_idx failing validation with sample count, metadata on expected samples and example table of expected structure for samples belonging to the compound idx in question.                 |
| target_file_exists             | File exists at `file_path` provided.                                                                                                                                             | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_partition_file_name     | Hive-style partition file path segments are valid and can be parsed successfully. Skipped if target dataset not hive-partitioned.                                                | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_file_ext                | Target data file extension is valid.                                                                                                                                             | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_dataset_exists          | Target dataset can be successfully detected for a given target type.                                                                                                             | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_dataset_unique          | A single unique target dataset exists for a given target type.                                                                                                                   | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_dataset_file_ext_unique | All files of a given target type share a single unique file format.                                                                                                              | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_dataset_rows_unique     | Target dataset rows are all unique.                                                                                                                                              | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| target_file_read               | Target data file can be read successfully.                                                                                                                                       | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_tbl_colnames            | Target data file has the correct column names according to target type.                                                                                                          | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_tbl_coltypes            | Target data file has the correct column types according to target type.                                                                                                          | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_tbl_ts_targets          | Targets in a time-series target data file are valid. Only performed on `time-series` data files.                                                                                 | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_tbl_rows_unique         | Target data file rows are all unique.                                                                                                                                            | FALSE        | check_failure |                                                                                                                                                                                                                                      |
| target_tbl_values              | Task ID columns in a target data file have valid task ID values.                                                                                                                 | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_tbl_output_type_ids     | Output type ID values in a target data file are valid and complete. Only performed when the target data file contains an `output_type_id` column.                                | TRUE         | check_error   |                                                                                                                                                                                                                                      |
| target_tbl_oracle_value        | Oracle values in a target data file are valid. Only performed on `oracle output` data files.                                                                                     | FALSE        | check_failure |                                                                                                                                                                                                                                      |

Details of checks performed by
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_submission.md)

## Validating model metadata files with `validate_model_metadata()`

If you want to check a model metadata file before submitting, you can
similarly use function
[`validate_model_metadata()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_metadata.md).

The function takes model metadata file name as argument `file_path`,
performs a series of validation checks and returns their results in the
form of a `hub_validations` S3 class object.

``` r
validate_model_metadata(hub_path,
  file_path = "hub-baseline.yml"
)
#> 
#> ── model-metadata-schema.json ────
#> 
#> ✔ [metadata_schema_exists]: File exists at path
#>   hub-config/model-metadata-schema.json.
#> 
#> 
#> ── hub-baseline.yml ────
#> 
#> 
#> 
#> ✔ [metadata_file_exists]: File exists at path model-metadata/hub-baseline.yml.
#> ✔ [metadata_file_ext]: Metadata file extension is "yml" or "yaml".
#> ✔ [metadata_file_location]: Metadata file directory name matches
#>   "model-metadata".
#> ✔ [metadata_matches_schema]: Metadata file contents are consistent with schema
#>   specifications.
#> ✔ [metadata_file_name]: Metadata file name matches the `model_id` specified
#>   within the metadata file.

validate_model_metadata(hub_path,
  file_path = "team1-goodmodel.yaml"
)
#> 
#> ── model-metadata-schema.json ────
#> 
#> ✔ [metadata_schema_exists]: File exists at path
#>   hub-config/model-metadata-schema.json.
#> ── team1-goodmodel.yaml ────
#> 
#> ✔ [metadata_file_exists]: File exists at path
#>   model-metadata/team1-goodmodel.yaml.
#> ✔ [metadata_file_ext]: Metadata file extension is "yml" or "yaml".
#> ✔ [metadata_file_location]: Metadata file directory name matches
#>   "model-metadata".
#> ⓧ [metadata_matches_schema]: Metadata file contents must be consistent with
#>   schema specifications.  - must have required property 'model_details' . -
#>   must NOT have additional properties; saw unexpected property
#>   'models_details'. - must NOT have additional properties; saw unexpected
#>   property 'ensemble_of_hub_models"'. - /include_ensemble must be boolean .
```

For more details on the structure of `<hub_validations>` objects,
including how to access more information on individual checks, see
[`vignette("articles/hub-validations-class")`](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.md).

### `validate_model_metadata` check details

| Name                    | Check                                                                                                               | Early return | Fail output   | Extra info |
|:------------------------|:--------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-----------|
| metadata_schema_exists  | A model metadata schema file exists in `hub-config` directory.                                                      | TRUE         | check_error   |            |
| metadata_file_exists    | A file with name provided to argument `file_path` exists at the expected location (the `model-metadata` directory). | TRUE         | check_error   |            |
| metadata_file_ext       | The metadata file has correct extension (yaml or yml).                                                              | TRUE         | check_error   |            |
| metadata_file_location  | The metadata file has been saved to correct location.                                                               | TRUE         | check_failure |            |
| metadata_matches_schema | The contents of the metadata file match the hub’s model metadata schema                                             | TRUE         | check_error   |            |
| metadata_file_name      | The metadata filename matches the model ID specified in the contents of the file.                                   | TRUE         | check_error   |            |

Details of checks performed by
[`validate_model_metadata()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_metadata.md)

#### Custom checks

The standard checks discussed here are the checks deployed by default by
the `validate_submission` or `validate_model_metadata` functions. For
more information on deploying optional/custom functions or functions
that require configuration please check the article on [including custom
functions](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.md)
([`vignette("articles/deploying-custom-functions")`](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.md)).
