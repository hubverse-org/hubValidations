test_that("check_config_hub_valid works", {
  skip_if_offline()
  expect_snapshot(
    check_config_hub_valid(
      hub_path = system.file("testhubs/simple", package = "hubValidations")
    )
  )

  expect_snapshot(
    check_config_hub_valid(
      hub_path = system.file("testhubs/flusight", package = "hubValidations")
    )
  )

  mockery::stub(
    check_config_hub_valid,
    "hubAdmin::validate_hub_config",
    list(
      admin = TRUE,
      tasks = FALSE
    ),
    2
  )
  expect_snapshot(
    check_config_hub_valid(
      hub_path = system.file("testhubs/flusight", package = "hubValidations")
    )
  )
})
