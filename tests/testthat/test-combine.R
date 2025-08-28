test_that("combine works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  expect_snapshot(
    str(
      combine(new_hub_validations(), new_hub_validations(), NULL)
    )
  )

  expect_snapshot(
    str(combine(
      new_hub_validations(),
      new_hub_validations(
        file_exists = check_file_exists(file_path, hub_path),
        file_name = check_file_name(file_path),
        NULL
      )
    ))
  )

  expect_snapshot(
    str(combine(
      new_hub_validations(file_exists = check_file_exists(file_path, hub_path)),
      new_hub_validations(
        file_name = check_file_name(file_path),
        NULL
      )
    ))
  )
})

test_that("combine errors correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  expect_snapshot(
    combine(new_hub_validations(), new_hub_validations(), a = 1),
    error = TRUE
  )

  expect_snapshot(
    combine(
      new_hub_validations(
        file_exists = check_file_exists(file_path, hub_path),
        file_name = check_file_name(file_path),
        a = 10
      )
    ),
    error = TRUE
  )
})
test_that("combine.target_validations works", {
  hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
  file_path <- "time-series.csv"

  expect_snapshot(
    str(
      combine(new_target_validations(), new_target_validations(), NULL)
    )
  )

  expect_snapshot(
    str(combine(
      new_target_validations(),
      new_target_validations(
        target_file_name = check_target_file_name(file_path),
        target_file_ext_valid = check_target_file_ext_valid(file_path),
        NULL
      )
    ))
  )

  expect_snapshot(
    str(combine(
      new_target_validations(
        target_file_name = check_target_file_name(file_path)
      ),
      new_target_validations(
        target_file_ext_valid = check_target_file_ext_valid(file_path),
        NULL
      )
    ))
  )
})

test_that("combine.target_validations errors correctly", {
  file_path <- "time-series.csv"

  expect_snapshot(
    combine(new_target_validations(), new_target_validations(), a = 1),
    error = TRUE
  )
})

test_that("combine maintains correct class for target_validations", {
  file_path <- "time-series.csv"

  result <- combine(
    new_target_validations(
      target_file_name = check_target_file_name(file_path)
    ),
    new_target_validations(
      target_file_ext_valid = check_target_file_ext_valid(file_path)
    )
  )

  expect_s3_class(result, c("target_validations", "hub_validations"))
})
