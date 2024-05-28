test_that("check_tbl_spl_compound_tid works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "Flusight-baseline/2022-10-22-Flusight-baseline.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_spl_compound_tid(tbl, round_id, file_path, hub_path)
  )

  tbl_error <- tbl
  tbl_error[
    which(tbl$output_type == "sample" & tbl$output_type_id == "1")[1],
    "location"
  ] <- "02"

  expect_snapshot(
    check_tbl_spl_compound_tid(tbl_error, round_id, file_path, hub_path)
  )
  error_check <- check_tbl_spl_compound_tid(
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
