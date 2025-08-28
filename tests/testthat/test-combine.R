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
    regexp = "All elements must inherit from class"
  )
})

test_that("combine.target_validations works", {
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

test_that("combine.target_validations errors correctly", {
  expect_error(
    combine(new_target_validations(), new_target_validations(), a = 1),
    regexp = "All elements must inherit from class"
  )
})
