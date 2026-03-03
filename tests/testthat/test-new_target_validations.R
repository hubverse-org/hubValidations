test_that("new_target_validations works", {
  expect_snapshot(str(new_target_validations()))
  expect_s3_class(
    new_target_validations(),
    c("target_validations", "hub_validations")
  )

  hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
  file_path <- "time-series.csv"

  expect_snapshot(
    str(
      new_target_validations(
        target_file_name = check_target_file_name(file_path),
        target_file_ext_valid = check_target_file_ext_valid(file_path)
      )
    )
  )

  expect_s3_class(
    new_target_validations(
      target_file_name = check_target_file_name(file_path),
      target_file_ext_valid = check_target_file_ext_valid(file_path)
    ),
    c("target_validations", "hub_validations")
  )
})

test_that("new_target_validations works with hive partitioned target files", {
  file_path <- "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"

  expect_snapshot(
    str(
      new_target_validations(
        target_file_name = check_target_file_name(file_path),
        target_file_ext_valid = check_target_file_ext_valid(file_path)
      )
    )
  )

  expect_s3_class(
    new_target_validations(
      target_file_name = check_target_file_name(file_path),
      target_file_ext_valid = check_target_file_ext_valid(file_path)
    ),
    c("target_validations", "hub_validations")
  )
})

# ---- target_validations_collection tests ----

test_that("new_target_validations_collection creates empty collection", {
  collection <- new_target_validations_collection()

  expect_s3_class(collection, "target_validations_collection")
  expect_s3_class(collection, "hub_validations_collection")
  expect_s3_class(collection, "list")
  expect_equal(length(collection), 0)
  expect_null(names(collection))
})

test_that("new_target_validations_collection creates collection from single element", {
  file_path <- "time-series.csv"

  validations <- new_target_validations(
    target_file_name = check_target_file_name(file_path),
    target_file_ext_valid = check_target_file_ext_valid(file_path)
  )

  collection <- new_target_validations_collection(validations)

  expect_s3_class(collection, "target_validations_collection")
  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
  expect_s3_class(collection[[1]], "target_validations")
})

test_that("new_target_validations_collection creates collection from multiple elements", {
  file_path_1 <- "time-series.csv"
  file_path_2 <- "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"

  validations_1 <- new_target_validations(
    target_file_name = check_target_file_name(file_path_1)
  )
  validations_2 <- new_target_validations(
    target_file_name = check_target_file_name(file_path_2)
  )

  collection <- new_target_validations_collection(validations_1, validations_2)

  expect_s3_class(collection, "target_validations_collection")
  expect_equal(length(collection), 2)
  expect_equal(names(collection), c(file_path_1, file_path_2))
  expect_s3_class(collection[[1]], "target_validations")
  expect_s3_class(collection[[2]], "target_validations")
})

test_that("new_target_validations_collection ignores NULL elements", {
  file_path <- "time-series.csv"

  validations <- new_target_validations(
    target_file_name = check_target_file_name(file_path)
  )

  collection <- new_target_validations_collection(validations, NULL, NULL)

  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
})

test_that("new_target_validations_collection errors on non-target_validations input", {
  # Plain hub_validations should not be accepted
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  hub_validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )

  expect_error(
    new_target_validations_collection(hub_validations),
    "target_validations"
  )

  expect_error(
    new_target_validations_collection(list(a = 1)),
    "target_validations"
  )

  expect_error(
    new_target_validations_collection("not a validation"),
    "target_validations"
  )
})

test_that("as_target_validations_collection converts list to collection", {
  file_path_1 <- "time-series.csv"
  file_path_2 <- "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet"

  validations_1 <- new_target_validations(
    target_file_name = check_target_file_name(file_path_1)
  )
  validations_2 <- new_target_validations(
    target_file_name = check_target_file_name(file_path_2)
  )

  x <- list(validations_1, validations_2)
  collection <- as_target_validations_collection(x)

  expect_s3_class(collection, "target_validations_collection")
  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 2)
  expect_equal(names(collection), c(file_path_1, file_path_2))
})

test_that("as_target_validations_collection errors on non-list input", {
  expect_error(
    as_target_validations_collection("not a list"),
    "must inherit from class.*list"
  )

  expect_error(
    as_target_validations_collection(42),
    "must inherit from class.*list"
  )
})

test_that("as_target_validations_collection errors when list contains non-target_validations", {
  file_path <- "time-series.csv"

  validations <- new_target_validations(
    target_file_name = check_target_file_name(file_path)
  )

  # List with valid target_validations and invalid element
  x <- list(validations, list(a = 1))
  expect_error(
    as_target_validations_collection(x),
    "target_validations"
  )

  # List with hub_validations (wrong type)
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  hub_file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  hub_validations <- new_hub_validations(
    file_exists = check_file_exists(hub_file_path, hub_path)
  )

  x <- list(validations, hub_validations)
  expect_error(
    as_target_validations_collection(x),
    "target_validations"
  )
})

test_that("as_target_validations_collection ignores NULL elements", {
  file_path <- "time-series.csv"

  validations <- new_target_validations(
    target_file_name = check_target_file_name(file_path)
  )

  x <- list(validations, NULL, NULL)
  collection <- as_target_validations_collection(x)

  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
})

test_that("target collection filters out empty target_validations objects", {
  # Empty target_validations objects are filtered by purrr::compact()
  # since they are zero-length lists
  empty_validations <- new_target_validations()

  collection <- new_target_validations_collection(empty_validations)
  expect_s3_class(collection, "target_validations_collection")
  expect_equal(length(collection), 0)

  # Multiple empties also result in empty collection
  collection <- new_target_validations_collection(
    empty_validations,
    new_target_validations()
  )
  expect_s3_class(collection, "target_validations_collection")
  expect_equal(length(collection), 0)

  # But if mixed with valid ones, valid are kept
  file_path <- "time-series.csv"
  valid_validations <- new_target_validations(
    target_file_name = check_target_file_name(file_path)
  )

  collection <- new_target_validations_collection(
    empty_validations,
    valid_validations
  )
  expect_s3_class(collection, "target_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
})

test_that("as_target_validations_collection filters out empty target_validations objects", {
  empty_validations <- new_target_validations()

  # All empties result in empty collection
  collection <- as_target_validations_collection(list(
    empty_validations,
    new_target_validations()
  ))
  expect_s3_class(collection, "target_validations_collection")
  expect_equal(length(collection), 0)

  # Mixed with valid keeps valid
  file_path <- "time-series.csv"
  valid_validations <- new_target_validations(
    target_file_name = check_target_file_name(file_path)
  )

  collection <- as_target_validations_collection(list(
    empty_validations,
    valid_validations
  ))
  expect_s3_class(collection, "target_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
})

test_that("new_target_validations_collection merges validations for same file", {
  file_path <- "time-series.csv"

  validations_1 <- new_target_validations(
    target_file_name = check_target_file_name(file_path)
  )
  validations_2 <- new_target_validations(
    target_file_ext_valid = check_target_file_ext_valid(file_path)
  )

  # Two validations for the same file should be merged
  collection <- new_target_validations_collection(validations_1, validations_2)

  expect_s3_class(collection, "target_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
  expect_equal(
    names(collection[[file_path]]),
    c("target_file_name", "target_file_ext_valid")
  )
})

test_that("as_target_validations_collection merges validations for same file", {
  file_path <- "time-series.csv"

  validations_1 <- new_target_validations(
    target_file_name = check_target_file_name(file_path)
  )
  validations_2 <- new_target_validations(
    target_file_ext_valid = check_target_file_ext_valid(file_path)
  )

  x <- list(validations_1, validations_2)
  collection <- as_target_validations_collection(x)

  expect_s3_class(collection, "target_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
  expect_equal(
    names(collection[[file_path]]),
    c("target_file_name", "target_file_ext_valid")
  )
})
