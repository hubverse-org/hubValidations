test_that("combine works", {
  expect_equal(
    combine(new_hub_validations(), new_hub_validations(), NULL),
    structure(list(), class = c("hub_validations", "list"))
  )

  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  hub_vals <- combine(
    new_hub_validations(),
    new_hub_validations(
      file_exists = check_file_exists(file_path, hub_path),
      file_name = check_file_name(file_path),
      NULL
    )
  )
  expect_s3_class(hub_vals, "hub_validations")
  expect_named(hub_vals, c("file_exists", "file_name"))

  hub_vals_null <- combine(
    new_hub_validations(file_exists = check_file_exists(file_path, hub_path)),
    new_hub_validations(
      file_name = check_file_name(file_path),
      NULL
    )
  )
  expect_s3_class(hub_vals_null, "hub_validations")
  expect_named(hub_vals_null, c("file_exists", "file_name"))
})

test_that("combine errors correctly", {
  expect_error(
    combine(new_hub_validations(), new_hub_validations(), a = 1),
    regexp = "All elements must be of class"
  )
})

test_that("combine preserves target_validations class", {
  expect_equal(
    combine(new_target_validations(), new_target_validations(), NULL),
    structure(
      list(),
      class = c("target_validations", "hub_validations", "list")
    )
  )
  hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
  file_path <- "time-series.csv"

  target_vals <- combine(
    new_target_validations(),
    new_target_validations(
      target_file_name = check_target_file_name(file_path),
      target_file_ext_valid = check_target_file_ext_valid(file_path),
      NULL
    )
  )
  expect_s3_class(target_vals, "target_validations")
  expect_named(target_vals, c("target_file_name", "target_file_ext_valid"))

  target_vals_null <- combine(
    new_target_validations(
      target_file_name = check_target_file_name(file_path)
    ),
    new_target_validations(
      target_file_ext_valid = check_target_file_ext_valid(file_path),
      NULL
    )
  )
  expect_s3_class(target_vals_null, "target_validations")
  expect_named(target_vals_null, c("target_file_name", "target_file_ext_valid"))
})

test_that("combine target_validations errors correctly", {
  expect_error(
    combine(new_target_validations(), new_target_validations(), a = 1),
    regexp = "All elements must be of class"
  )
})

# ---- combine.hub_validations_collection tests ----

test_that("combine collection returns single input as-is", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )
  collection <- new_hub_validations_collection(validations)

  result <- combine(collection)

  expect_s3_class(result, "hub_validations_collection")
  expect_equal(length(result), 1)
  expect_equal(names(result), file_path)
})

test_that("combine collection combines different files", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path_1 <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  file_path_2 <- "team1-goodmodel/2022-10-15-team1-goodmodel.csv"

  validations_1 <- new_hub_validations(
    file_exists = check_file_exists(file_path_1, hub_path)
  )
  validations_2 <- new_hub_validations(
    file_exists = check_file_exists(file_path_2, hub_path)
  )

  collection_1 <- new_hub_validations_collection(validations_1)
  collection_2 <- new_hub_validations_collection(validations_2)

  result <- combine(collection_1, collection_2)

  expect_s3_class(result, "hub_validations_collection")
  expect_equal(length(result), 2)
  expect_equal(names(result), c(file_path_1, file_path_2))
})

test_that("combine collection merges validations for same file", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations_1 <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )
  validations_2 <- new_hub_validations(
    file_name = check_file_name(file_path)
  )

  collection_1 <- new_hub_validations_collection(validations_1)
  collection_2 <- new_hub_validations_collection(validations_2)

  result <- combine(collection_1, collection_2)

  expect_s3_class(result, "hub_validations_collection")
  expect_equal(length(result), 1)
  expect_equal(names(result), file_path)
  # Both checks should be merged
  expect_equal(names(result[[file_path]]), c("file_exists", "file_name"))
})

test_that("combine collection ignores NULL inputs", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )
  collection <- new_hub_validations_collection(validations)

  result <- combine(collection, NULL, NULL)

  expect_s3_class(result, "hub_validations_collection")
  expect_equal(length(result), 1)
})

test_that("combine collection handles empty collections", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )
  valid_collection <- new_hub_validations_collection(validations)
  empty_collection <- new_hub_validations_collection()

  # Single empty returns as-is
  result_single <- combine(empty_collection)
  expect_s3_class(result_single, "hub_validations_collection")
  expect_equal(length(result_single), 0)

  # Empty + valid filters out empty
  result_mixed <- combine(empty_collection, valid_collection)
  expect_s3_class(result_mixed, "hub_validations_collection")
  expect_equal(length(result_mixed), 1)

  # All empty returns first
  result_all_empty <- combine(
    empty_collection,
    new_hub_validations_collection()
  )
  expect_s3_class(result_all_empty, "hub_validations_collection")
  expect_equal(length(result_all_empty), 0)
})

test_that("combine collection preserves target_validations_collection class", {
  file_path_1 <- "time-series.csv"
  file_path_2 <- "other-file.csv"

  validations_1 <- new_target_validations(
    target_file_name = check_target_file_name(file_path_1)
  )
  validations_2 <- new_target_validations(
    target_file_name = check_target_file_name(file_path_2)
  )

  collection_1 <- new_target_validations_collection(validations_1)
  collection_2 <- new_target_validations_collection(validations_2)

  result <- combine(collection_1, collection_2)

  expect_s3_class(result, "target_validations_collection")
  expect_s3_class(result, "hub_validations_collection")
  expect_equal(length(result), 2)
  expect_equal(names(result), c(file_path_1, file_path_2))
})

test_that("combine collection errors on mixed classes", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  hub_file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  target_file_path <- "time-series.csv"

  hub_validations <- new_hub_validations(
    file_exists = check_file_exists(hub_file_path, hub_path)
  )
  target_validations <- new_target_validations(
    target_file_name = check_target_file_name(target_file_path)
  )

  hub_collection <- new_hub_validations_collection(hub_validations)
  target_collection <- new_target_validations_collection(target_validations)

  expect_error(
    combine(hub_collection, target_collection),
    "All elements must be of class"
  )
})
