test_that("check_metadata_matches_schema works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  expect_s3_class(
    check_metadata_matches_schema(
      file_path = "hub-baseline.yml",
      hub_path = hub_path
    ),
    c("check_success")
  )
  expect_snapshot(
    check_metadata_matches_schema(
      file_path = "hub-baseline.yml",
      hub_path = hub_path
    )
  )

  expect_s3_class(
    check_metadata_matches_schema(
      file_path = "team1-goodmodel.yaml",
      hub_path = hub_path
    ),
    c("check_error")
  )
  expect_snapshot(
    check_metadata_matches_schema(
      file_path = "team1-goodmodel.yaml",
      hub_path = hub_path
    )
  )
})

test_that("check_metadata_matches_schema properly distinguishes length-1 arrays from scalars", {
  hub_path <- system.file("testhubs/array_hub", package = "hubValidations")

  run_check <- function(file_path, expected_result, expected_message_regex) {
    result <- check_metadata_matches_schema(
      file_path = file_path,
      hub_path = hub_path
    )

    expect_s3_class(result, expected_result)
    expect_match(result$message, expected_message_regex)
  }

  # multi-entry array passes
  run_check("multi-entry.yml", "check_success", "consistent with")

  # length-1 array passes
  run_check("single-entry.yml", "check_success", "consistent with")

  # correct length one optional array passes
  run_check("two-arrays.yml", "check_success", "consistent with")

  # missing mandatory array field errors
  run_check(
    "no-entry.yml",
    "check_error",
    "mandatory_array_valued_metadata must be array"
  )

  # string in an array field errors, even if optional field
  run_check(
    "string-instead-of-array.yml",
    "check_error",
    "optional_array_valued_metadata must be array"
  )

  # length-1 array in string field errors, even if optional field
  run_check(
    "array-instead-of-string.yml",
    "check_error",
    "website_url must be string"
  )
})
