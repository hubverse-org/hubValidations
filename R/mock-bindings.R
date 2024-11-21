# These bindings allow us to mock base functions in tests.
# See: https://blog.r-hub.io/2024/03/21/mocking-new-take/

# Binging for mocking `Sys.time` function in tests of `validate_pr` and
# validate_submission
Sys.time <- NULL
