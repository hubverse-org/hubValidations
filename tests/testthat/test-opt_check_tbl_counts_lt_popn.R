test_that("opt_check_tbl_counts_lt_popn works", {
  hub_path <- system.file("testhubs/flusight", package = "hubValidations")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  targets <- list("target" = "wk ahead inc flu hosp")

  expect_snapshot(
    opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets)
  )

  expect_equal(
    opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets),
    opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path)
  )

  tbl$value[1:2] <- 332200066L + 10L
  expect_snapshot(
    opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets)
  )
})

test_that("opt_check_tbl_counts_lt_popn fails correctly", {
  hub_path <- system.file("testhubs/flusight", package = "hubValidations")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  targets <- list("target" = "random target")

  expect_snapshot(
    opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets),
    error = TRUE
  )

  expect_snapshot(
    opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path,
      popn_file_path = "random/path.csv"
    ),
    error = TRUE
  )
  expect_snapshot(
    opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path,
      location_col = "random_col"
    ),
    error = TRUE
  )
  expect_snapshot(
    opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path,
      popn_col = "random_col"
    ),
    error = TRUE
  )
})

test_that("filter_targets works", {
  hub_path <- system.file("testhubs/flusight", package = "hubValidations")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  target <- list(target = "wk ahead inc flu hosp")
  # Test more complex target with two sets of target keys and target keys
  # comprised of multiple columns.
  targets <- list(
    list(
      target = c("wk ahead inc flu hosp", "extra target"),
      horizon = 1L
    ),
    list(
      target = c("wk ahead inc flu hosp", "extra target"),
      horizon = 2L
    )
  )

  expect_equal(nrow(filter_targets(tbl, target)), 46)
  expect_equal(nrow(filter_targets(tbl, targets)), 46)
  expect_equal(nrow(filter_targets(tbl, targets[[1]])), 23)
})
