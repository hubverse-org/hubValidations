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
