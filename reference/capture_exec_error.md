# Capture an execution error condition

Capture an execution error condition. Useful for communicating when a
check execution has failed. Usually used in conjunction with
[`try`](https://rdrr.io/r/base/try.html).

## Usage

``` r
capture_exec_error(file_path, msg, call = NULL)
```

## Arguments

- file_path:

  character string. Path to the file being validated. Must be the
  relative path to the hub's `model-output` (or equivalent) directory.

- msg:

  Character string.

- call:

  Character string. Name of the parent call that failed to execute. If
  `NULL` (default), the caller's call name is captured.

## Value

A `<error/check_exec_error>` condition class object. Returned object
also inherits from subclass `<hub_check>`.
