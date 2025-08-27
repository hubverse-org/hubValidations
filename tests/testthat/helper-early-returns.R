#' Helper to test early returns in `validate_target_data()`
#'
#' Mocks one `check_*()` to error and verifies that `validate_target_data()`
#' returns results only up to (and including) that check.
#'
#' @param check_name Character scalar: base name of the check to mock
#'   (e.g., `"target_tbl_coltypes"`). The helper mocks
#'   `check_<check_name>()` to `stop("testing early return")`.
#' @param expected_check_names Optional character vector of expected result names.
#'   If `NULL`, they’re inferred as checks up to `check_name`. For checks that
#'   don’t early-return, pass the full expected set.
#'
#' @return Invisibly returns `NULL`. Asserts via `testthat`.
#' @noRd
test_early_return_val_target_data <- function(
  check_name,
  expected_check_names = NULL
) {
  hub_path <- hubutils_target_file_hub() # nolint: object_usage_linter
  target_type <- "time-series"
  file_path <- fs::path(target_type, ext = "csv")

  check_mock <- setNames(
    list(function(...) stop("testing early return")),
    paste0("check_", check_name)
  )

  check_names <- c(
    "target_file_read",
    "target_tbl_colnames",
    "target_tbl_coltypes",
    "target_tbl_ts_targets",
    "target_tbl_rows_unique",
    "target_tbl_values",
    "target_tbl_output_type_ids",
    "target_tbl_oracle_value"
  )
  with_mocked_bindings(
    {
      res <- validate_target_data(
        hub_path,
        file_path = file_path,
        target_type = target_type
      )
      expect_s3_class(res, "hub_validations")
      # Expected check names should be those up to and including the one
      # that errored unless provided explicitly
      if (is.null(expected_check_names)) {
        expected_check_names <- check_names[1:match(check_name, check_names)]
      }
      expect_named(res, expected_check_names)
    },
    # mock exec error which should trigger early return
    !!!check_mock
  )
}
