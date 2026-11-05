test_that("check_tbl_spl_n works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  # Check succeeds when samples are in range and consistent across all
  # compound_idx
  expect_snapshot(
    check_tbl_spl_n(tbl, round_id, file_path, hub_path)
  )

  # Check failure when sample n not consistent across compound_idx outside ----
  tbl_const_error <- tbl[
    -which(
      tbl$output_type == "sample" & tbl$output_type_id %in% c("1", "102")
    ),
  ]

  expect_snapshot(
    check_tbl_spl_n(tbl_const_error, round_id, file_path, hub_path)
  )

  const_error_check <- check_tbl_spl_n(
    tbl_const_error,
    round_id,
    file_path,
    hub_path
  )

  expect_snapshot(const_error_check$errors)

  # Ensure other checks pass
  expect_s3_class(
    check_tbl_spl_non_compound_tid(
      tbl_const_error,
      round_id,
      file_path,
      hub_path
    ),
    c("check_success")
  )
  expect_s3_class(
    check_tbl_spl_compound_tid(
      tbl_const_error,
      round_id,
      file_path,
      hub_path
    ),
    c("check_success")
  )

  # Check failure when all compound_idx outside range ----
  tbl_min_error <- tbl[
    -which(
      tbl$output_type == "sample" &
        tbl$output_type_id %in%
          c(
            "1",
            "102",
            "201",
            "301",
            "5201"
          )
    ),
  ]

  expect_snapshot(
    check_tbl_spl_n(tbl_min_error, round_id, file_path, hub_path)
  )

  min_error_check <- check_tbl_spl_n(
    tbl_min_error,
    round_id,
    file_path,
    hub_path
  )

  expect_snapshot(min_error_check$errors)
})


test_that("Overriding compound_taskid_set in check_tbl_spl_n works", {
  hub_path <- test_path("testdata/hub-spl")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  config_task <- read_config_file(
    fs::path(hub_path, "hub-config", "tasks.json")
  )
  compound_taskid_set <- list(
    NULL,
    c("reference_date", "horizon")
  )
  tbl_coarse <- create_spl_file(
    "2022-10-22",
    compound_taskid_set = compound_taskid_set,
    write = FALSE,
    out_datatype = "chr",
    n_samples = 1L
  )

  # Validation of coarser files should return check failure. Each coarser
  # sample counts towards every configured compound_idx it covers, so every
  # compound_idx has one sample, short of the minimum.
  res <- check_tbl_spl_n(tbl_coarse, round_id, file_path, hub_path)
  expect_snapshot(res)
  expect_check(res, failure_class, file_path, "check_tbl_spl_n")
  # fmt: skip
  compound_idx <- c(
    "1", "5", "9", "13", "17", "21", "25", "29", "33", "37", "41", "45", "49",
    "53", "57", "61", "65", "69", "73", "77", "82", "86", "90", "94", "98",
    "102", "106", "110", "114", "118", "122", "126", "130", "134", "138",
    "142", "146", "150", "154", "158", "163", "167", "171", "175", "179",
    "183", "187", "191", "195", "199", "203", "207", "211", "215", "219",
    "223", "227", "231", "235", "239", "244", "248", "252", "256", "260",
    "264", "268", "272", "276", "280", "284", "288", "292", "296", "300",
    "304", "308", "312", "316", "320"
  )
  expect_named(res$errors, compound_idx)
  expect_equal(
    unname(purrr::map_chr(res$errors, "compound_idx")),
    compound_idx
  )
  expect_equal(
    unique(purrr::map(res$errors, names)),
    list(c(
      "compound_idx",
      "n",
      "min_samples_per_task",
      "max_samples_per_task",
      "compound_idx_tbl"
    ))
  )
  expect_equal(unique(purrr::map_int(res$errors, "n")), 1L)
  expect_equal(unique(purrr::map_int(res$errors, "min_samples_per_task")), 9L)
  expect_equal(unique(purrr::map_int(res$errors, "max_samples_per_task")), 10L)
  expect_equal(
    res$errors[["1"]]$compound_idx_tbl,
    tibble::tibble(
      reference_date = "2022-10-22",
      target = "wk inc flu hosp",
      horizon = "0",
      location = "US",
      variant = "AA",
      target_end_date = "2022-10-22"
    )
  )
  compound_idx_tbl <- purrr::map_dfr(res$errors, "compound_idx_tbl")
  expect_tbl(
    compound_idx_tbl,
    n_rows = 80L,
    types = c(
      reference_date = "character",
      target = "character",
      horizon = "character",
      location = "character",
      variant = "character",
      target_end_date = "character"
    ),
    values = list(
      reference_date = "2022-10-22",
      target = "wk inc flu hosp",
      location = c("01", "02", "04", "05", "US"),
      variant = c("AA", "BB", "CC", "DD")
    ),
    counts = tibble::tibble(
      horizon = c("0", "1", "2", "3"),
      target_end_date = c(
        "2022-10-22",
        "2022-10-29",
        "2022-11-05",
        "2022-11-12"
      ),
      n = 20L
    )
  )

  # Validation providing coarser compound taskid still fails because the coarser
  # structure means the same rows are spread across fewer samples. But the
  # compound_idx values are as expected because the compound_taskid_set matches
  # that used to generate the data.
  expect_snapshot(
    check_tbl_spl_n(
      tbl_coarse,
      round_id,
      file_path,
      hub_path,
      compound_taskid_set = compound_taskid_set
    )
  )

  # Create 100 spls of each compound idx
  tbl_full <- create_spl_file(
    "2022-10-22",
    compound_taskid_set = compound_taskid_set,
    write = FALSE,
    out_datatype = "chr"
  )

  # This succeeds!
  expect_snapshot(
    check_tbl_spl_n(
      tbl_full,
      round_id,
      file_path,
      hub_path,
      compound_taskid_set = compound_taskid_set
    )
  )

  # If we remove one sample, the check will fail because of an inconsistent
  # number of samples per compound_idx (Most will have 100 but one will only
  # have 99)
  tbl_minus_1 <- tbl_full[
    -which(
      tbl_full$output_type_id == "1"
    ),
  ]
  expect_snapshot(
    check_tbl_spl_n(
      tbl_minus_1,
      round_id,
      file_path,
      hub_path,
      compound_taskid_set = compound_taskid_set
    )
  )
})


test_that("Ignoring derived_task_ids in check_tbl_spl_n works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- tbl_orig <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  # Introduce invalid value to derived task id that should be ignored when using
  # `derived_task_ids`.
  tbl[1, "target_end_date"] <- "random_date"
  expect_snapshot(
    check_tbl_spl_n(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  # Check that ignoring derived task ids returns same result as not ignoring.
  expect_equal(
    check_tbl_spl_n(
      tbl,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    ),
    check_tbl_spl_n(
      tbl_orig,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
})
