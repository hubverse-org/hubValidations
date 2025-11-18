# Get status of a hub check

Get status of a hub check

## Usage

``` r
is_success(x)

is_failure(x)

is_error(x)

is_info(x)

not_pass(x)

is_exec_error(x)

is_exec_warn(x)

is_any_error(x)
```

## Arguments

- x:

  an object that inherits from class `<hub_check>` to test.

## Value

Logical. Is given status of check TRUE?

## Functions

- `is_success()`: Is check success?

- `is_failure()`: Is check failure?

- `is_error()`: Is check error?

- `is_info()`: Is check info?

- `not_pass()`: Did check not pass?

- `is_exec_error()`: Is exec error?

- `is_exec_warn()`: Is exec warning?

- `is_any_error()`: Is error or exec error?
