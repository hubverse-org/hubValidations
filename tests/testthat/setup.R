# Set up test target data hub
example_hub_exists <- exists("hub_path") && dir.exists(
  file.path(hub_path, "target-data")
)
if (curl::has_internet() && !example_hub_exists) {
  tmp_dir <- withr::local_tempdir(clean = FALSE)
  hub_path <- fs::path(tmp_dir, "main")
  file_hub_path <- fs::path(tmp_dir, "file")
  dir_hub_path <- fs::path(tmp_dir, "dir")
  example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
  gert::git_clone(url = example_hub, path = hub_path)
  fs::dir_copy(hub_path, file_hub_path)
  fs::dir_copy(hub_path, dir_hub_path)
}
