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


test_that("bad configs throw the correct errors", {
  missing_cfg <- testthat::test_path("testdata", "config", "does-not-exist.yml")
  expect_error(
    test_custom_checks_caller(validations_cfg_path = missing_cfg),
    class = "custom_validation_yml_missing"
  )

  malformed_cfg <- testthat::test_path(
    "testdata",
    "config",
    "validations-bad-cfg.yml"
  )
  expect_error(
    test_custom_checks_caller(validations_cfg_path = malformed_cfg),
    class = "custom_validation_cfg_malformed"
  )
})


test_that("execute_custom_checks sourcing functions from scripts works", {
  tmp <- withr::local_tempdir()
  the_config <- testthat::test_path("testdata/config/validations-src.yml")

  hub <- stand_up_custom_check_hub(new_path = tmp, yaml_path = the_config)

  expect_no_error({
    withr::with_tempdir({
      validations_src_external <- test_custom_checks_caller(hub_path = hub)
    })
  })

  expect_snapshot(validations_src_external)
})


test_that("execute_custom_checks return early when appropriate", {
  # When the first custom check returns an check_error class object, custom check
  # execution should return early
  tmp1 <- withr::local_tempdir()
  hub1 <- stand_up_custom_check_hub(
    new_path = tmp1,
    yaml_path = testthat::test_path("testdata/config/validations-early-ret.yml")
  )
  early_ret_custom <- test_custom_checks_caller(hub_path = hub1)
  expect_snapshot(early_ret_custom)
  expect_length(early_ret_custom, 1L)
  expect_false("check_2" %in% names(early_ret_custom))

  # Same when the first custom check returns an exec_error class object
  tmp2 <- withr::local_tempdir()
  hub2 <- stand_up_custom_check_hub(
    new_path = tmp2,
    yaml_path = testthat::test_path(
      "testdata/config/validations-exec-error.yml"
    )
  )
  early_ret_exec_error <- test_custom_checks_caller(hub2)
  expect_snapshot(early_ret_exec_error)
  expect_length(early_ret_exec_error, 1L)
  expect_false("check_2" %in% names(early_ret_custom))

  # When the first custom check returns an check_failure class object, custom check
  # execution should proceed
  tmp3 <- withr::local_tempdir()
  hub3 <- stand_up_custom_check_hub(
    new_path = tmp3,
    yaml_path = testthat::test_path(
      "testdata/config/validations-no-early-ret.yml"
    )
  )
  no_early_ret_custom <- test_custom_checks_caller(hub3)
  expect_snapshot(no_early_ret_custom)
  expect_length(no_early_ret_custom, 2L)
  expect_true("check_2" %in% names(no_early_ret_custom))
})
