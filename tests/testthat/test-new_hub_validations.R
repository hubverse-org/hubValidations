test_that("new_hub_validations works", {
  expect_snapshot(str(new_hub_validations()))
  expect_s3_class(
    new_hub_validations(),
    c("hub_validations")
  )

  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  expect_snapshot(
    str(
      new_hub_validations(
        file_exists = check_file_exists(file_path, hub_path),
        file_name = check_file_name(file_path)
      )
    )
  )

  expect_s3_class(
    new_hub_validations(
      file_exists = check_file_exists(file_path, hub_path),
      file_name = check_file_name(file_path)
    ),
    c("hub_validations")
  )
})

# ---- hub_validations_collection tests ----

test_that("new_hub_validations_collection creates empty collection", {
  collection <- new_hub_validations_collection()

  expect_s3_class(collection, "hub_validations_collection")
  expect_s3_class(collection, "list")
  expect_equal(length(collection), 0)
  expect_null(names(collection))
})

test_that("new_hub_validations_collection creates collection from single element", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path),
    file_name = check_file_name(file_path)
  )

  collection <- new_hub_validations_collection(validations)

  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
  expect_s3_class(collection[[1]], "hub_validations")
})

test_that("new_hub_validations_collection creates collection from multiple elements", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path_1 <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  file_path_2 <- "team1-goodmodel/2022-10-15-team1-goodmodel.csv"

  validations_1 <- new_hub_validations(
    file_exists = check_file_exists(file_path_1, hub_path),
    file_name = check_file_name(file_path_1)
  )
  validations_2 <- new_hub_validations(
    file_exists = check_file_exists(file_path_2, hub_path),
    file_name = check_file_name(file_path_2)
  )

  collection <- new_hub_validations_collection(validations_1, validations_2)

  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 2)
  expect_equal(names(collection), c(file_path_1, file_path_2))
  expect_s3_class(collection[[1]], "hub_validations")
  expect_s3_class(collection[[2]], "hub_validations")
})

test_that("new_hub_validations_collection ignores NULL elements", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )

  collection <- new_hub_validations_collection(validations, NULL, NULL)

  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
})

test_that("new_hub_validations_collection errors on non-hub_validations input", {
  expect_error(
    new_hub_validations_collection(list(a = 1)),
    "hub_validations"
  )

  expect_error(
    new_hub_validations_collection("not a validation"),
    "hub_validations"
  )
})

test_that("as_hub_validations_collection converts list to collection", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path_1 <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  file_path_2 <- "team1-goodmodel/2022-10-15-team1-goodmodel.csv"

  validations_1 <- new_hub_validations(
    file_exists = check_file_exists(file_path_1, hub_path)
  )
  validations_2 <- new_hub_validations(
    file_exists = check_file_exists(file_path_2, hub_path)
  )

  x <- list(validations_1, validations_2)
  collection <- as_hub_validations_collection(x)

  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 2)
  expect_equal(names(collection), c(file_path_1, file_path_2))
})

test_that("as_hub_validations_collection errors on non-list input", {
  expect_error(
    as_hub_validations_collection("not a list"),
    "must inherit from class.*list"
  )

  expect_error(
    as_hub_validations_collection(42),
    "must inherit from class.*list"
  )
})

test_that("as_hub_validations_collection errors when list contains non-hub_validations", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )

  # List with valid hub_validations and invalid element
  x <- list(validations, list(a = 1))
  expect_error(
    as_hub_validations_collection(x),
    "hub_validations"
  )

  # List with only invalid elements
  x <- list("not a validation", 42)
  expect_error(
    as_hub_validations_collection(x),
    "hub_validations"
  )
})

test_that("as_hub_validations_collection ignores NULL elements", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )

  x <- list(validations, NULL, NULL)
  collection <- as_hub_validations_collection(x)

  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
})

test_that("collection filters out empty hub_validations objects", {
  # Empty hub_validations objects are filtered by purrr::compact()
  # since they are zero-length lists
  empty_validations <- new_hub_validations()

  collection <- new_hub_validations_collection(empty_validations)
  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 0)

  # Multiple empties also result in empty collection
  collection <- new_hub_validations_collection(
    empty_validations,
    new_hub_validations()
  )
  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 0)

  # But if mixed with valid ones, valid are kept
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  valid_validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )

  collection <- new_hub_validations_collection(
    empty_validations,
    valid_validations
  )
  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
})

test_that("as_hub_validations_collection filters out empty hub_validations objects", {
  empty_validations <- new_hub_validations()

  # All empties result in empty collection
  collection <- as_hub_validations_collection(list(
    empty_validations,
    new_hub_validations()
  ))
  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 0)

  # Mixed with valid keeps valid
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  valid_validations <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )

  collection <- as_hub_validations_collection(list(
    empty_validations,
    valid_validations
  ))
  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
})

test_that("new_hub_validations_collection merges validations for same file", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations_1 <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )
  validations_2 <- new_hub_validations(
    file_name = check_file_name(file_path)
  )

  # Two validations for the same file should be merged

  collection <- new_hub_validations_collection(validations_1, validations_2)

  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
  expect_equal(names(collection[[file_path]]), c("file_exists", "file_name"))
})

test_that("as_hub_validations_collection merges validations for same file", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations_1 <- new_hub_validations(
    file_exists = check_file_exists(file_path, hub_path)
  )
  validations_2 <- new_hub_validations(
    file_name = check_file_name(file_path)
  )

  x <- list(validations_1, validations_2)
  collection <- as_hub_validations_collection(x)

  expect_s3_class(collection, "hub_validations_collection")
  expect_equal(length(collection), 1)
  expect_equal(names(collection), file_path)
  expect_equal(names(collection[[file_path]]), c("file_exists", "file_name"))
})
