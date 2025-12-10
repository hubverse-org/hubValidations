# Structure of hub_validations class objects

``` r
library(hubValidations)
```

The high level `validate_*()` family of functions all return a
`<hub_validations>` S3 class object.

## Structure of `<hub_validations>` object

A `hub_validations` object is effectively a list and represents the
collected output of the series of checks performed by a higher level
`validate_*()` function.

Each named element of the list contains the result of an individual
check and inherits from subclass `<hub_check>`. The name of each element
is the name of the check.

Let’s examine an example output of a model output file validation using
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_submission.md).

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")

v <- validate_submission(hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
)

str(v, max.level = 1)
#> Classes 'hub_validations', 'list'  hidden list of 22
#>  $ valid_config        :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_exists         :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_name           :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_location       :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ round_id_valid      :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_format         :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_n              :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ metadata_exists     :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_read           :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ valid_round_id_col  :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ unique_round_id     :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ match_round_id      :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ colnames            :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ col_types           :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ valid_vals          :List of 5
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ derived_task_id_vals:List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
#>  $ rows_unique         :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ req_vals            :List of 5
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ value_col_valid     :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ value_col_non_desc  :List of 5
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ value_col_sum1      :List of 4
#>   ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
#>  $ submission_time     :List of 6
#>   ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
```

The super class returned in each element depends on the status of the
check:

- If a check succeeds, a `<message/check_success>` condition class
  object is returned.

- If a check is skipped, a `<message/check_info>` condition class object
  is returned.

- Checks vary with respect to whether they return an
  `<error/check_failure>` or `<error/check_error>` condition class
  object if the check fails.

  - **`<error/check_failure>`** class objects indicate a check that
    failed but does not affect downstream checks so validation was able
    to proceed.
  - **`<error/check_error>`** class objects indicate early termination
    of the validation process because of failure of a check downstream
    checks depend on.

Ultimately, both will cause overall validation to fail. The
`<error/check_error>` class exists to alert you to the fact that *there
may be more errors not yet reported* due to early termination of the
check process.

## `hub_validations` print method

`hub_validations` objects have their own print method which displays the
result, the check name and message of each check:

- `✔` indicates a check was successful (a `<message/check_success>`
  condition class object was returned)
- `✖` indicates a check failed but, because it does not affect
  downstream checks, validation was able to proceed (a
  `<error/check_failure>` condition class object was returned)
- `ⓧ` indicates a check that downstream checks depend on failed, causing
  early return of the validation process (a `<error/check_error>`
  condition class object was returned)
- `☒` indicates an execution error occured and the check was not able to
  complete (a `<error/check_exec_error>` condition class object was
  returned). Will cause early return if expected check failure output
  was a `<error/check_error>`.
- `ℹ` indicates a check was skipped (a `<message/check_info>` condition
  class object was returned)

``` r
v
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
#>   for round.  Current time "2025-12-10 19:03:32 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.
```

Note that the submission window check is always performed and reported
last.

## Structure of a `<hub_check>` object

Let’s look more closely at the structure of the first few elements of
the `hub_validations` object retuned by
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_submission.md)

``` r
v <- validate_submission(hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
)

str(utils::head(v))
#> List of 6
#>  $ valid_config  :List of 4
#>   ..$ message       : chr "All hub config files are valid. \n "
#>   ..$ where         : chr "simple"
#>   ..$ call          : chr "check_config_hub_valid"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_exists   :List of 4
#>   ..$ message       : chr "File exists at path \033[34mmodel-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv\033[39m. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_file_exists"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_name     :List of 4
#>   ..$ message       : chr "File name \033[34m\"2022-10-08-team1-goodmodel.csv\"\033[39m is valid. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_file_name"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_location :List of 4
#>   ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_file_location"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ round_id_valid:List of 4
#>   ..$ message       : chr "`round_id` is valid. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_valid_round_id"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ file_format   :List of 4
#>   ..$ message       : chr "File is accepted hub format. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_file_format"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
```

Each `<hub_check>` objects contains the following elements:

- `message`: the result message containing details about the check.
- `where:`: there the check was performed, usually the model output file
  name.
- `call`: the function used to perform the check.
- `use_cli_format`: whether the message is formatted using cli format,
  almost always TRUE.

## Extra information

Some `<hub_check>` objects contain extra information about the failing
check to help identify affected rows in submissions.

For example, the `<hub_check>` object returned for the `valid_vals`
check, which checks that all columns in a model output file (excluding
the `value` column) contain valid combinations of task ID / output type
/ output type ID values contains an additional element called
`error_tbl`, with details of the invalid value combinations in the rows
affected.

To access `error_tbl` from the output of
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_submission.md)
stored in an object `v`, you would use:

``` r
v$valid_vals$error_tbl
```
