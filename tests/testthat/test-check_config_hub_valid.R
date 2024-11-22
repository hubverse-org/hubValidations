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
  local_mocked_bindings(
    validate_hub_config = function(...) {
      list(
        admin = TRUE,
        tasks = FALSE
      )
    }
  )
  expect_snapshot(
    check_config_hub_valid(
      hub_path = system.file("testhubs/flusight", package = "hubValidations")
    )
  )
})
