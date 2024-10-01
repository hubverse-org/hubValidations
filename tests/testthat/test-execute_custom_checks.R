test_that("execute_custom_checks works", {
  expect_snapshot(
    str(
      test_custom_checks_caller(
        validations_cfg_path = testthat::test_path(
          "testdata",
          "config",
          "validations.yml"
        )
      )
    )
  )

  expect_snapshot(
    str(
      test_custom_checks_caller(
        validations_cfg_path = testthat::test_path(
          "testdata",
          "config",
          "validations-error.yml"
        )
      )
    )
  )
})

test_that("execute_custom_checks sourcing functions from scripts works", {

  expect_snapshot(
    test_custom_checks_caller(
      validations_cfg_path = testthat::test_path(
        "testdata",
        "config",
        "validations-src.yml"
      )
    )
  )
})

test_that("execute_custom_checks return early when appropriate", {
  # When the first custom check returns an check_error class object, custom check
  # execution should return early
  early_ret_custom <- test_custom_checks_caller(
    validations_cfg_path = testthat::test_path(
      "testdata",
      "config",
      "validations-early-ret.yml"
    )
  )
  expect_snapshot(early_ret_custom)
  expect_length(early_ret_custom, 1L)
  expect_false("example_shouldnt_run" %in% names(early_ret_custom))


  # When the first custom check returns an check_failure class object, custom check
  # execution should proceed
  no_early_ret_custom <- test_custom_checks_caller(
    validations_cfg_path = testthat::test_path(
      "testdata",
      "config",
      "validations-no-early-ret.yml"
    )
  )
  expect_snapshot(no_early_ret_custom)
  expect_length(no_early_ret_custom, 2L)
  expect_true("example_should_run" %in% names(no_early_ret_custom))
})
