# Structure of hub_validations class objects

``` r
library(hubValidations)
```

The `validate_*()` family of functions return validation results as S3
class objects. Functions that validate multiple items (e.g.,
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_submission.md),
[`validate_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_pr.md))
return a `<hub_validations_collection>`, while lower-level functions
return a `<hub_validations>` object.

## Structure of `<hub_validations>` object

A `hub_validations` object represents validation results for a single
validation subject. Depending on context, this could be a file, a
configuration directory (`hub-config`), or a target dataset type
(`time-series`, `oracle-output`).

It is a named list where each element contains the result of an
individual check and inherits from subclass `<hub_check>`. The name of
each element is the name of the check. The object also has a `where`
attribute identifying what was validated.

Let’s examine an example using
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_data.md),
which validates a single model output file’s data:

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")

v <- validate_model_data(hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
)

# The where attribute
attr(v, "where")
#> [1] "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

# Structure of the hub_validations object
str(v, max.level = 1)
#> List of 13
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
#>  - attr(*, "class")= chr [1:2] "hub_validations" "list"
#>  - attr(*, "where")= chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
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
- `!` indicates an execution warning occurred during a check (a
  `<warning/check_exec_warn>` condition class object was returned)
- `█` indicates an execution error occurred and the check was not able
  to complete (a `<error/check_exec_error>` condition class object was
  returned). Will cause early return if expected check failure output
  was a `<error/check_error>`.
- `ℹ` indicates a check was skipped (a `<message/check_info>` condition
  class object was returned)

``` r
v
#> 
#> ── team1-goodmodel/2022-10-08-team1-goodmodel.csv ────
#> 
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
```

Note that the submission window check is always performed and reported
last.

### Validation warnings

Some validation functions may attach warnings to a `hub_validations`
object. These are informational messages about conditions that may
warrant attention but do not affect the validation result. There are two
levels of warnings:

- **Validation-level warnings** are attached to the `hub_validations`
  object itself and are always displayed prominently at the top of the
  print output in a box. For example,
  [`validate_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_pr.md)
  attaches a validation-level warning when hub configuration files have
  been modified in a pull request.

- **Check-level warnings** are attached to individual check results and
  provide additional context about a specific check. By default,
  check-level warnings are hidden. To display them, use
  `print(v, show_check_warnings = TRUE)`. They appear indented below
  their associated check result.

Here is an example showing both warning levels with
`show_check_warnings = TRUE`:

    #> ┌────────────────────────────────────────────────────────────────────┐
    #> │ ⚠ Warnings                                                         │
    #> │ • Hub config files modified: tasks.json. Config changes may affect │
    #> │   validation. Please review carefully.                             │
    #> └────────────────────────────────────────────────────────────────────┘
    #> 
    #> ── hub-baseline/2022-10-08-hub-baseline.csv ────
    #> 
    #> ✔ [file_exists]: File exists.
    #>     ! Check-level warning: additional context about this check.

## Structure of a `<hub_check>` object

Let’s look more closely at the structure of the first few elements of
the `hub_validations` object returned by
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_data.md):

``` r
str(utils::head(v))
#> List of 6
#>  $ file_read         :List of 4
#>   ..$ message       : chr "File could be read successfully. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_file_read"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ valid_round_id_col:List of 4
#>   ..$ message       : chr "`round_id_col` name is valid. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_valid_round_id_col"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ unique_round_id   :List of 4
#>   ..$ message       : chr "`round_id` column \033[34m\"origin_date\"\033[39m contains a single, unique round ID value. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_tbl_unique_round_id"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ match_round_id    :List of 4
#>   ..$ message       : chr "All `round_id_col` \033[34m\"origin_date\"\033[39m values match submission `round_id` from file name. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_tbl_match_round_id"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ colnames          :List of 4
#>   ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_tbl_colnames"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  $ col_types         :List of 4
#>   ..$ message       : chr "Column data types match hub schema. \n "
#>   ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>   ..$ call          : chr "check_tbl_col_types"
#>   ..$ use_cli_format: logi TRUE
#>   ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
#>  - attr(*, "where")= chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#>  - attr(*, "class")= chr [1:2] "hub_validations" "list"
```

Each `<hub_check>` object contains the following elements:

- `message`: the result message containing details about the check.
- `where`: what was validated (corresponds to the `where` attribute of
  the parent `hub_validations` object).
- `call`: the function used to perform the check.
- `use_cli_format`: whether the message is formatted using cli format,
  almost always TRUE.
- `warnings`: (optional) a list of check-level warning conditions
  providing additional context about the check. See the [Validation
  warnings](#validation-warnings) section above.

## Extra information

Some `<hub_check>` objects contain extra information about the failing
check to help identify affected rows in submissions.

For example, the `<hub_check>` object returned for the `valid_vals`
check, which checks that all columns in a model output file (excluding
the `value` column) contain valid combinations of task ID / output type
/ output type ID values contains an additional element called
`error_tbl`, with details of the invalid value combinations in the rows
affected.

To access `error_tbl` from a `hub_validations` object `v`, you would
use:

``` r
v$valid_vals$error_tbl
```

## Collection classes

When validating multiple items (e.g., with
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_submission.md)
or
[`validate_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_pr.md)),
results are organized hierarchically using collection classes.

### `<hub_validations_collection>` class

A `hub_validations_collection` is a named list where:

- **Names** identify what was validated (e.g., `"hub-config"`,
  `"team1-goodmodel/2022-10-08-team1-goodmodel.csv"`)
- **Elements** are `hub_validations` objects containing the checks for
  that item

Let’s look at an example using
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_submission.md):

``` r
v_collection <- validate_submission(hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
)

# Class of the returned object
class(v_collection)
#> [1] "hub_validations_collection" "list"

# Names show what was validated
names(v_collection)
#> [1] "hub-config"                                    
#> [2] "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

# Subset to access a specific hub_validations object
v_collection[["hub-config"]]
#> 
#> ── hub-config ────
#> 
#> ✔ [valid_config]: All hub config files are valid.

# Access a specific check within a file's validations
v_collection[["team1-goodmodel/2022-10-08-team1-goodmodel.csv"]]$file_exists
#> <message/check_success>
#> Message:
#> File exists at path
#> model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
```

See `vignette("validate-pr")` for more examples of working with
`hub_validations_collection` objects.

### `<target_validations_collection>` class

Similarly, `target_validations_collection` is used for target data
validation results, where each element contains a `target_validations`
object. See `vignette("validate-target-pr")` for examples of working
with `target_validations_collection` objects returned by
[`validate_target_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_pr.md).
