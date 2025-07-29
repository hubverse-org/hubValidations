test_setup_blank_target_dir <- function(
  hub_path,
  source_hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  fs::dir_delete(hub_path)
  fs::dir_copy(source_hub_path, hub_path)
  # Delete single time-series file in preparation for creating time-series directory
  hub_ts_path <- fs::path(
    hub_path,
    "target-data",
    target_type,
    ext = "csv"
  )
  fs::file_delete(hub_ts_path)

  # Create hive partitioned timeseries data by target
  ts_dir <- test_target_dir_path(
    hub_path,
    target_type
  )
  fs::dir_create(ts_dir)
  invisible(ts_dir)
}
test_target_file_path <- function(
  hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  fs::path(hub_path, "target-data", target_type, ext = "csv")
}

test_target_dir_path <- function(
  hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  fs::path(hub_path, "target-data", target_type)
}

test_read_target_data <- function(
  source_hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  # Read timeseries data from single source hub file
  source_ts_path <- fs::path(
    source_hub_path,
    "target-data",
    target_type,
    ext = "csv"
  )
  arrow::read_csv_arrow(source_ts_path)
}

test_partition_target_data <- function(
  data,
  hub_path,
  target_type = c("time-series", "oracle-output"),
  partitioning = "target"
) {
  target_type <- rlang::arg_match(target_type)
  target_dir <- test_target_dir_path(hub_path, target_type)

  arrow::write_dataset(
    data,
    target_dir,
    partitioning = partitioning,
    format = "parquet"
  )
}
