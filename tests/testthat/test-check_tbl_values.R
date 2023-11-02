test_that("check_tbl_values works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  round_id <- "2022-10-08"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_snapshot(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )

  tbl[1, "horizon"] <- 11L
  expect_snapshot(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )
})


test_that("check_tbl_values consistent across numeric & character output type id columns & ignores trailing zeros", {

  # Hub with both character & numeric output type ids & trailing zeros in
  # numeric output type id
  hub_path <- test_path("testdata/hub-chr")
  # File with both character & numeric output type ids.
  file_path <- "UMass-gbq/2023-10-28-UMass-gbq.csv"
  round_id <- "2023-10-28"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )

  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )


  file_path <- "UMass-gbq/2023-11-04-UMass-gbq.csv"
  # File with only numeric output type ids.
  round_id <- "2023-11-04"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )

  file_path <- "UMass-gbq/2023-11-11-UMass-gbq.csv"
  # File with only numeric output type ids.
  round_id <- "2023-11-11"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition")
  )

  # Hub with only numeric output type ids
  hub_path <- test_path("testdata/hub-num")
  # File with only numeric output type ids.
  file_path <- "UMass-gbq/2023-11-04-UMass-gbq.csv"
  round_id <- "2023-11-04"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )

  hub_path <- test_path("testdata/hub-num")
  # File with only numeric output type ids.
  file_path <- "UMass-gbq/2023-11-11-UMass-gbq.csv"
  round_id <- "2023-11-11"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )
  expect_s3_class(
    check_tbl_values(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition")
  )
})
