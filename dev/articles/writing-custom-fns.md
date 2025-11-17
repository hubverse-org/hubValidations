# Writing custom validation functions

``` r
library(hubValidations)
```

`hubValidations` provides a wide range of validation `check_*()`
functions, but there are times when you might need to write your own
custom check functions to check a specific aspect of your hub’s
submissions.

This guide will help you understand how to write custom check functions
and what tools are available in `hubValidations` to help.

Custom functions are configured through the `validations.yml` file and
executed as part of
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_data.md),
[`validate_model_metadata()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_metadata.md)
and
[`validate_model_file()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_file.md)
functions. More details about deploying custom check functions during
validation workflows are available in
**[`vignette("articles/deploying-custom-functions")`](https://hubverse-org.github.io/hubValidations/dev/articles/deploying-custom-functions.md)**.

## Anatomy of a check function

While source code of existing `hubValidations` `check_*()` functions can
be a good place to start when writing custom check functions, it is
important to understand the structure of a check function, particularly
the expected inputs and outputs.

At it’s most basic, a custom check function should:

- take in a set of inputs to be validated
- evaluate whether a condition is met
- return an appropriate check condition object

In addition, if the check condition is not met, it’s also helpful to
capture any details that can guide users towards specifics of the
failure and how to fix it

In general, `hubValidations` check functions evaluate conditions with
respect to one or more of the following:

- Model output submission files
- Model output submission file content (i.e data)
- Model metadata files

## `create_custom_check()` for creating custom check function templates

To help you get started on the right path, we also provide function
[`create_custom_check()`](https://hubverse-org.github.io/hubValidations/dev/reference/create_custom_check.md)
for creating a basic custom check function from a template.

The function requires a name for the new custom check function,
e.g. `"example_check"`. It then creates an `.R` script file named after
the function (`example_check.R`) and saves it in the hub at the
recommended location: `src/validations/R/`. The script contains basic
skeleton code to create a custom check function called `example_check`.

The output of
[`create_custom_check()`](https://hubverse-org.github.io/hubValidations/dev/reference/create_custom_check.md)
can also be parametarised through a number of arguments to include
additional template code snippets (see below for examples).

Let’s take a look at the basic structure of a custom check function
created by
[`create_custom_check()`](https://hubverse-org.github.io/hubValidations/dev/reference/create_custom_check.md).

We’ll start by creating a temporary “hub” for us to work in, but if you
have an existing hub, you can work in there.

``` r
hub_path <- withr::local_tempdir()

create_custom_check("cstm_check_tbl_basic",
  hub_path = hub_path
)
#> ✔ Directory /tmp/RtmpqeUVno/file21b926efdd9b/src/validations/R created.
#> ✔ Custom validation check template function file "cstm_check_tbl_basic.R" created.
#> → Edit the function template to add your custom check logic.
#> ℹ See the Writing custom check functions article for more information.
#> (<https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html>)
```

The contents of the created file at
`src/validations/R/cstm_check_tbl_basic.R` are as follows:

``` r
cstm_check_tbl_basic <- function(tbl, file_path) {
  # Here you can write your custom check logic
  # Assign the result as `TRUE` or `FALSE` to object called `check`.
  # If `check` is `TRUE`, the check will pass.

  check <- condition_to_be_TRUE_for_check_to_pass

  if (check) {
    details <- NULL
  } else {
    # You can use details messages to pass on helpful information to users about
    # what caused the validation failure and how to locate affected data.
    details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
  }

  hubValidations::capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var round_id}",
    msg_attribute = "valid.",
    error = FALSE,
    details = details
  )
}
```

### **Function naming conventions**

We recommend following the naming conventions used in `hubValidations`.

To distinguish `hubValidations` package functions from custom ones, we
recommend prefixing custom function names with an additional prefix,
e.g. `cstm_` or `cs`.

- `cstm_check_file_*` for checks that operate on model output files
  (e.g. file location, name etc).
- `cstm_check_tbl_*` for checks that operate on a tibble of model output
  data (i.e. the contents of a file).
- `cstm_check_meta_*` for checks that operate on model metadata files.
- `cstm_check_submission_*` for checks that operate on high level
  properties of the submission (e.g. timing).
- `cstm_check_config_*` for checks that operate on the hub configuration
  files.
- `cstm_check_valid_*` for checks that don’t fit into the above
  categories.

Neither of these recommendations are required for custom functions to
work, but consistency is an important aspect of maintaining a hub.

## Function inputs / arguments

The minimum inputs required by a custom check function depend on the
type of check being performed.

- **`file_path`**: the relative path to the submission file being
  validated is required for all check functions. **`file_path` must
  therefore be included as an argument** in all custom check function.
- **`tbl`** or **`tbl_chr`**: a **tibble representation of the contents
  of a model output** submission—with column data types matching the hub
  schema (`tbl`) or an all character version (`tbl_chr`)—is also
  **required by any checks that operate on the data** in the submission
  file.

Since `file_path` and `tbl` are the most common inputs to check
functions,
[`create_custom_check()`](https://hubverse-org.github.io/hubValidations/dev/reference/create_custom_check.md)
includes them as arguments by default. This means that the **custom
check function will include these objects in the function call
environment by default**.

Keep in mind that **`tbl` and `tbl_chr` are only available when calling
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_data.md)**,
but not in
[`validate_model_metadata()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_metadata.md)
or
[`validate_model_file()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_file.md).
Therefore, the default
[`create_custom_check()`](https://hubverse-org.github.io/hubValidations/dev/reference/create_custom_check.md)
function is designed for checks run by
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_data.md).

**If you’re not running your custom check with
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_data.md),
you should remove `tbl` from the function arguments**. If your custom
check not run by
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_data.md)
needs the model output file contents, you can use
`hubValidations::read_model_out_file(file_path)` within your function
body to read it.

In addition to these, custom check functions can also have additional
arguments for inputs required by the check. Some of these inputs **are
available in the check caller environment** and can be passed
automatically to a custom check function by including an argument with
the same name as the input object required in the custom function
formals. Other inputs can be passed explicitly to function arguments
through [the functions `args`
field](https://hubverse-org.github.io/hubValidations/dev/articles/deploying-custom-functions#validations-yml-structure)
when configuring the `validations.yml` file.

### Arguments available in the caller environment

Each of the `validate_*()` functions **contain a number of standard
objects in their call environment** which are **available for downstream
check functions to use as arguments** and are **passed automatically to
arguments** of optional/custom functions **with the same name**.
Therefore, values for such arguments do not need including in function
deployment configuration but [**can be overridden through a function’s
`args`
configuration**](https://hubverse-org.github.io/hubValidations/dev/articles/deploying-custom-functions.html#deploying-optional-hubvalidations-functions)
in `validations.yml` during deployment.

**All `validate_*()` functions will contain the following five objects
in their caller environment:**

- **`file_path`**: character string of path to file being validated
  relative to the `model-output` directory.  
- **`hub_path`**: character string of path to hub.
- **`round_id`**: character string of `round_id` derived from the model
  file name.
- **`file_meta`**: named list containing `round_id`, `team_abbr`,
  `model_abbr` and `model_id` details.
- **`validations_cfg_path`**: character string of path to
  `validations.yml` file. Defaults to `hub-config/validations.yml`.

**[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_data.md)
will contain the following additional objects:**

- **`tbl`**: a tibble of the model output data being validated.  
- **`tbl_chr`**: a tibble of the model output data being validated with
  all columns coerced to character type.  
- **`round_id_col`**: character string of name of `tbl` column
  containing `round_id` information. Defaults to `NULL` and usually
  determined from the `tasks.json` config if applicable unless
  explicitly provided as an argument to
  [`validate_model_data()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_model_data.md).
- **`output_type_id_datatype`**: character string. The value of the
  `output_type_id_datatype` argument. This value is useful in functions
  like
  [`hubData::create_hub_schema()`](https://rdrr.io/pkg/hubData/man/create_hub_schema.html)
  or
  [`hubValidations::expand_model_out_grid()`](https://hubverse-org.github.io/hubValidations/dev/reference/expand_model_out_grid.md)
  to set the data type of `output_type_id` column.
- **`derived_task_ids`**: character vector or `NULL`. The value of the
  `derived_task_ids` argument, i.e. the names of task IDs whose values
  depend on other task IDs.

The `args` configuration can be used to override objects from the caller
environment as well as defaults during deployment.

Note that, when writing custom functions, these objects **do not all
need to be specified as arguments** in the function definition. **Only
the ones that your custom function actually requires as inputs**.

### Additional arguments

You can add additional arguments to custom check functions and pass
values to them by including them in the `args` configuration in the
`validations.yml` file. These values are passed to the custom check
function by `hubValidations` when the function is called.

If you do add additional arguments to a custom check function, you
should also add input checks at the start of the function to ensure
inputs are valid. [The `checkmate`
package](https://mllg.github.io/checkmate/) contains a wide range of
functions for checking inputs.

For example, the optional check
[`opt_check_tbl_col_timediff()`](https://hubverse-org.github.io/hubValidations/dev/reference/opt_check_tbl_col_timediff.md)
(which is deployed in exactly the same fashion as custom functions,
i.e. through the `validations.yml` file) takes additional arguments
`t0_colname`, `t1_colname` and `timediff`.

``` r
opt_check_tbl_col_timediff
function (tbl, file_path, hub_path, t0_colname, t1_colname, timediff = lubridate::weeks(2), 
    output_type_id_datatype = c("from_config", "auto", "character", 
        "double", "integer", "logical", "Date")) 
{
    checkmate::assert_class(timediff, "Period")
    checkmate::assert_scalar(timediff)
    checkmate::assert_character(t0_colname, len = 1L)
    checkmate::assert_character(t1_colname, len = 1L)
    checkmate::assert_choice(t0_colname, choices = names(tbl))
    checkmate::assert_choice(t1_colname, choices = names(tbl))
    config_tasks <- read_config(hub_path, "tasks")
    output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
    schema <- create_hub_schema(config_tasks, partitions = NULL, 
        r_schema = TRUE, output_type_id_datatype = output_type_id_datatype)
    assert_column_date(t0_colname, schema)
    assert_column_date(t1_colname, schema)
    tbl <- subset_check_tbl(tbl, c(t0_colname, t1_colname))
    if (nrow(tbl) == 0) {
        return(capture_check_info(file_path = file_path, msg = "No relevant data to check. Check skipped."))
    }
    if (!lubridate::is.Date(tbl[[t0_colname]])) {
        tbl[, t0_colname] <- as.Date(tbl[[t0_colname]])
    }
    if (!lubridate::is.Date(tbl[[t1_colname]])) {
        tbl[, t1_colname] <- as.Date(tbl[[t1_colname]])
    }
    compare <- tbl[[t1_colname]] - tbl[[t0_colname]] == timediff
    check <- all(compare)
    if (check) {
        details <- NULL
    }
    else {
        details <- cli::format_inline("t1 var value{?s} {.val {tbl[[t1_colname]][!compare]}} invalid.")
    }
    capture_check_cnd(check = check, file_path = file_path, msg_subject = cli::format_inline("Time differences between t0 var {.var {t0_colname}} and t1 var\n        {.var {t1_colname}}"), 
        msg_verbs = c("all match", "do not all match"), msg_attribute = cli::format_inline("expected period of {.val {timediff}}."), 
        details = details)
}
<bytecode: 0x55fc5829a630>
<environment: namespace:hubValidations>
```

You can add an example extra argument with `extra_args = TRUE` when
creating the custom check function with
[`create_custom_check()`](https://hubverse-org.github.io/hubValidations/dev/reference/create_custom_check.md).

``` r
create_custom_check("cstm_check_tbl_args",
  hub_path = hub_path,
  extra_args = TRUE
)
#> ✔ Custom validation check template function file "cstm_check_tbl_args.R" created.
#> → Edit the function template to add your custom check logic.
#> ℹ See the Writing custom check functions article for more information.
#> (<https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html>)
```

This adds an extra example argument `extra_arg` to the custom check
function formals as well as an example input check to the top of the
function body.

``` r
cstm_check_tbl_args <- function(tbl, file_path, extra_arg = NULL) {
  # If you're providing additional custom arguments, make sure to include input checks
  # at the top of your function. `checkmate` package provides a simple interface
  # for many useful basic checks and is available through hubValidations.
  # The following example checks that `extra_arg` is a single character string.
  checkmate::assert_character(extra_arg, len = 1L, null.ok)

  # Here you can write your custom check logic
  # Assign the result as `TRUE` or `FALSE` to object called `check`.
  # If `check` is `TRUE`, the check will pass.

  check <- condition_to_be_TRUE_for_check_to_pass

  if (check) {
    details <- NULL
  } else {
    # You can use details messages to pass on helpful information to users about
    # what caused the validation failure and how to locate affected data.
    details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
  }

  hubValidations::capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var round_id}",
    msg_attribute = "valid.",
    error = FALSE,
    details = details
  )
}
```

## Function output

### Capturing and returning check results with `capture_check_cnd()`

The
[`capture_check_cnd()`](https://hubverse-org.github.io/hubValidations/dev/reference/capture_check_cnd.md)
function is used to return a check condition (success, failure, or
error) and it’s output is what a custom check function should return in
most cases (see below for exception). The function returns a
`<hub_check>` class object depending on the value passed to the `check`
argument, which represents the summary of the condition being checked by
a given validation function.

If the value passed to `check` is `TRUE`, the function returns a
`<message/check_success>` class object.

If the value is `FALSE`, the output depends on the `error` argument.

- If `error` is `FALSE` (the default), the function returns a
  `<error/check_failure>` class object, which indicates the check has
  failed.
- If `error` is `TRUE`, the function returns a `<error/check_error>`
  class object, which indicates the check has failed and additionally
  causes execution of further custom validation functions to halt. Set
  `error = TRUE` if downstream checks cannot be run if the current check
  fails.

``` r
create_custom_check("cstm_check_tbl_error",
  hub_path = hub_path, error = TRUE
)
#> ✔ Custom validation check template function file "cstm_check_tbl_error.R" created.
#> → Edit the function template to add your custom check logic.
#> ℹ See the Writing custom check functions article for more information.
#> (<https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html>)
```

``` r
cstm_check_tbl_error <- function(tbl, file_path) {
  # Here you can write your custom check logic
  # Assign the result as `TRUE` or `FALSE` to object called `check`.
  # If `check` is `TRUE`, the check will pass.

  check <- condition_to_be_TRUE_for_check_to_pass

  if (check) {
    details <- NULL
  } else {
    # You can use details messages to pass on helpful information to users about
    # what caused the validation failure and how to locate affected data.
    details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
  }

  hubValidations::capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var round_id}",
    msg_attribute = "valid.",
    error = TRUE,
    details = details
  )
}
```

### Skipping checks and returning a message with `capture_check_info()`

Sometimes a check function might not always be applicable and a
pre-condition needs to be met before the main check itself is performed.
**If the pre-condition is not met, the check is usually skipped**.

**For such checks, the function should return a `<message/check_info>`
object**, generated by the
[`capture_check_info()`](https://hubverse-org.github.io/hubValidations/dev/reference/capture_check_info.md)
function. Use the `msg` argument to explain that a check was skipped and
why.

``` r
capture_check_info(
  "modelA-teamA/2024-09-12-modelA-teamA",
  "Condition for running this check was not met. Skipped."
)
#> <message/check_info>
#> Message:
#> Condition for running this check was not met. Skipped.
```

For example, the
[`check_tbl_value_col_ascending()`](https://hubverse-org.github.io/hubValidations/dev/reference/check_tbl_value_col_ascending.md)
check function which validates that values are ascending when arranged
by increasing `output_type_id` order is only applicable to `cdf` and
`quantile` output types. Before proceeding with the main check, the
function first checks whether the model output `tbl` contains data for
`cdf` and `quantile` output types. If not, the check is skipped.

``` r
check_tbl_value_col_ascending
function (tbl, file_path, hub_path, round_id, derived_task_ids = get_hub_derived_task_ids(hub_path)) 
{
    check_output_types <- intersect(c("cdf", "quantile"), unique(tbl[["output_type"]]))
    if (length(check_output_types) == 0L) {
        return(capture_check_info(file_path, "No quantile or cdf output types to check for non-descending values.\n        Check skipped."))
    }
    config_tasks <- hubUtils::read_config(hub_path, "tasks")
    if (!is.null(derived_task_ids)) {
        tbl[derived_task_ids] <- NA_character_
    }
    error_tbl <- purrr::map(check_output_types, function(.x) {
        check_values_ascending_by_output_type(.x, tbl, config_tasks, 
            round_id, derived_task_ids)
    }) %>% purrr::list_rbind()
    check <- nrow(error_tbl) == 0L
    if (check) {
        details <- NULL
        error_tbl <- NULL
    }
    else {
        details <- cli::format_inline("See {.var error_tbl} attribute for details.")
    }
    capture_check_cnd(check = check, file_path = file_path, msg_subject = "Quantile or cdf {.var value} values", 
        msg_verbs = c("increase", "do not all increase"), msg_attribute = "when ordered by {.var output_type_id}.", 
        details = details, error_tbl = error_tbl)
}
<bytecode: 0x55fc5b591b90>
<environment: namespace:hubValidations>
```

You can add a pre-condition check block of code with argument
`conditional = TRUE` when creating the custom check function with
[`create_custom_check()`](https://hubverse-org.github.io/hubValidations/dev/reference/create_custom_check.md).

``` r
create_custom_check("cstm_check_tbl_skip",
  hub_path = hub_path,
  conditional = TRUE
)
#> ✔ Custom validation check template function file "cstm_check_tbl_skip.R" created.
#> → Edit the function template to add your custom check logic.
#> ℹ See the Writing custom check functions article for more information.
#> (<https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html>)
```

``` r
cstm_check_tbl_skip <- function(tbl, file_path) {
  if (!condition) {
    return(
      capture_check_info(
        file_path,
        "Condition for running this check was not met. Skipped."
      )
    )
  }

  # Here you can write your custom check logic
  # Assign the result as `TRUE` or `FALSE` to object called `check`.
  # If `check` is `TRUE`, the check will pass.

  check <- condition_to_be_TRUE_for_check_to_pass

  if (check) {
    details <- NULL
  } else {
    # You can use details messages to pass on helpful information to users about
    # what caused the validation failure and how to locate affected data.
    details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
  }

  hubValidations::capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var round_id}",
    msg_attribute = "valid.",
    error = FALSE,
    details = details
  )
}
```

## Loading config files

Many checks are conditioned against information stored in hub
configuration files and these are often read in at the start of the
custom check function.

The easiest way to make hub configuration information available within
your function is to pass the `hub_path` caller environment object by
specifying it as a function argument and then use
`hubUtils::read_config(hub_path)` to read in the `tasks.json`
configuration file.

You can add a `config = TRUE` argument when creating the custom check
function with
[`create_custom_check()`](https://hubverse-org.github.io/hubValidations/dev/reference/create_custom_check.md)
to include the `hub_path` argument and insert a code snippet in you
custom check function skeleton that reads in the `tasks.json` hub
configuration file.

``` r
create_custom_check("cstm_check_tbl_config",
  hub_path = hub_path,
  config = TRUE
)
#> ✔ Custom validation check template function file "cstm_check_tbl_config.R" created.
#> → Edit the function template to add your custom check logic.
#> ℹ See the Writing custom check functions article for more information.
#> (<https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html>)
```

``` r
cstm_check_tbl_config <- function(tbl, file_path, hub_path) {
  config_tasks <- hubValidations::read_config(hub_path)

  # Here you can write your custom check logic
  # Assign the result as `TRUE` or `FALSE` to object called `check`.
  # If `check` is `TRUE`, the check will pass.

  check <- condition_to_be_TRUE_for_check_to_pass

  if (check) {
    details <- NULL
  } else {
    # You can use details messages to pass on helpful information to users about
    # what caused the validation failure and how to locate affected data.
    details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
  }

  hubValidations::capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var round_id}",
    msg_attribute = "valid.",
    error = FALSE,
    details = details
  )
}
```

## Custom function dependencies

When writing your functions you might want to use functions from other
packages.

## Available dependencies

**All `hubValidations` exported functions are available** for use in
your custom check functions as well as functions from hubverse packages
**`huUtils`**, **`hubAdmin`** and **`hubData`**.

In addition, **functions in packages from the `hubValidations`
dependency tree are also generally available**, both locally (once
`hubValidations` is installed) and in the hubverse `validate-submission`
GitHub Action.

Functions from these packages can be used in your custom checks without
specifying them as additional dependencies.

## Additional dependencies

If any custom functions you are deploying depend on additional packages,
you will need to ensure these packages are available during validation.

The simplest way to ensure they are available is to edit the
`setup-r-dependencies` step in the `hubverse-actions`
[`validate-submission.yaml`](https://github.com/hubverse-org/hubverse-actions/blob/main/validate-submission/validate-submission.yaml)
GitHub Action workflow of your hub and add any additional dependency to
the `packages` field list.

In the following pseudo example we add `additionalPackage` package to
the list of standard dependencies:

``` yaml
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          packages: |
            any::hubValidations
            any::sessioninfo
            any::additionalPackage
```

Note that this ensures the additional dependency is available during
validation on GitHub but does not guarantee it will be installed locally
for hub administrators or submitting teams. Indeed such missing
dependencies could lead to execution errors in custom checks when
running
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/dev/reference/validate_submission.md)
locally.

You could use documentation, like your hub’s README to communicate
additional required dependencies for validation to submitting teams.
Even better, you could add a check to the top of your function to catch
missing dependencies and provide a helpful error message to the user.

## Managing custom check functions as a package

The simplest way to manage custom check functions is to store them as
scripts in the `src/validations/R` directory in the root of the hub and
source them during validation by specifying the path to a custom
functions file via the `source:` property in `validations.yml`.

Alternatively, you could **manage your custom functions as a package**.

You can easily [turn the contents of `src/validations` into a local
`validations` R
package](https://r-pkgs.org/whole-game.html#create_package) with:

``` r
usethis::create_package("src/validations", open = FALSE)
```

This would allow you to:

- Make your functions available locally by users who could use
  `pak::local_install("src/validations")` in the hub root to install the
  `validations` package.
- [Manage additional
  dependencies](https://r-pkgs.org/description.html#sec-description-imports-suggests)
  required by your custom functions formally through the `DESCRIPTION`
  file.
- [Formally test your custom
  functions](https://r-pkgs.org/testing-basics.html) using `testthat`
  tests in the `tests/testthat` directory.

### Deploying custom functions as a package

To deploy custom functions managed as a package in `src/validations`,
you can use the `pkg` configuration property in the `validations.yml`
file to specify the package namespace.

For example, if you have created a simple package in `src/validations/`
with a `cstm_check_tbl_example.R` script containing the specification of
an `cstm_check_tbl_example()` function in `src/validations/R`, you can
use the following configuration in your `validation.yml` file to source
the function from the installed `validations` package namespace:

    default:
        validate_model_data:
          custom_check:
            fn: "cstm_check_tbl_example"
            pkg: "validations"

To ensure the package (and any additional dependencies it depends on) is
installed and available during validation, you must add the package to
the `setup-r-dependencies` step in the `hubverse-actions`
`validate-submission.yaml` GitHub Action workflow of your hub like so:

``` yaml
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          packages: |
            any::hubValidations
            any::sessioninfo
            local::./src/validations
```

If you want to share custom functions across multiple hubs, you could
even consider separating them into a standalone package and hosting them
on GitHub.
