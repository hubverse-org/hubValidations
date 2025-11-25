test_that("get_obs_unit works with oracle-output (v5 inference mode)", {
  hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- read_target_file("oracle-output.csv", hub_path)

  # Without as_of column
  obs_unit <- get_obs_unit(tbl, config_tasks)
  expect_type(obs_unit, "character")
  expect_setequal(obs_unit, c("location", "target_end_date", "target"))

  # With as_of column - should always include it in inference mode
  tbl$as_of <- as.Date("2024-01-15")
  obs_unit_with_as_of <- get_obs_unit(tbl, config_tasks)
  expect_setequal(
    obs_unit_with_as_of,
    c("location", "target_end_date", "target", "as_of")
  )

  # include_as_of parameter should have no effect in inference mode
  as_of_false <- get_obs_unit(
    tbl,
    config_tasks,
    config_target_data = NULL,
    target_type = NULL,
    include_as_of = FALSE
  )
  expect_true("as_of" %in% as_of_false)
})

test_that("get_obs_unit works with time-series (v5 inference mode)", {
  hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- read_target_file("time-series.csv", hub_path)

  # Without as_of column
  obs_unit <- get_obs_unit(tbl, config_tasks)
  expect_type(obs_unit, "character")
  expect_setequal(obs_unit, c("target_end_date", "target", "location"))

  # With as_of column
  tbl$as_of <- as.Date("2024-01-15")
  obs_unit_with_as_of <- get_obs_unit(tbl, config_tasks)
  expect_setequal(
    obs_unit_with_as_of,
    c("target_end_date", "target", "location", "as_of")
  )
})

test_that("get_obs_unit works with v6 oracle-output and config_target_data", {
  skip_if_not_installed("hubUtils", minimum_version = "0.1.0")

  hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  config_target_data <- hubUtils::read_config(hub_path, "target-data")
  tbl <- read_target_file("oracle-output.csv", hub_path)

  # Should error when target_type is NULL with config_target_data provided
  expect_error(
    get_obs_unit(tbl, config_tasks, config_target_data, target_type = NULL),
    regexp = "`target_type` must be a character vector, not `NULL`."
  )

  # With include_as_of = FALSE, should not include as_of
  obs_unit <- get_obs_unit(
    tbl,
    config_tasks,
    config_target_data = config_target_data,
    target_type = "oracle-output",
    include_as_of = FALSE
  )
  expect_setequal(obs_unit, config_target_data$observable_unit)
  expect_false("as_of" %in% obs_unit)

  # With include_as_of = TRUE but data is NOT versioned, should not include as_of
  obs_unit_not_versioned <- get_obs_unit(
    tbl,
    config_tasks,
    config_target_data = config_target_data,
    target_type = "oracle-output",
    include_as_of = TRUE
  )
  expect_equal(obs_unit_not_versioned, obs_unit)
  expect_false("as_of" %in% obs_unit_not_versioned)

  # Modify config to make oracle-output versioned
  config_target_data$`oracle-output`$versioned <- TRUE

  # With include_as_of = TRUE and data IS versioned, should include as_of
  obs_unit_versioned <- get_obs_unit(
    tbl,
    config_tasks,
    config_target_data = config_target_data,
    target_type = "oracle-output",
    include_as_of = TRUE
  )
  expect_setequal(
    obs_unit_versioned,
    c("as_of", config_target_data$observable_unit)
  )

  # Modify config with oracle-output specific observable unit
  config_target_data$`oracle-output`$observable_unit <- c(
    config_target_data$observable_unit,
    "horizon"
  )

  obs_unit_horizon <- get_obs_unit(
    tbl,
    config_tasks,
    config_target_data = config_target_data,
    target_type = "oracle-output",
    include_as_of = TRUE
  )
})

test_that("get_obs_unit works with v6 time-series and config_target_data", {
  skip_if_not_installed("hubUtils", minimum_version = "0.1.0")

  hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  config_target_data <- hubUtils::read_config(hub_path, "target-data")
  tbl <- read_target_file("time-series.csv", hub_path)

  obs_unit <- get_obs_unit(
    tbl,
    config_tasks,
    config_target_data = config_target_data,
    target_type = "time-series",
    include_as_of = FALSE
  )
  expect_type(obs_unit, "character")
  expect_false("as_of" %in% obs_unit)
})

test_that("group_by_obs_unit works with v5 oracle-output", {
  hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- read_target_file("oracle-output.csv", hub_path)

  # Without as_of
  grouped <- group_by_obs_unit(tbl, config_tasks)
  expect_s3_class(grouped, "grouped_df")
  expect_setequal(
    dplyr::group_vars(grouped),
    c("location", "target_end_date", "target")
  )

  # With as_of
  tbl$as_of <- as.Date("2024-01-15")
  grouped_with_as_of <- group_by_obs_unit(tbl, config_tasks)
  expect_true("as_of" %in% dplyr::group_vars(grouped_with_as_of))
})

test_that("group_by_obs_unit works with v5 time-series", {
  hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- read_target_file("time-series.csv", hub_path)

  grouped <- group_by_obs_unit(tbl, config_tasks)
  expect_s3_class(grouped, "grouped_df")
  expect_setequal(
    dplyr::group_vars(grouped),
    c("target_end_date", "target", "location")
  )
})

test_that("group_by_obs_unit works with v6 and config_target_data", {
  skip_if_not_installed("hubUtils", minimum_version = "0.1.0")

  hub_path <- system.file("testhubs/v6/target_file", package = "hubUtils")
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  config_target_data <- hubUtils::read_config(hub_path, "target-data")
  tbl <- read_target_file("oracle-output.csv", hub_path)

  grouped <- group_by_obs_unit(
    tbl,
    config_tasks,
    config_target_data = config_target_data,
    target_type = "oracle-output",
    include_as_of = FALSE
  )
  expect_s3_class(grouped, "grouped_df")
  expect_false("as_of" %in% dplyr::group_vars(grouped))
})
