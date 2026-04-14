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
      "modeling tasks 2 and 4. See check message and compound_taskid_set ",
      "fields for specifics."
    )
  )
})

test_that("coarser_compound_taskid_set_warnings returns NULL on empty input", {
  expect_null(coarser_compound_taskid_set_warnings(list()))
})
