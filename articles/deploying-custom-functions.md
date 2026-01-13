# Deploying custom validation functions

``` r
library(hubValidations)
```

Custom validation functions can be included and configured within
standard `hubValidation` workflows by **including a `validations.yml`
file in the `hub-config` directory**. Alternatively, an appropriately
structured file can be included at a different location and the path to
the file provided through argument `validations_cfg_path`.

`hubValidations` uses the
[`config`](https://rstudio.github.io/config/articles/inheritance.html)
package to get validation configuration. This allows for configuration
inheritance and the ability to include executable R code. See the
`config` package vignette on [inheritance and R
expressions](https://rstudio.github.io/config/articles/inheritance.html)
for more details.

### `validations.yml` structure

`validations.yml` files should follow the nested structure described
below:

#### Default configuration

The top of any `validations.yml` file, under the required `default:` top
level property, should contain default custom validation configurations
that will be executed regardless of round ID.

Within the default configuration, individual checks can be configured
for each of the 3 validation functions run as part of
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_submission.md),
using the following structure for each validation function:

- **`<name-of-caller-function>`:** One of `validate_model_data`,
  `validate_model_metadata` and `validate_model_file` depending on the
  function the custom check is to be included in.
  - **`<name-of-check>`:** The name of the check. This is the name of
    the element containing the result of the check when
    `hub_validations` is returned (required).
    - **`fn`:** The name of the check function to be run, as character
      string (required).
    - **`pkg`:** The name of the package namespace from which to get
      check function. Must be supplied if function is distributed as
      part of a package.
    - **`source:`** Path to `.R` script containing function code to be
      sourced. If relative, should be relative to the hub’s directory
      root. Must be supplied if function is not part of a package and
      only exists as a script.
    - **`args`:** A yaml dictionary of key/value pairs of arguments and
      their values to be passed to the custom function. Values can be
      yaml lists or even executable R code (optional).

Each of the `validate_*()` functions **contain a number of standard
objects in their call environment** which are **available for downstream
check functions to use as arguments** and are **passed automatically to
arguments** of optional/custom functions **with the same name**.
Therefore, values for such arguments do not need including in function
deployment configuration but [**can be overridden through a function’s
`args`
configuration**](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.html#deploying-optional-hubvalidations-functions)
in `validations.yml` during deployment.

### Model output validation

**All model output `validate_*()` functions will contain the following
objects in their caller environment:**

- **`file_path`**: character string of path to file being validated
  relative to the `model-output` directory.
- **`hub_path`**: character string of path to hub.
- **`round_id`**: character string of `round_id` derived from the model
  file name.
- **`file_meta`**: named list containing `round_id`, `team_abbr`,
  `model_abbr` and `model_id` details.
- **`validations_cfg_path`**: character string of path to
  `validations.yml` file. Defaults to `hub-config/validations.yml`.

**[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_data.md)
will contain the following additional objects:**

- **`tbl`**: a tibble of the model output data being validated.
- **`tbl_chr`**: a tibble of the model output data being validated with
  all columns coerced to character type.
- **`round_id_col`**: character string of name of `tbl` column
  containing `round_id` information. Defaults to `NULL` and usually
  determined from the `tasks.json` config if applicable unless
  explicitly provided as an argument to
  [`validate_model_data()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_data.md).
- **`output_type_id_datatype`**: character string. The value of the
  `output_type_id_datatype` argument. This value is useful in functions
  like
  [`hubData::create_hub_schema()`](https://hubverse-org.github.io/hubData/reference/create_hub_schema.html)
  or
  [`hubValidations::expand_model_out_grid()`](https://hubverse-org.github.io/hubValidations/reference/expand_model_out_grid.md)
  to set the data type of `output_type_id` column.
- **`derived_task_ids`**: character vector or `NULL`. The value of the
  `derived_task_ids` argument, i.e. the names of task IDs whose values
  depend on other task IDs.

### Target data validation

**All target data `validate_*()` functions will contain the following
objects in their caller environment:**

- **`hub_path`**: character string of path to hub.
- **`file_path`**: character string of path to file being validated
  relative to the `target-data` directory.
- **`validations_cfg_path`**: character string of path to
  `validations.yml` file. Defaults to `hub-config/validations.yml`.
- **`round_id`**: character string. Not generally relevant to target
  datasets but can be used to specify a specific block of custom
  validation checks. Otherwise best set to `"default"`.

**[`validate_target_data()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_data.md)
will contain the following additional objects:**

- **`target_tbl`**: a tibble of the target data being validated.
- **`target_tbl_chr`**: a tibble of the target data being validated with
  all columns coerced to character type.
- **`target_type`**: character string. The type of target data being
  validated, either `"time-series"` or `"oracle-output"`.
- **`config_target_data`**: the parsed `target-data.json` config if
  available, otherwise `NULL`.
- **`date_col`**: character string or `NULL`. Optional name of the
  column containing the date observations actually occurred.
- **`allow_extra_dates`**: logical. Whether to allow extra dates in the
  target data beyond those defined in the hub config.
- **`output_type_id_datatype`**: character string. The value of the
  `output_type_id_datatype` argument.

**[`validate_target_dataset()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_dataset.md)
will contain the following additional objects:**

- **`target_type`**: character string. The type of target data being
  validated, either `"time-series"` or `"oracle-output"`.

The `args` configuration can be used to override objects from the caller
environment as well as defaults during deployment.

##### Deploying optional `hubValidations` functions

Here’s an example configuration for a single optional `hubValidations`
check,
[`opt_check_tbl_horizon_timediff()`](https://hubverse-org.github.io/hubValidations/reference/opt_check_tbl_horizon_timediff.md),
which checks that the temporal difference between the values in two date
columns (defined by additional arguments `t0_colname` & `t1_colname`) is
equal to a time period defined by horizon values (contained in a column
defined by `horizon_colname`) and the length of a single horizon defined
by argument `timediff`.

The check is to be run as part of the
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_data.md)
validation function which checks the content of the model data
submission files.

``` r
default:
    validate_model_data:
      horizon_timediff:
        fn: "opt_check_tbl_horizon_timediff"
        pkg: "hubValidations"
        args:
          t0_colname: "forecast_date"
          t1_colname: "target_end_date"
```

The above configuration file relies on default values for arguments
`horizon_colname` (`"horizon"`) and `timediff`
([`lubridate::weeks()`](https://lubridate.tidyverse.org/reference/period.html)).
We can **use the `validations.yml` `args` list to override the
`horizon_colname` and `timediff` argument default values**.

In this example, we **also include executable r code** as the value of
the `timediff` argument.

    default:
        validate_model_data:
          horizon_timediff:
            fn: "opt_check_tbl_horizon_timediff"
            pkg: "hubValidations"
            args:
              t0_colname: "forecast_date"
              t1_colname: "target_end_date"
              horizon_colname: "horizons"
              timediff: !expr lubridate::weeks(2)

##### Deploying custom functions

The above example involved an optional `hubValidation` function. To
deploy a custom function that is not part of the `hubValidations` or any
other package, you should store the script containing the function in
the `src/validations/R/` directory (relative to the root of your hub)
and include the path to the script in the `source` argument in the
configuration file.

    default:
        validate_model_data:
          custom_check:
            fn: "cstm_check_tbl_example"
            source: "src/validations/R/cstm_check_tbl_example.R"

#### Round specific configuration

Additional round specific configurations can be included in
`validations.yml` that can add to or override default configurations.

For example, in the following `validations.yml` which deploys the
[`opt_check_tbl_col_timediff()`](https://hubverse-org.github.io/hubValidations/reference/opt_check_tbl_col_timediff.md)
optional check, if the file being validated is being submitted to a
round with round ID `"2023-08-15"`, default `col_timediff` check
configuration will be overridden by the `2023-08-15` configuration.

``` yml
default:
    validate_model_data:
      col_timediff:
        fn: "opt_check_tbl_col_timediff"
        pkg: "hubValidations"
        args:
          t0_colname: "forecast_date"
          t1_colname: "target_end_date"

2023-08-15:
    validate_model_data:
      col_timediff:
        fn: "opt_check_tbl_col_timediff"
        pkg: "hubValidations"
        args:
          t0_colname: "forecast_date"
          t1_colname: "target_end_date"
          timediff: !expr lubridate::weeks(1)
```

### Available optional functions

`hubValidations` includes a number of optional checks or checks that
require administrator configuration to be run, detailed below.

For more detail on each function and its configuration parameters,
consult the function documentation.

#### For deploying through `validate_model_data`

| check fun                      | Check                                                                                                                  | Early return | Fail output   | Extra info |
|:-------------------------------|:-----------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-----------|
| opt_check_tbl_col_timediff     | Time difference between values in two date columns equal a defined period.                                             | FALSE        | check_failure |            |
| opt_check_tbl_counts_lt_popn   | Predicted values per location are less than total location population.                                                 | FALSE        | check_failure |            |
| opt_check_tbl_horizon_timediff | Time difference between values in two date columns equals a defined time period defined by values in a horizon column. | FALSE        | check_failure |            |

Details of available optional checks or checks requiring configuration
for
[`validate_model_data()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_data.md).

#### For deploying through `validate_model_metadata`

| check fun                           | Check                                                                                               | Early return | Fail output   | Extra info |
|:------------------------------------|:----------------------------------------------------------------------------------------------------|:-------------|:--------------|:-----------|
| opt_check_metadata_team_max_model_n | The number of metadata files submitted by a single team does not exceed the maximum number allowed. | FALSE        | check_failure |            |

Details of available optional checks or checks requiring configuration
for
[`validate_model_metadata()`](https://hubverse-org.github.io/hubValidations/reference/validate_model_metadata.md).

## Managing dependencies of custom functions

If any custom functions you are deploying depend on additional packages,
you will need to ensure these packages are available during validation.

### Available dependencies

**All `hubValidations` exported functions are available** for use in
your custom check functions as well as functions from hubverse packages
**`huUtils`**, **`hubAdmin`** and **`hubData`**.

In addition, **functions in packages from the `hubValidations`
dependency tree are also generally available**, both locally (once
`hubValidations` is installed) and in the hubverse `validate-submission`
GitHub Action.

Functions from these packages can be used in your custom checks without
specifying them as additional dependencies.

### Additional dependencies

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
[`validate_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_submission.md)
locally.

You could use documentation, like your hub’s README to communicate
additional required dependencies for validation to submitting teams.
Even better, you could add a check to the top of your function to catch
missing dependencies and provide a helpful error message to the user.

#### Deploying custom functions as a package

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
