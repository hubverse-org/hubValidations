# Set up test target data hub
example_hub_exists <- exists("example_complex_forecasting_hub_path") &&
  dir.exists(
    file.path(example_complex_forecasting_hub_path, "target-data")
  )
if (curl::has_internet() && !example_hub_exists) {
  # Allow example data temp directory to persist across tests.
  tmp_dir <- withr::local_tempdir(clean = FALSE)
  # Only register teardown if running in a testthat context
  if (is_testing()) {
    withr::defer(
      fs::dir_delete(tmp_dir),
      envir = teardown_env()
    )
  }

  example_complex_forecasting_hub_path <- fs::path(tmp_dir, "main")
  example_file_hub_path <- fs::path(tmp_dir, "file")
  example_dir_hub_path <- fs::path(tmp_dir, "dir")
  example_hub_url <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
  gert::git_clone(
    url = example_hub_url,
    path = example_complex_forecasting_hub_path
  )
  fs::dir_copy(
    example_complex_forecasting_hub_path,
    example_file_hub_path
  )
  fs::dir_copy(
    example_complex_forecasting_hub_path,
    example_dir_hub_path
  )
}
