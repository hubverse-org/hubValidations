overlap_tbl <- function(hub_path, file_path) {
  # The config's `compound_taskid_set` is `reference_date` and `location`.
  # Samples 1 to 50 become joint across locations "01" and "02", and samples
  # 201 to 250 across locations "02" and "04". Both groups cover location "02".
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  spl_id <- suppressWarnings(as.integer(tbl$output_type_id))
  is_02 <- tbl$output_type == "sample" & tbl$location == "02"
  tbl$output_type_id[is_02 & spl_id <= 150L] <- as.character(
    spl_id[is_02 & spl_id <= 150L] - 100L
  )
  tbl$output_type_id[is_02 & spl_id > 150L] <- as.character(
    spl_id[is_02 & spl_id > 150L] + 50L
  )
  tbl
}

test_that("check_tbl_spl_overlap passes samples that do not overlap", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")

  expect_s3_class(
    check_tbl_spl_overlap(tbl, "2022-10-22", file_path, hub_path),
    "check_success"
  )
})

test_that("samples covering different but overlapping compound task ID values fail (#400)", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  tbl <- overlap_tbl(hub_path, file_path)

  result <- check_tbl_spl_overlap(tbl, "2022-10-22", file_path, hub_path)
  expect_s3_class(result, "check_error")
  expect_snapshot(result)
  expect_equal(
    sort(result$errors[["2"]]$output_type_ids),
    sort(as.character(c(1:100, 201:300)))
  )
  expect_named(
    result$errors[["2"]]$slices,
    c("output_type_id", "compound_idx", "reference_date", "location")
  )
})

test_that("validate_model_data skips the overlap check when overlapping samples are allowed (#400)", {
  hub_path <- withr::local_tempdir()
  fs::dir_copy(
    system.file("testhubs/samples", package = "hubValidations"),
    hub_path,
    overwrite = TRUE
  )
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  # Keeping only the overlapping samples gives every sample the compound task
  # ID set `reference_date`.
  tbl <- overlap_tbl(hub_path, file_path)
  tbl <- tbl[
    tbl$output_type != "sample" |
      tbl$output_type_id %in% as.character(c(1:50, 201:250)),
  ]
  utils::write.csv(
    tbl,
    fs::path(hub_path, "model-output", file_path),
    row.names = FALSE
  )

  checks <- validate_model_data(hub_path, file_path)
  expect_s3_class(checks$spl_overlap, "check_error")
  expect_false("spl_non_compound_tid" %in% names(checks))

  checks <- validate_model_data(
    hub_path,
    file_path,
    allow_overlapping_samples = TRUE
  )
  expect_s3_class(checks$spl_overlap, "check_info")
  expect_s3_class(checks$spl_compound_taskid_set, "check_success")
  expect_true("spl_n" %in% names(checks))
})

test_that("allow_overlapping_samples must be a single logical value", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"

  expect_error(
    validate_model_data(hub_path, file_path, allow_overlapping_samples = NA),
    "allow_overlapping_samples"
  )
})
