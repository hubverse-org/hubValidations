# Create a custom validation check function template file.

Create a custom validation check function template file.

## Usage

``` r
create_custom_check(
  name,
  hub_path = ".",
  r_dir = "src/validations/R",
  error = FALSE,
  conditional = FALSE,
  error_object = FALSE,
  config = FALSE,
  extra_args = FALSE,
  overwrite = FALSE
)
```

## Arguments

- name:

  Character string. Name of the custom check function. We recommend
  following the hubValidations package naming convention. For more
  details, consult the article on [writing custom check
  functions](https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html).

- hub_path:

  Character string. Path to the hub directory. Default is the current
  working directory.

- r_dir:

  Character string. Path (relative to `hub_path`) to the directory the
  custom check function file will be written to. Default is
  `src/validations/R` which is the recommended directory for storing
  custom check functions.

- error:

  Logical. Defaults to `FALSE`, which will return a
  `<error/check_failure>` class object in the case of a failed check.
  Set this to `TRUE` if your custom check function is required to pass
  for other custom checks to be performed; in the case of a failed
  check, the custom check function will then return an
  `<error/check_error>` class object and cause custom validations to
  return early. Note that in the case of custom validations, executions
  errors in custom functions will also result in custom validations
  returning early.

- conditional:

  Logical. If `TRUE`, the custom check function template will include a
  block of code to check a condition before running the check. This is
  useful when a check may need to be skipped based on a condition.

- error_object:

  Logical. If `TRUE`, the custom check function template will include an
  error object that can be used to store additional information about
  the properties of the object being checked that caused check failure.
  For example, it could store the index of rows in a `tbl` that caused a
  check failure.

- config:

  Logical. If `TRUE`, the custom check function template will include
  `hub_path` as a function argument and a block of code for reading in
  the hub `tasks.json` config file.

- extra_args:

  Logical. If `TRUE`, the custom check function template will include an
  `extra_arg` template function argument and template block of code to
  check the input arguments of the custom check function.

- overwrite:

  Logical. If `TRUE`, the function will overwrite an existing

## Value

Invisible `TRUE` if the custom check function file is created
successfully.

## Details

See the article on [writing custom check
functions](https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html)
for more.

## Examples

``` r
withr::with_tempdir({
  # Create the custom check file with default settings.
  create_custom_check("check_default")
  cat(readLines("src/validations/R/check_default.R"), sep = "\n")

  # Create fully featured custom check file.
  create_custom_check("check_full",
    error = TRUE, conditional = TRUE,
    error_object = TRUE, config = TRUE,
    extra_args = TRUE
  )
  cat(readLines("src/validations/R/check_full.R"), sep = "\n")
})
#> ✔ Directory src/validations/R created.
#> ✔ Custom validation check template function file "check_default.R" created.
#> → Edit the function template to add your custom check logic.
#> ℹ See the Writing custom check functions article for more information.
#> (<https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html>)
#> check_default <- function(tbl, file_path) {
#>   # Here you can write your custom check logic
#>   # Assign the result as `TRUE` or `FALSE` to object called `check`.
#>   # If `check` is `TRUE`, the check will pass.
#> 
#>   check <- condition_to_be_TRUE_for_check_to_pass
#> 
#>   if (check) {
#>     details <- NULL
#>   } else {
#>     # You can use details messages to pass on helpful information to users about
#>     # what caused the validation failure and how to locate affected data.
#>     details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
#>   }
#> 
#>   hubValidations::capture_check_cnd(
#>     check = check,
#>     file_path = file_path,
#>     msg_subject = "{.var round_id}",
#>     msg_attribute = "valid.",
#>     error = FALSE,
#>     details = details
#>   )
#> }
#> ✔ Custom validation check template function file "check_full.R" created.
#> → Edit the function template to add your custom check logic.
#> ℹ See the Writing custom check functions article for more information.
#> (<https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html>)
#> check_full <- function(tbl, file_path, hub_path, extra_arg = NULL) {
#>   # If you're providing additional custom arguments, make sure to include input checks
#>   # at the top of your function. `checkmate` package provides a simple interface
#>   # for many useful basic checks and is available through hubValidations.
#>   # The following example checks that `extra_arg` is a single character string.
#>   checkmate::assert_character(extra_arg, len = 1L, null.ok)
#> 
#>   config_tasks <- hubValidations::read_config(hub_path)
#> 
#>   if (!condition) {
#>     return(
#>       capture_check_info(
#>         file_path,
#>         "Condition for running this check was not met. Skipped."
#>       )
#>     )
#>   }
#> 
#>   # Here you can write your custom check logic
#>   # Assign the result as `TRUE` or `FALSE` to object called `check`.
#>   # If `check` is `TRUE`, the check will pass.
#> 
#>   check <- condition_to_be_TRUE_for_check_to_pass
#> 
#>   if (check) {
#>     details <- NULL
#>     error_object <- NULL
#>   } else {
#>     # You can use details messages and any type of R object to pass on helpful
#>     # information to users about what caused the validation failure and how to
#>     # locate affected data.
#>     error_object <- list(
#>       invalid_rows = which(tbl$example_task_id == "invalid")
#>     )
#>     details <- cli::format_inline("See {.var error_object} attribute for details.")
#>   }
#> 
#>   hubValidations::capture_check_cnd(
#>     check = check,
#>     file_path = file_path,
#>     msg_subject = "{.var round_id}",
#>     msg_attribute = "valid.",
#>     error = TRUE,
#>     error_object = error_object,
#>     details = details
#>   )
#> }
```
