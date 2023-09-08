test_that("execute_custom_checks works", {
  test_custom_checks_caller <- function(hub_path = system.file("testhubs/flusight", package = "hubValidations"),
                                        file_path = "hub-ensemble/2023-05-08-hub-ensemble.parquet",
                                        validations_cfg_path = NULL) {
    tbl <- read_model_out_file(
      file_path = file_path,
      hub_path = hub_path
    )

    custom_checks <- execute_custom_checks(validations_cfg_path = validations_cfg_path)
    class(custom_checks) <- c("hub_validations", "list")
    custom_checks
  }

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
})
