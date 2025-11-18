# Capture a condition of the result of validation check.

Capture a condition of the result of validation check.

## Usage

``` r
capture_check_cnd(
  check,
  file_path,
  msg_subject,
  msg_attribute,
  msg_verbs = c("is", "must be"),
  error = FALSE,
  details = NULL,
  ...
)
```

## Arguments

- check:

  logical, the result of a validation check. If `check` is `FALSE`,
  validation has failed. If `check` is `TRUE`, validation has succeeded.

- file_path:

  character string. Path to the file being validated. Must be the
  relative path to the hub's `model-output` (or equivalent) directory.

- msg_subject:

  character string. The subject of the validation.

- msg_attribute:

  character string. The attribute of subject being validated.

- msg_verbs:

  character vector of length 2. The verbs describing the state of the
  attribute in relation to the validation subject. The first element
  describes the state when validation succeeds, the second element, when
  validation fails.

- error:

  logical. In the case of validation failure, whether the function
  should return an object of class `<error/check_error>` (`TRUE`) or
  `<error/check_failure>` (`FALSE`, default).

- details:

  further details to be appended to the output message.

- ...:

  \<[dynamic](https://rlang.r-lib.org/reference/dyn-dots.html)\> Named
  data fields stored inside the condition object.

## Value

Depending on whether validation has succeeded and the value of the
`error` argument, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

Arguments `msg_subject`, `msg_attribute`, `msg_verbs` and `details`
accept text that can interpreted and formatted by
[`cli::format_inline()`](https://cli.r-lib.org/reference/format_inline.html).

## Examples

``` r
capture_check_cnd(
  check = TRUE, file_path = "test/file.csv",
  msg_subject = "{.var round_id}", msg_attribute = "valid.", error = FALSE
)
#> <message/check_success>
#> Message:
#> `round_id` is valid.
capture_check_cnd(
  check = FALSE, file_path = "test/file.csv",
  msg_subject = "{.var round_id}", msg_attribute = "valid.", error = FALSE,
  details = "Must be one of 'A' or 'B', not 'C'"
)
#> <error/check_failure>
#> Error:
#> ! `round_id` must be valid.  Must be one of 'A' or 'B', not 'C'
capture_check_cnd(
  check = FALSE, file_path = "test/file.csv",
  msg_subject = "{.var round_id}", msg_attribute = "valid.", error = TRUE,
  details = "Must be one of {.val {c('A', 'B')}}, not {.val C}"
)
#> <error/check_error>
#> Error:
#> ! `round_id` must be valid.  Must be one of "A" and "B", not "C"
```
