# Capture a validation warning condition

Capture a warning about the validation process. Unlike check results
(success/failure/error), validation warnings are informational messages
about the validation process itself rather than validation outcomes.

## Usage

``` r
capture_validation_warning(msg, where = NULL, call = rlang::caller_call(), ...)
```

## Arguments

- msg:

  Character string. The warning message. Accepts text that can be
  interpreted and formatted by
  [`cli::format_inline()`](https://cli.r-lib.org/reference/format_inline.html).

- where:

  Optional. Character string indicating the location or context of the
  warning (e.g., file path, `"hub-config"`). Used as metadata.

- call:

  The defused call of the function that generated the warning. Use to
  override default which uses the caller call. See
  [rlang::stack](https://rlang.r-lib.org/reference/stack.html) for more
  details.

- ...:

  Additional named fields to include in the warning condition object.
  Useful for attaching structured data (e.g.,
  `config_files = c("tasks.json")`).

## Value

A `<warning/validation_warning>` condition class object.

## Details

Validation warnings can be attached at two levels:

- **Validation-level**: Stored as an attribute on `hub_validations`
  objects, printed prominently by default.

- **Check-level**: Stored in a `warnings` field on individual check
  results, printed only when `verbose = TRUE`.

## Examples

``` r
# Simple warning
capture_validation_warning(
  msg = "Configuration files were modified"
)
#> <warning/validation_warning>
#> Warning:
#> Configuration files were modified

# Warning with location and additional structured data
config_files <- c("tasks.json", "admin.json")
capture_validation_warning(
  msg = "Config files modified: {.path {config_files}}",
  where = "hub-config",
  config_files = config_files
)
#> Error in "fun(..., .envir = .envir)": ! Could not evaluate cli `{}` expression: `config_files`.
#> Caused by error in `eval(expr, envir = envir)`:
#> ! object 'config_files' not found
```
