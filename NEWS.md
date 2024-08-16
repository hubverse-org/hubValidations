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
* Enforce minimum dependence on latest `hubData` (0.1.0) & `hubAdmin` (0.1.0). This allows for successful validation of submissions to hubs with multiple model tasks, where a given model task might contain non relevant task IDs and both `required` and `optional` properties have been set to `null` in `tasks.json` (#75). See the [relevant section in `hubDocs` documentation](https://hubverse.io/en/latest/quickstart-hub-admin/tasks-config.html#required-and-optional-elements) for more details.
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
