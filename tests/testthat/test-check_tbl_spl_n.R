test_that("check_tbl_spl_n works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_spl_n(tbl, round_id, file_path, hub_path)
  )

  tbl_error <- tbl[-which(
    tbl$output_type == "sample" & tbl$output_type_id %in% c("1", "102")
  ), ]

  expect_snapshot(
    check_tbl_spl_n(tbl_error, round_id, file_path, hub_path)
  )
  error_check <- check_tbl_spl_n(
    tbl_error, round_id, file_path, hub_path
  )

  expect_snapshot(error_check$errors)

  # Ensure other checks pass
  expect_s3_class(
    check_tbl_spl_non_compound_tid(tbl_error, round_id, file_path, hub_path),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )
  expect_s3_class(
    check_tbl_spl_compound_tid(tbl_error, round_id, file_path, hub_path),
    c("check_success", "hub_check", "rlang_message", "message", "condition")
  )
})
