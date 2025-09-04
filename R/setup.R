# Set up test hubs for testing PR validation
if (curl::has_internet()) {
  # Allow example data temp directory to persist across tests.
  tmp_dir <- withr::local_tempdir(clean = FALSE)
  # Only register teardown if running in a testthat context
  if (testthat::is_testing()) {
    withr::defer(
      fs::dir_delete(tmp_dir),
      envir = teardown_env()
    )
  }

  ci_simple_hub_path <- fs::path(tmp_dir, "simple")
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-simple.git",
    path = ci_simple_hub_path
  )

  ci_target_hub_path <- fs::path(tmp_dir, "target")
  gert::git_clone(
    url = "https://github.com/hubverse-org/ci-testhub-target.git",
    path = ci_target_hub_path
  )
}
