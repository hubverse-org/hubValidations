test_that("hub_validations subsetting with [ preserves class and where", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  where <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(where, hub_path),
    file_name = check_file_name(where)
  )

  # Positive indexing preserves class and correct element
  subset_pos <- validations[1]
  expect_s3_class(subset_pos, "hub_validations")
  expect_equal(attr(subset_pos, "where"), where)
  expect_equal(length(subset_pos), 1)
  expect_equal(names(subset_pos), "file_exists")

  # Negative indexing preserves class and correct element
  subset_neg <- validations[-1]
  expect_s3_class(subset_neg, "hub_validations")
  expect_equal(attr(subset_neg, "where"), where)
  expect_equal(length(subset_neg), 1)
  expect_equal(names(subset_neg), "file_name")

  # Subsetting by name preserves class
  subset_named <- validations["file_exists"]
  expect_s3_class(subset_named, "hub_validations")
  expect_equal(attr(subset_named, "where"), where)
  expect_equal(names(subset_named), "file_exists")

  # Empty subset has NULL where
  empty_subset <- validations[integer(0)]
  expect_s3_class(empty_subset, "hub_validations")
  expect_null(attr(empty_subset, "where"))
  expect_equal(length(empty_subset), 0)

  # Negative indexing to empty also has NULL where
  empty_neg <- validations[-(1:2)]
  expect_s3_class(empty_neg, "hub_validations")
  expect_null(attr(empty_neg, "where"))
  expect_equal(length(empty_neg), 0)
})

test_that("hub_validations [[ returns hub_check not hub_validations", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  where <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(where, hub_path),
    file_name = check_file_name(where)
  )

  # [[ returns the raw hub_check object
  check <- validations[[1]]
  expect_s3_class(check, "hub_check")
  expect_false(inherits(check, "hub_validations"))

  # Same for named access
  check_named <- validations[["file_exists"]]
  expect_s3_class(check_named, "hub_check")
})

test_that("hub_validations $<- assignment validates and maintains where", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  where <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  # Assignment to empty object sets where
  validations <- new_hub_validations()
  expect_null(attr(validations, "where"))

  validations$file_exists <- check_file_exists(where, hub_path)
  expect_equal(attr(validations, "where"), where)
  expect_equal(names(validations), "file_exists")

  # Assignment of check with same where works
  validations$file_name <- check_file_name(where)
  expect_equal(length(validations), 2)
  expect_equal(names(validations), c("file_exists", "file_name"))

  # Assignment of check with different where errors
  different_file <- "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
  expect_error(
    validations$other_check <- check_file_name(different_file),
    "Cannot add check with different.*where.*value"
  )

  # Only hub_check objects can be assigned
  expect_error(
    validations$bad <- "not a check",
    "Can only assign.*hub_check"
  )

  expect_error(
    validations$bad <- list(a = 1),
    "Can only assign.*hub_check"
  )
})

test_that("hub_validations $<- NULL assignment removes elements", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  where <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations(
    file_exists = check_file_exists(where, hub_path),
    file_name = check_file_name(where)
  )

  # NULL assignment removes element
  validations$file_name <- NULL
  expect_equal(length(validations), 1)
  expect_equal(names(validations), "file_exists")
  expect_null(validations$file_name)
  expect_equal(attr(validations, "where"), where)

  # Removing all elements resets where to NULL
  validations$file_exists <- NULL
  expect_equal(length(validations), 0)
  expect_null(attr(validations, "where"))
})

test_that("hub_validations [[<- assignment works like $<-", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  where <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  validations <- new_hub_validations()

  # Assignment sets where
  validations[["file_exists"]] <- check_file_exists(where, hub_path)
  expect_equal(attr(validations, "where"), where)
  expect_equal(names(validations), "file_exists")

  # Different where errors
  different_file <- "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
  expect_error(
    validations[["other"]] <- check_file_name(different_file),
    "Cannot add check with different.*where.*value"
  )

  # Non hub_check errors
  expect_error(
    validations[["bad"]] <- list(a = 1),
    "Can only assign.*hub_check"
  )

  # NULL removal works
  validations[["file_exists"]] <- NULL
  expect_equal(length(validations), 0)
  expect_null(attr(validations, "where"))
})

test_that("hub_validations methods preserve subclass (target_validations)", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  where <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  # Create a target_validations object
  validations <- new_target_validations(
    file_exists = check_file_exists(where, hub_path),
    file_name = check_file_name(where)
  )

  expect_s3_class(validations, "target_validations")
  expect_s3_class(validations, "hub_validations")

  # Subsetting preserves target_validations class
  subset <- validations[1]
  expect_s3_class(subset, "target_validations")
  expect_s3_class(subset, "hub_validations")
  expect_equal(names(subset), "file_exists")

  # Assignment preserves target_validations class
  validations$new_check <- check_file_name(where)
  expect_s3_class(validations, "target_validations")
  expect_s3_class(validations, "hub_validations")
  expect_equal(names(validations), c("file_exists", "file_name", "new_check"))
})
