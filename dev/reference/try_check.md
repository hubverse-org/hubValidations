# Wrap check expression in try to capture check execution errors

Wrap check expression in try to capture check execution errors

## Usage

``` r
try_check(expr, file_path)
```

## Arguments

- expr:

  check function expression to run.

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

## Value

If `expr` executes correctly, the output of `expr` is returned. If
execution fails, and object of class `<error/check_exec_error>` is
returned. The execution error message is attached as attribute `msg`.
