test_that("validate_submission works", {
  skip_if_offline()

  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  # File that passes validation
  expect_snapshot(
    str(
      validate_submission(hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        skip_submit_window_check = TRUE,
        skip_check_config = TRUE
      )
    )
  )
  expect_s3_class(
    validate_submission(hub_path,
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      skip_submit_window_check = TRUE,
      skip_check_config = TRUE
    ),
    c("hub_validations", "list")
  )

  # File with validation error ----
  # Missing file
  expect_snapshot(
    str(
      validate_submission(hub_path,
        file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
        skip_submit_window_check = TRUE,
        skip_check_config = TRUE
      )
    )
  )
  expect_s3_class(
    validate_submission(hub_path,
      file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
      skip_submit_window_check = TRUE,
      skip_check_config = TRUE
    ),
    c("hub_validations", "list")
  )

  # Wrong submission location & missing data column (age_group)
  expect_snapshot(
    str(
      validate_submission(hub_path,
        file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv",
        skip_submit_window_check = TRUE,
        skip_check_config = TRUE
      )
    )
  )
  expect_s3_class(
    validate_submission(hub_path,
      file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv",
      skip_submit_window_check = TRUE,
      skip_check_config = TRUE
    ),
    c("hub_validations", "list")
  )


  expect_snapshot(
    str(
      validate_submission(
        hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        round_id_col = "random_col",
        skip_submit_window_check = TRUE,
        skip_check_config = TRUE
      )
    )
  )

  # File that passes validation & checks config
  expect_snapshot(
    str(
      validate_submission(hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        skip_submit_window_check = TRUE
      )
    )
  )
  expect_s3_class(
    validate_submission(hub_path,
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      skip_submit_window_check = TRUE
    ),
    c("hub_validations", "list")
  )
})

test_that("validate_submission submission within window works", {
  skip_if_offline()

  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  mockery::stub(
    check_submission_time,
    "Sys.time",
    lubridate::as_datetime("2022-10-08 18:01:00 EEST"),
    2
  )
  expect_snapshot(
    str(
      validate_submission(hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
      )[["submission_time"]]
    )
  )
})

test_that("validate_submission submission outside window fails correctly", {
  skip_if_offline()

  hub_path <- system.file("testhubs/simple", package = "hubValidations")

  mockery::stub(
    check_submission_time,
    "Sys.time",
    lubridate::as_datetime("2023-10-08 18:01:00 EEST"),
    2
  )
  expect_snapshot(
    str(
      validate_submission(hub_path,
        file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
      )[["submission_time"]]
    )
  )
})

test_that("validate_submission csv file read in and validated according to schema.", {
  skip_if_offline()

  expect_snapshot(
    str(
      validate_submission(
        hub_path = test_path("testdata/hub"),
        file_path = "hub-baseline/2023-04-24-hub-baseline.csv",
        skip_submit_window_check = TRUE
      )
    )
  )
})

test_that("validate_submission fails when csv cannot be parsed according to schema.", {
  skip_if_offline()

  expect_s3_class(
    validate_submission(
      hub_path = test_path("testdata/hub"),
      file_path = "hub-baseline/2023-05-01-hub-baseline.csv",
      skip_submit_window_check = TRUE
    )[["file_read"]],
    c("check_error", "hub_check", "rlang_error", "error", "condition")
  )
})

test_that("File containing task ID with all null properties validate correctly", {
  expect_snapshot(
    str(
      validate_submission(
        hub_path = test_path("testdata/hub-nul"),
        file_path = "team-model/2023-11-26-team-model.parquet",
        skip_submit_window_check = TRUE
      )
    )
  )
  expect_true(
    suppressMessages(
      check_for_errors(
        validate_submission(
          hub_path = test_path("testdata/hub-nul"),
          file_path = "team-model/2023-11-26-team-model.parquet",
          skip_submit_window_check = TRUE
        )
      )
    )
  )
  expect_snapshot(
    str(
      validate_submission(
        hub_path = test_path("testdata/hub-nul"),
        file_path = "team-model/2023-11-19-team-model.parquet",
        skip_submit_window_check = TRUE
      )
    )
  )
  expect_true(
    suppressMessages(
      check_for_errors(
        validate_submission(
          hub_path = test_path("testdata/hub-nul"),
          file_path = "team-model/2023-11-19-team-model.parquet",
          skip_submit_window_check = TRUE
        )
      )
    )
  )
})
