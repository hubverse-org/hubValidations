test_that("check_metadata_file_name works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  expect_s3_class(
    check_metadata_file_name(
      file_path = "hub-baseline.yml",
      hub_path = hub_path),
    c("check_success", "rlang_message", "message", "condition")
  )
  expect_snapshot(
    check_metadata_file_name(
      file_path = "hub-baseline.yml",
      hub_path = hub_path)
  )

  expect_s3_class(
    check_metadata_file_name(
      file_path = "hub-baseline-with-model_id.yml",
      hub_path = hub_path),
    c("check_success", "rlang_message", "message", "condition")
  )
  expect_snapshot(
    check_metadata_file_name(
      file_path = "hub-baseline-with-model_id.yml",
      hub_path = hub_path)
  )

  expect_s3_class(
    check_metadata_file_name(
      file_path = "hub-baseline-with-wrong-model_id.yml",
      hub_path = hub_path),
    c("check_error", "rlang_message", "message", "condition")
  )
  expect_snapshot(
    check_metadata_file_name(
      file_path = "hub-baseline-with-wrong-model_id.yml",
      hub_path = hub_path),
  )

  expect_s3_class(
    hubValidations:::check_metadata_file_name(
      file_path = "hub-baseline-no-abbrs-or-model_id.yml",
      hub_path = hub_path),
    c("check_error", "rlang_message", "message", "condition")
  )
  expect_snapshot(
    check_metadata_file_name(
      file_path = "hub-baseline-no-abbrs-or-model_id.yml",
      hub_path = hub_path)
  )

  expect_s3_class(
    check_metadata_file_name(
      file_path = "team1-goodmodel.yaml",
      hub_path = hub_path),
    c("check_success", "rlang_message", "message", "condition")
  )
  expect_snapshot(
    check_metadata_file_name(
      file_path = "team1-goodmodel.yaml",
      hub_path = hub_path)
  )
})
