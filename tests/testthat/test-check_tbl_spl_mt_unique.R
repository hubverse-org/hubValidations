test_that("check_tbl_spl_mt_unique works with valid single-MT samples", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  expect_snapshot(
    check_tbl_spl_mt_unique(tbl, round_id, file_path, hub_path)
  )
})

test_that("check_tbl_spl_mt_unique detects samples spanning model tasks", {
  hub_path <- test_path("testdata/hub-spl-multi-mt")
  file_path <- "team-model/2022-10-22-team-model.csv"
  round_id <- "2022-10-22"

  # Read the valid file
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  # Valid case: sample IDs are unique per model task
  expect_snapshot(
    check_tbl_spl_mt_unique(tbl, round_id, file_path, hub_path)
  )
  expect_s3_class(
    check_tbl_spl_mt_unique(tbl, round_id, file_path, hub_path),
    "check_success"
  )

  # Invalid case: share sample IDs across model tasks
  tbl_error <- tbl
  tbl_error$output_type_id[tbl_error$target == "ed_visits"] <-
    tbl$output_type_id[tbl$target == "hosp"]

  expect_snapshot(
    check_tbl_spl_mt_unique(tbl_error, round_id, file_path, hub_path)
  )

  error_check <- check_tbl_spl_mt_unique(
    tbl_error,
    round_id,
    file_path,
    hub_path
  )
  expect_s3_class(error_check, "check_error")
  expect_true(length(error_check$errors$output_type_ids) > 0)
  expect_equal(error_check$errors$mt_ids, c(1L, 2L))
})

test_that("check_tbl_spl_mt_unique skips when no v3 samples present", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  # Remove all sample rows
  tbl_no_spl <- tbl[tbl$output_type != "sample", ]

  expect_snapshot(
    check_tbl_spl_mt_unique(tbl_no_spl, round_id, file_path, hub_path)
  )
  expect_s3_class(
    check_tbl_spl_mt_unique(tbl_no_spl, round_id, file_path, hub_path),
    "check_info"
  )
})
