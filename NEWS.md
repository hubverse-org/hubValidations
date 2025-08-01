# hubValidations (development version)

* Added utilities for working with hive-partitioned data file paths:
  - `extract_hive_partitions()` for extracting key value pairs from paths to hive-partitioned data files.
  - `is_hive_partitioned_path()` for checking if a path is hive-partitioned.
* Added `read_target_file()` function for reading in individual target data files.
* Added target data utilities:
  - `get_target_task_id()` for extracting the name of the task ID(s) containing targets from the target metadata of a hub's config.
* Added target data validation checks:
  - `check_target_file_name()`: that a hive-partitioned target data file name can be correctly parsed.
  - `check_target_dataset_unique()`: that a single unique target dataset exists for a given target type.
  - `check_target_dataset_file_ext_unique()`: that file(s) in a target dataset (e.g. `time-series` or `oracle-output`) share a single unique file extension.
  - `check_target_dataset_rows_unique()`: that each row in a target dataset is unique. Function designed to be used as part of overall target data integrity check.
  - `check_target_file_ext_valid()`: that the file extension of a single target data file is valid.
  - `check_target_file_read()`: that a single target data file can be read in without errors.
  - `check_target_tbl_colnames()`: that column names of a target data file match expected column names for the target type.
  - `check_target_tbl_coltypes()`: that column types of a target data file match expected column types for the target type.
  - `check_target_tbl_values()`: that values in a target data file match valid values/value combinations for model tasks specified n the `tasks.json` hub config file.
  - `check_target_tbl_ts_targets()`: Check that targets contained in a time-series target data file or implied through hub config are valid time-series targets.
  - `check_target_tbl_output_type_ids()`: Check that each observation (as defined by the observable unit) in an oracle-output target data file matches the expected `output_type_id`s.
  - `check_target_tbl_rows_unique()`: Check that each observation in a target data file is unique.
  - `check_target_tbl_oracle_value()`: Check that the `oracle_value` values in an oracle-output target data file for `cdf` and `pmf` output types conform to expectations. Specifically it verifies that oracle values are either 0 or 1, `pmf` oracle values sum to 1 for each observation unit and `cdf` oracle values are non-decreasing for each observation unit when sorted by the `output_type_id` set defined in the hub config.
* Improved performance of `check_tbl_values_required()`.


# hubValidations 0.11.0

* Introduced `path` as main argument to `submission_tmpl()` and deprecated arguments `hub_con` and `config_tasks` (#165 & #137). This way, all that is required by the user to create a submission template is the path to a hub directory or `tasks.json` config file. We also added functionality to enable sourcing config files from a
cloud hub or directly from GitHub which means users do not required a local copy of the hub to create a submission template.
* `submission_tmpl()` gains `path` as the main argument, which can take a path to a 
local hub or config file, an s3 connection, or a URL to a hub or tasks configuration file. This allows users to create submission templates without downloading a local copy of the entire hub. The arguments `hub_con` and `config_tasks` are deprecated and will be removed in future versions (#165 & #137).

# hubValidations 0.10.1

* `check_tbl_value_col_ascending()` will now use the order of the
  `output_type_id` values as defined in the schema. This ensures that the
  `output_type_id`s for `cdf` output types are always sorted in the correct
  order (#78).
* Shortened the `check_tbl_value_col_ascending()` check message to improve readability (#143).

# hubValidations 0.10.0

* Added `check_tbl_derived_task_id_vals()` check to `validate_model_data()`
  that ensures that values in derived task ID columns match expected values for
  the corresponding derived task IDs in the round as defined in `tasks.json`
  config (#110). Given the dependence of derived task IDs on the values of
  their source task ID values, the check ignores the combinations of derived
  task ID values with those of other task IDs and focuses only on identifying
  values that do not match corresponding accepted values.
* `submission_tmpl()` gains the `force_output_types` allowing users to force
  optional output types to be included in a submission template when
  `required_vals_only = TRUE`. In conjunction with the use of the
  `output_types` argument, this allows users to create submission templates
  which include optional output types they plan to submit.
* `check_tbl_values_required()` no longer reports false positives for v4 hubs,
  which fixes the bug reported in #177. Evaluation of whether all combinations
  of required values have been submitted through `check_tbl_values_required()`
  is now chunked by output type for v4 config and above. This reduces memory
  pressure and should speed up required value validation in hubs with complex
  task.json files.

# hubValidations 0.9.0

* Re-exported functions useful for modelers (#149):
  - `hubUtils::read_config()` and `hubUtils::read_config_file()` for reading in hub configuration files.
  - `hubData::create_hub_schema()` and `hubData::coerce_to_hub_schema()` for creating and coercing data to the hub schema.
* Validation of v4 hubs now fully supported (#155, #156, #159). This includes:
- support for the v4 specification of `output_type_ids`.
- use of the new `is_required` property to determine whether output types are required or not. 
- `derived_task_ids` are now extracted from the `tasks.json` config by default. 

See the [`schemas` repository `NEWS.md`](https://github.com/hubverse-org/schemas/blob/main/NEWS.md) for more details.

# hubValidations 0.8.0

* Custom checks no longer fail if validation is run outside of the root of the hub (#141)
* Downgrade result of missing model metadata file check from `check_error` to `check_failure` and suppress early return in case of check failure in `validate_model_file()` (#138).
* Add `check_file_n()` function to validate that the number of files submitted per round does not exceed the allowed number of submissions per team (#139).
* Ignore `NA`s in relevant `tbl` columns in `opt_check_tbl_col_timediff()` and `opt_check_tbl_horizon_timediff()` checks to ensure rows that may not be targeting relevant to modeling task do not cause false check failure. (#140).

# hubValidations 0.7.1

* Updated documentation for custom validations:
  - new vignette on how to create custom validation checks for hub validations (#121) 
  - new section on how to manage additional dependencies required by custom validation functions (#22).
* Bolstered parsing of file names in`parse_file_name()`:
  - ensure filenames are composed of letters, numbers, and underscores (#132).
  - added more fine-grained check error messages to identify portion of file name that errored.

# hubValidations 0.7.0

* Added function `create_custom_check()` for creating custom validation check function files from templates (#121).
* Fixed bug in `check_tbl_values_required()` causing required missing values to not be identified correctly when all output types were optional (#123)

# hubValidations 0.6.2

* Fixed bug in `check_tbl_col_types()` where columns in model output data with more than one class were causing an EXEC error (#118). Thanks for the bug report @ruarai!

# hubValidations 0.6.1

* Changed file name header colour in `hub_validations` object `print()` method to make more visible on lighter backgrounds.
* Soft deprecated `file_modification_check` argument `"warn"` option and replaced it with `"failure"` in `validate_pr()` function. 

# hubValidations 0.6.0

* To make clearer that all checks resulting in `check_failure` are required to pass for files to be considered valid, `check_failure` class objects are elevated to errors (#111). Also, to make it easier for users to identify errors from visually scanning the printed output, the following custom bullets have been assigned.
  - `✖` : `check_failure` class object.  This indicates an error that does not impact the validation process. 
  - `ⓧ` : `check_error` class object. This also indicates early termination of the validation process.
  - `☒` : `check_exec_error` class object. This indicates an error in the execution of a check function.
* `hub_validations` class object `combine()` method now ensures that check names are made unique across all `hub_validations` objects being combined.
* Additional improvements to `hub_validations` class object `print()` method. 
  - Check results for each file validated are now split and printed under file name header. 
  - The check name that can be used to access the check result from the `hub_validations` object is now included as the prefix to the check result message instead of the file name (#76).
* `octolog` dependency removed. This removes the annotation of validation results onto GitHub Action workflow logs (#113).

# hubValidations 0.5.1

* Remove dependency on development version of `arrow` package and bump required version to 17.0.0.


# hubValidations 0.5.0

This release introduces **significant improvements in the performance of submission validation** via the following changes:

* Add ability to sub-set expanded valid value grids by output type through `output_type` argument in `expand_model_out_grid()` (#98).
* Add ability to ignore the values of derived task IDs in expanded valid value grids through argument `derived_task_ids` in `expand_model_out_grid()`. 
* Use sub-setting and batching of model output data validation by output type in appropriate lower level checks and add ability to ignore derived task IDs in `validate_model_data()`, `validate_submission()` and `validate_pr()`. 

Both of these changes **allow for the creation of smaller, more focused expanded valid value grids, significantly reducing pressure on memory** when working with large, complex hub configs and making submission validation much more efficient.

Additional useful functionality:

* Add ability to subset by output type and ignore derived task IDs to `submission_tmpl()`. Ignoring derived task ids can be particularly useful to avoid creating templates with invalid derived task ID value combinations.
* Add new exported function `match_tbl_to_model_task()` that matches the rows in a `tbl` of model output data to a model task of a given round (as defined in `tasks.json`).

# hubValidations 0.4.0

- Add new `check_tbl_spl_compound_taskid_set()` check function to `validate_model_data()` that ensures that sample compound task id sets for each modeling task match or are coarser than the expected set defined in `tasks.json` config.
- Add new `get_tbl_compound_taskid_set()` for detecting sample compound task ID set from submission data.
- Add argument `compound_taskid_set` to `expand_model_out_grid()` and `submission_tmpl()` that allows users to override the compound task ID set when creating sample indices in the `output_type_id` column of samples.

# hubValidations 0.3.0

* Introduce an `output_type_id_datatype` argument to `validate_pr()`, `validate_submission()`, `validate_model_data()` and `expand_model_out_grid()` and set default value to `"from_config"`. This default means the data type specified in the `output_type_id_datatype` property in `tasks.json` (introduced in schema version `v3.0.1`) is used to cast the hub level `output_type_id` column data type. If not set in the config, the functions fall back to `"auto"` which detects the simplest data type that can represent all output type id values across all output types and rounds. The argument also allows hub administrators to override this setting manually during validation.


# hubValidations 0.2.0

* Move and rename the following `hubData` functions to `hubValidations`:
 - `hubData::expand_model_out_val_grid` to `expand_model_out_grid`.
 - `hubData::create_model_out_submit_tmpl` to `submission_tmpl`.

# hubValidations 0.1.0

* Support validation of v3 schema sample submissions.

# hubValidations 0.0.1

* Release stable 0.0.1 version
* Enforce minimum dependence on latest `hubData` (0.1.0) & `hubAdmin` (0.1.0). This allows for successful validation of submissions to hubs with multiple model tasks, where a given model task might contain non relevant task IDs and both `required` and `optional` properties have been set to `null` in `tasks.json` (#75). See the [relevant section in `hubDocs` documentation](https://docs.hubverse.io/en/latest/quickstart-hub-admin/tasks-config.html#required-and-optional-elements) for more details.
* Improve formatting of current time print in `validate_submission_time()` message by removing decimal seconds and including local time zone.


# hubValidations 0.0.0.9008

* Added new articles on:
    - The structure of `<hub_validations>` class objects.
    - Validating Pull Requests on Github (for admins).
    - Validating Submissions locally (for teams).
* Added tables with details of individual checks performed by each high level `validate_*()` function to documentation.
* Fixed bug where check that values in `value` column are non-decreasing as `output_type_id`s increase for all unique task ID /output type value combinations for `cdf` and `quantile` output types was erroneously returning validation errors if the `output_type_id` column was not ordered. (Thanks @M-7th).

# hubValidations 0.0.0.9007

* `validate_pr()` now has arguments for controlling modification/deletions check are performed on model output and model metadata files (#65).
  - `file_modification_check`, which controls whether modification/deletion checks are performed and what is returned if modifications/deletions detected.
  - `allow_submit_window_mods`, which controls whether modifications/deletions of model output files are allowed within their submission windows.


# hubValidations 0.0.0.9006

* `validate_pr()` now checks for deletions of previously submitted model metadata files and modifications or deletions of previously submitted model output files, adding an `<error/check_error>` class object to the function output for each detected modified/deleted file (#43 & #44).

# hubValidations 0.0.0.9005

* Improved handling of numeric output type IDs (including high precision floating points / values with trailing zeros), especially when overall hub output type ID column is character. This previously lead to a number of bugs and false validation failures (#58 & #54) which are addressed in this version.
* Bug fixes with respect to handling modelling tasks with no required task ID / output type combinations.
* Improved capture of error messages when check execution error occurs.

# hubValidations 0.0.0.9004

This release contains a bug fix for reading in and validating CSV column types correctly. (#54) 

# hubValidations 0.0.0.9003

This release includes a number of bug fixes:
- Deployment of custom/optional functions via `validations.yml` can now be accessed directly form `pkg` namespace, addressing bug which required `pkg` library to be loaded. (#51)
- Use `all.equal` to check that sums of `pmf` probabilities equal 1. (#52)

# hubValidations 0.0.0.9002

This release includes improvements designed after the first round of sandbox testing on setting up the CDC FluSight hub. Improvements include:

* Export `parse_file_name` function for parsing model output metadata from a model output file name.
* Issue more specific and informative messaging when `check_tbl_values()` check fails.
* Adding a `verbose` option to `check_for_errors()` function which prints the results of all checks in addition to the deafult overall result and subset of failed checks.

# hubValidations 0.0.0.9001

* Release of first draft `hubValidations` package

# hubValidations 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.
