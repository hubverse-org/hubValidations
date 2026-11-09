test_that("get_tbl_compound_taskid_set works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  config_tasks <- read_config(hub_path, "tasks")

  expect_snapshot(
    get_tbl_compound_taskid_set(
      tbl,
      config_tasks,
      round_id,
      compact = TRUE,
      error = TRUE
    )
  )

  expect_snapshot(
    get_tbl_compound_taskid_set(
      tbl,
      config_tasks,
      round_id,
      compact = FALSE,
      error = TRUE
    )
  )
})

test_that("get_tbl_compound_taskid_set errors correctly", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl_error_dups <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  config_tasks <- read_config(hub_path, "tasks")

  tbl_error_dups[which(tbl_error_dups$output_type_id == "2"), "horizon"] <- "0"
  expect_snapshot(
    get_tbl_compound_taskid_set(
      tbl_error_dups,
      config_tasks,
      round_id,
      compact = TRUE,
      error = TRUE
    ),
    error = TRUE
  )

  expect_snapshot(
    get_tbl_compound_taskid_set(
      tbl_error_dups,
      config_tasks,
      round_id,
      compact = TRUE,
      error = FALSE
    )
  )
})

test_that("get_tbl_compound_taskid_set ignores task IDs of other rounds (#393)", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  # The config has a later round with a task ID, `scenario_id`, that the round
  # being validated, and so the submission, does not have.
  config_tasks <- read_config_file(
    test_path("testdata/configs/tasks-samples-extra-round.json")
  )

  expect_equal(
    get_tbl_compound_taskid_set(tbl, config_tasks, round_id),
    list("2" = c("reference_date", "location"))
  )
})

test_that("test get_tbl_compound_taskid_set utilities", {
  x <- structure(
    list(
      reference_date = TRUE,
      target = FALSE,
      horizon = FALSE,
      location = TRUE,
      target_end_date = FALSE
    ),
    class = c(
      "tbl_df",
      "tbl",
      "data.frame"
    ),
    row.names = c(NA, -1L)
  )

  expect_equal(
    true_to_names_vector(x, cols = "location"),
    list("location")
  )
})

test_that("errors name the invalid compound task IDs of each finer set and keep sets (#400)", {
  # Sample "1" holds one horizon, so it is finer by `horizon`. Sample "2" holds
  # one target, so it is finer by `target`.
  tbl_chr <- tibble::tibble(
    location = "a",
    horizon = c("1", "1", "1", "2"),
    target = c("x", "y", "x", "x"),
    output_type_id = c("1", "1", "2", "2")
  )
  membership <- spl_comp_tid_membership(
    tibble::tibble(
      mt_id = 1L,
      output_type_id = tbl_chr$output_type_id,
      row_idx = seq_len(nrow(tbl_chr))
    ),
    tbl_chr,
    config_comp_tids = "location",
    task_ids = c("location", "horizon", "target"),
    derived_task_ids = NULL
  )
  out <- get_mt_compound_taskid_set(
    membership$is_compound_taskid,
    membership$output_type_ids,
    config_comp_tids = "location",
    error = FALSE
  )
  errors <- attr(out, "errors")
  expect_equal(purrr::map(errors, "output_type_ids"), list("1", "2"))
  expect_equal(
    purrr::map(errors, "invalid_tbl_comp_tids"),
    list("horizon", "target")
  )
  expect_equal(
    purrr::map(attr(out, "sets"), "output_type_ids"),
    list("1", "2")
  )
})

test_that("a derived task ID is compound exactly when the config lists it (#401)", {
  # Modeling task 2 lists `target_end_date` in its `compound_taskid_set`.
  # Varying it within each sample does not drop it from the detected set.
  hub_path <- test_path("testdata/hub-spl")
  config_tasks <- read_config(hub_path, "tasks")
  tbl <- read_model_out_file(
    "flu-base/2022-10-22-flu-base.parquet",
    hub_path,
    coerce_types = "chr"
  )
  tbl$target_end_date <- as.character(seq_len(nrow(tbl)))
  expect_equal(
    get_tbl_compound_taskid_set(
      tbl,
      config_tasks,
      "2022-10-22",
      derived_task_ids = "target_end_date"
    )[["2"]],
    c("reference_date", "horizon", "location", "variant", "target_end_date")
  )

  # Modeling task 2 does not list `target_end_date`. Holding one value of it
  # per sample, and different values across samples, does not make it
  # compound.
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  config_tasks <- read_config(hub_path, "tasks")
  tbl <- read_model_out_file(
    "flu-base/2022-10-22-flu-base.csv",
    hub_path,
    coerce_types = "chr"
  )
  tbl$target_end_date <- tbl$output_type_id
  expect_equal(
    get_tbl_compound_taskid_set(
      tbl,
      config_tasks,
      "2022-10-22",
      derived_task_ids = "target_end_date"
    )[["2"]],
    c("reference_date", "location")
  )
})

test_that("a sample with a missing output type ID is detected as its own sample (#401)", {
  tbl_chr <- tibble::tibble(
    location = c("a", "b", "a", "b", "a", "b"),
    horizon = c("1", "1", "1", "1", "1", "1"),
    output_type_id = c("1", "1", "2", "2", NA, NA)
  )
  membership <- spl_comp_tid_membership(
    tibble::tibble(
      output_type_id = tbl_chr$output_type_id,
      row_idx = seq_len(nrow(tbl_chr))
    ),
    tbl_chr,
    config_comp_tids = "location",
    task_ids = c("location", "horizon"),
    derived_task_ids = NULL
  )
  expect_equal(membership$output_type_ids, c("1", "2", NA))
  expect_equal(
    membership$is_compound_taskid,
    tibble::tibble(location = rep(FALSE, 3), horizon = rep(FALSE, 3))
  )
})

test_that("detect_coarser_compound_taskid_set filters out NULL and matching mts", {
  # mt 1: NULL detected (skip), mt 2: matches (skip), mt 3: coarser
  detected <- list(
    NULL,
    c("a", "b", "c"),
    c("a", "b")
  )
  configured <- list(
    c("a", "b"),
    c("a", "b", "c"),
    c("a", "b", "c")
  )

  result <- detect_coarser_compound_taskid_set(detected, configured)

  expect_length(result, 1L)
  expect_equal(result[[1]]$mt_idx, 3L)
  expect_equal(result[[1]]$detected, c("a", "b"))
  expect_equal(result[[1]]$configured, c("a", "b", "c"))
})

test_that("detect_coarser_compound_taskid_set returns empty list when all match or NULL", {
  expect_equal(
    detect_coarser_compound_taskid_set(
      detected = list(c("a", "b"), NULL),
      configured = list(c("a", "b"), c("x"))
    ),
    list()
  )
})

# Shared synthetic coarser_info for multi-mt message/warning tests.
multi_mt_coarser_info <- list(
  list(
    mt_idx = 2L,
    detected = c("a", "b"),
    configured = c("a", "b", "c")
  ),
  list(
    mt_idx = 4L,
    detected = c("x"),
    configured = c("x", "y")
  )
)

test_that("compile_coarser_details builds per-mt check-message details for multiple coarser mts", {
  expect_equal(
    compile_coarser_details(multi_mt_coarser_info),
    paste(
      "mt 2: detected (\"a\" and \"b\") is coarser than configured (\"a\", \"b\", and \"c\").",
      "mt 4: detected (\"x\") is coarser than configured (\"x\" and \"y\")."
    )
  )
})

test_that("compile_coarser_details returns NULL on empty input", {
  expect_null(compile_coarser_details(list()))
})

test_that("coarser_compound_taskid_set_warnings builds a single warning listing multiple mts", {
  result <- coarser_compound_taskid_set_warnings(multi_mt_coarser_info)

  expect_length(result, 1L)
  expect_s3_class(result[[1]], "validation_warning")
  expect_equal(
    result[[1]]$message,
    paste0(
      "Coarser-than-configured `compound_taskid_set` detected for ",
      "modeling tasks 2 and 4. See check message for specifics."
    )
  )
})

test_that("coarser_compound_taskid_set_warnings returns NULL on empty input", {
  expect_null(coarser_compound_taskid_set_warnings(list()))
})
