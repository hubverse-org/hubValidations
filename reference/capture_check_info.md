# Capture a simple info message condition

Capture a simple info message condition. Useful for communicating when a
check is ignored or skipped.

## Usage

``` r
capture_check_info(file_path, msg, call = rlang::caller_call())
```

## Arguments

- file_path:

  character string. Path to the file being validated. Must be the
  relative path to the hub's `model-output` (or equivalent) directory.

- msg:

  Character string. Accepts text that can interpreted and formatted by
  [`cli::format_inline()`](https://cli.r-lib.org/reference/format_inline.html).

- call:

  The defused call of the function that generated the message. Use to
  override default which uses the caller call. See
  [rlang::stack](https://rlang.r-lib.org/reference/stack.html) for more
  details.

## Value

A `<message/check_info>` condition class object. Returned object also
inherits from subclass `<hub_check>`.
