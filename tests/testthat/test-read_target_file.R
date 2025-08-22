# Set up test target data hub
hub_path <- system.file(
  "testhubs/v5/target_file",
  package = "hubUtils"
)
tmp_dir <- withr::local_tempdir()
dir_hub_path <- fs::path(tmp_dir, "dir")
fs::dir_copy(hub_path, dir_hub_path)


test_that("read_target_file works with single timeseries file.", {
  skip_if_offline()
  # read in time-series file with hub schema
  file <- read_target_file("time-series.csv", hub_path)
  expect_s3_class(file, "tbl_df")
  expect_equal(
    names(file),
    c("target_end_date", "target", "location", "observation")
  )
  expect_equal(dim(file), c(66L, 4L))
  expect_equal(
    purrr::map_chr(file, ~ class(.x)),
    c(
      target_end_date = "Date",
      target = "character",
      location = "character",
      observation = "numeric"
    )
  )
  expect_equal(
    purrr::map_chr(file, ~ typeof(.x)),
    c(
      target_end_date = "double",
      target = "character",
      location = "character",
      observation = "double"
    )
  )

  # read in time-series file as character columns
  chr_file <- read_target_file(
    "time-series.csv",
    hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(chr_file, "tbl_df")
  expect_equal(dim(chr_file), c(66L, 4L))
  expect_equal(
    purrr::map_chr(chr_file, ~ class(.x)),
    c(
      target_end_date = "character",
      target = "character",
      location = "character",
      observation = "character"
    )
  )
})

test_that("read_target_file works with single oracle-output file.", {
  skip_if_offline()
  # read in oracle-output file with hub schema
  file <- read_target_file("oracle-output.csv", hub_path)
  expect_s3_class(file, "tbl_df")
  expect_equal(
    names(file),
    c(
      "location",
      "target_end_date",
      "target",
      "output_type",
      "output_type_id",
      "oracle_value"
    )
  )
  expect_true(all(is.na(file$output_type_id[file$output_type == "quantile"])))
  expect_equal(dim(file), c(627L, 6L))
  expect_equal(
    purrr::map_chr(file, ~ class(.x)),
    c(
      location = "character",
      target_end_date = "Date",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "numeric"
    )
  )
  expect_equal(
    purrr::map_chr(file, ~ typeof(.x)),
    c(
      location = "character",
      target_end_date = "double",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "double"
    )
  )

  # read in oracle-output file as character columns
  chr_file <- read_target_file(
    "oracle-output.csv",
    hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(chr_file, "tbl_df")
  expect_equal(dim(chr_file), c(627L, 6L))
  expect_true(all(is.na(file$output_type_id[file$output_type == "quantile"])))
  expect_equal(
    purrr::map_chr(chr_file, ~ class(.x)),
    c(
      location = "character",
      target_end_date = "character",
      target = "character",
      output_type = "character",
      output_type_id = "character",
      oracle_value = "character"
    )
  )
})

test_that("read_target_file errors correctly.", {
  skip_if_offline()
  expect_error(
    read_target_file("non-existent.csv", hub_path),
    regexp = "Could not determine target type of file"
  )
  expect_error(
    read_target_file(
      c(
        "time-series.csv",
        "oracle-output.csv"
      ),
      hub_path
    ),
    regexp = "Assertion on 'target_file_path' failed: Must have length 1, but has length 2."
  )
  expect_error(
    read_target_file("time-series", hub_path),
    regexp = "No file exists at path"
  )
})

test_that("read_target_file works with split timeseries file.", {
  skip_if_offline()

  fs::dir_copy(hub_path, dir_hub_path)
  path <- abs_file_path("time-series.csv", dir_hub_path, subdir = "target-data")
  # Read timeseries data from single file
  dat <- arrow::read_csv_arrow(path)
  # Delete single time-series file in preparation for creating time-series directory
  fs::file_delete(path)

  # Create a seperate file for each target in a time-series directory
  dir <- fs::path(dir_hub_path, "target-data", "time-series")
  fs::dir_create(dir)
  split(dat, dat$target) |>
    purrr::iwalk(
      ~ {
        target <- gsub(" ", "_", .y)
        path <- file.path(dir, paste0("target-", target, ".csv"))
        arrow::write_csv_arrow(.x, file = path)
      }
    )

  # read in one of the time-series file with hub schema
  file <- read_target_file(
    "time-series/target-wk_inc_flu_hosp.csv",
    dir_hub_path
  )
  expect_s3_class(file, "tbl_df")
  expect_equal(
    names(file),
    c("target_end_date", "target", "location", "observation")
  )
  expect_equal(dim(file), c(33L, 4L))
  expect_equal(
    purrr::map_chr(file, ~ class(.x)),
    c(
      target_end_date = "Date",
      target = "character",
      location = "character",
      observation = "numeric"
    )
  )
  expect_equal(
    purrr::map_chr(file, ~ typeof(.x)),
    c(
      target_end_date = "double",
      target = "character",
      location = "character",
      observation = "double"
    )
  )

  # read in one of the time-series file with all character columns
  chr_file <- read_target_file(
    "time-series/target-wk_inc_flu_hosp.csv",
    dir_hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(chr_file, "tbl_df")
  expect_equal(dim(chr_file), c(33L, 4L))
  expect_equal(
    purrr::map_chr(chr_file, ~ class(.x)),
    c(
      target_end_date = "character",
      target = "character",
      location = "character",
      observation = "character"
    )
  )
})

test_that("connect_target_timeseries with HIVE-PARTTIONED data works on local hub", {
  skip_if_offline()
  fs::dir_delete(dir_hub_path)
  fs::dir_copy(hub_path, dir_hub_path)
  path <- abs_file_path("time-series.csv", dir_hub_path, subdir = "target-data")
  # Read timeseries data from single file
  dat <- arrow::read_csv_arrow(path)
  # Delete single time-series file in preparation for creating time-series directory
  fs::file_delete(path)

  # Create hive partitioned timeseries data by target
  dir <- fs::path(dir_hub_path, "target-data", "time-series")
  fs::dir_create(dir)

  # Create a PARQUET hive partitioned timeseries dataset by target ----
  arrow::write_dataset(dat, dir, partitioning = "target", format = "parquet")

  # read in one of the time-series file with hub schema
  file <- read_target_file(
    "time-series/target=wk%20inc%20flu%20hosp/part-0.parquet",
    hub_path = dir_hub_path
  )
  expected_dims <- c(33L, 4L)
  expect_s3_class(file, "tbl_df")
  expect_equal(
    names(file),
    c("target_end_date", "location", "observation", "target")
  )
  expect_equal(dim(file), expected_dims)
  expect_equal(
    purrr::map_chr(file, ~ class(.x)),
    c(
      target_end_date = "Date",
      location = "character",
      observation = "numeric",
      target = "character"
    )
  )
  expect_equal(
    purrr::map_chr(file, ~ typeof(.x)),
    c(
      target_end_date = "double",
      location = "character",
      observation = "double",
      target = "character"
    )
  )
  # read in one of the time-series file as all character
  file_chr <- read_target_file(
    "time-series/target=wk%20inc%20flu%20hosp/part-0.parquet",
    hub_path = dir_hub_path,
    coerce_types = "chr"
  )
  expect_equal(dim(file_chr), expected_dims)
  expect_equal(
    purrr::map_chr(file_chr, ~ class(.x)),
    c(
      target_end_date = "character",
      location = "character",
      observation = "character",
      target = "character"
    )
  )

  # Create CSV a hive partitioned timeseries dataset by target ----
  skip_on_os("windows")
  fs::dir_delete(dir)
  fs::dir_create(dir)
  arrow::write_dataset(dat, dir, partitioning = "target", format = "csv")
  # read in one of the time-series file with hub schema
  file <- read_target_file(
    "time-series/target=wk%20inc%20flu%20hosp/part-0.csv",
    hub_path = dir_hub_path
  )

  expect_s3_class(file, "tbl_df")
  expect_equal(dim(file), expected_dims)
  expect_equal(
    purrr::map_chr(file, ~ class(.x)),
    c(
      target_end_date = "Date",
      location = "character",
      observation = "numeric",
      target = "character"
    )
  )
  expect_equal(
    purrr::map_chr(file, ~ typeof(.x)),
    c(
      target_end_date = "double",
      location = "character",
      observation = "double",
      target = "character"
    )
  )
  # read in one of the time-series file as all character
  file_chr <- read_target_file(
    "time-series/target=wk%20inc%20flu%20hosp/part-0.csv",
    hub_path = dir_hub_path,
    coerce_types = "chr"
  )
  expect_equal(dim(file_chr), expected_dims)
  expect_equal(
    purrr::map_chr(file_chr, ~ class(.x)),
    c(
      target_end_date = "character",
      location = "character",
      observation = "character",
      target = "character"
    )
  )

  # Create CSV a hive partitioned timeseries dataset by target_end_date ----
  fs::dir_delete(dir)
  fs::dir_create(dir)
  arrow::write_dataset(
    dat,
    dir,
    partitioning = "target_end_date",
    format = "csv"
  )
  file <- read_target_file(
    "time-series/target_end_date=2022-10-22/part-0.csv",
    hub_path = dir_hub_path,
    date_col = "target_end_date"
  )

  expected_dims <- c(6L, 4L)
  expect_s3_class(file, "tbl_df")
  expect_equal(dim(file), expected_dims)
  expect_equal(
    purrr::map_chr(file, ~ class(.x)),
    c(
      target = "character",
      location = "character",
      observation = "numeric",
      target_end_date = "Date"
    )
  )
  expect_equal(
    purrr::map_chr(file, ~ typeof(.x)),
    c(
      target = "character",
      location = "character",
      observation = "double",
      target_end_date = "double"
    )
  )
  # read in one of the time-series file as all character
  file_chr <- read_target_file(
    "time-series/target_end_date=2022-10-22/part-0.csv",
    hub_path = dir_hub_path,
    coerce_types = "chr"
  )
  expect_equal(dim(file_chr), expected_dims)
  expect_equal(
    purrr::map_chr(file_chr, ~ class(.x)),
    c(
      target = "character",
      location = "character",
      observation = "character",
      target_end_date = "character"
    )
  )
})
