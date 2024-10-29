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
  tmp <- withr::local_tempdir()
  hub <- stand_up_custom_check_hub(new_path = tmp)

  expect_no_error({
    withr::with_tempdir({
      res <- test_custom_checks_caller(hub_path = hub)
    })
  })

  expect_snapshot(print(res))
})


test_that("execute_custom_checks return early when appropriate", {
  # When the first custom check returns an check_error class object, custom check
  # execution should return early
  tmp1 <- withr::local_tempdir()
  the_check <- testthat::test_path("testdata/src/R/src_simple_example_check.R")
  hub1 <- stand_up_custom_check_hub(new_path = tmp1,
    check_path = the_check,
    args = list(
      simple_example_check = list(check = FALSE, error = TRUE),
      simple_example_check = list(check = TRUE, error = FALSE)
    )
  )
  early_ret_custom <- test_custom_checks_caller(hub_path = hub1)
  expect_snapshot(early_ret_custom)
  expect_length(early_ret_custom, 1L)
  expect_false("check_2" %in% names(early_ret_custom))

  # Same when the first custom check returns an exec_error class object
  tmp2 <- withr::local_tempdir()
  hub2 <- stand_up_custom_check_hub(new_path = tmp2,
    check_path = the_check,
    args = list(
      simple_example_check = list(check = FALSE, error = TRUE, exec_error = TRUE),
      simple_example_check = list(check = TRUE, error = FALSE)
    )
  )
  early_ret_exec_error <- test_custom_checks_caller(hub2)
  expect_snapshot(early_ret_exec_error)
  expect_length(early_ret_exec_error, 1L)
  expect_false("check_2" %in% names(early_ret_custom))


  # When the first custom check returns an check_failure class object, custom check
  # execution should proceed
  tmp3 <- withr::local_tempdir()
  hub3 <- stand_up_custom_check_hub(new_path = tmp3,
    check_path = the_check,
    args = list(
      simple_example_check = list(check = FALSE, error = FALSE),
      simple_example_check = list(check = TRUE, error = FALSE)
    )
  )
  no_early_ret_custom <- test_custom_checks_caller(hub3)
  expect_snapshot(no_early_ret_custom)
  expect_length(no_early_ret_custom, 2L)
  expect_true("check_2" %in% names(no_early_ret_custom))
})
