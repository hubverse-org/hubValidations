# Helper functions for working with test target data tests

# Deletes and recreates the target data directory for the given hub and
# target type, ensuring it is empty before use.
test_clear_target_dir <- function(
  hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  target_dir <- test_target_dir_path(
    hub_path,
    target_type
  )
  fs::dir_delete(target_dir)
  fs::dir_create(target_dir)
  invisible(target_dir)
}

# Returns the file path to the single CSV target data file for the given hub and
# target type.
test_target_file_path <- function(
  hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  fs::path(hub_path, "target-data", target_type, ext = "csv")
}

# Returns the directory path containing partitioned target data files for the
# given hub and target type.
test_target_dir_path <- function(
  hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  fs::path(hub_path, "target-data", target_type)
}

# Reads and returns the CSV target data file for the given hub and target type.
test_read_target_data <- function(
  source_hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)

  source_target_path <- fs::path(
    source_hub_path,
    "target-data",
    target_type,
    ext = "csv"
  )
  arrow::read_csv_arrow(source_target_path)
}

# Writes the provided data as a Hive-partitioned Parquet dataset in the hub’s
# target data directory for the specified target type.
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
