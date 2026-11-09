test_that("check_metadata_file_location works", {
  expect_check(
    check_metadata_file_location("hub-baseline.yml"),
    success_class,
    where = "hub-baseline.yml",
    call = "check_metadata_file_location"
  )
  expect_snapshot(
    check_metadata_file_location("hub-baseline.yml")
  )

  expect_check(
    check_metadata_file_location("random_folder/hub-baseline.yml"),
    failure_class,
    where = "random_folder/hub-baseline.yml",
    call = "check_metadata_file_location"
  )
  expect_snapshot(
    check_metadata_file_location("random_folder/hub-baseline.yml")
  )
})
