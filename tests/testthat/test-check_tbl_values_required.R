test_that("check_tbl_values_required works with 1 model task & completely opt cols", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  config_tasks <- read_config(hub_path, "tasks")
  tbl <- read_model_out_file(file_path, hub_path,
    coerce_types = "chr"
  )
  tbl_hub <- read_model_out_file(file_path, hub_path,
    coerce_types = "hub"
  )
  round_id <- "2022-10-08"

  # Test all required but only optional location for optional output type
  expect_snapshot(
    check_tbl_values_required(tbl, round_id, file_path, hub_path)
  )
  # Test completely missing required block
  missing_req_block <- check_tbl_values_required(
    tbl[24:47, ],
    round_id, file_path, hub_path
  )
  expect_snapshot(
    str(missing_req_block)
  )
  expect_false("mean" %in% missing_req_block$missing$output_type)

  expect_equal(
    missing_req_block$missing, tbl_hub[1:23, names(tbl_hub) != "value"]
  )

  # Test missing required output_type_id for optional task ID
  res_missing_otid <- check_tbl_values_required(
    tbl[-(24:26), ],
    round_id, file_path, hub_path
  )
  expect_snapshot(
    str(res_missing_otid)
  )
  expect_false("mean" %in% res_missing_otid$missing$output_type)

  expect_equal(
    res_missing_otid$missing, tbl_hub[24:26, names(tbl_hub) != "value"]
  )
})


test_that("check_tbl_values_required works with 2 separate model tasks & completely missing cols", {
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  round_id <- "2023-05-08"
  config_tasks <- read_config(hub_path, "tasks")
  tbl <- read_model_out_file(file_path, hub_path,
    coerce_types = "chr"
  )
  tbl_hub <- read_model_out_file(file_path, hub_path,
    coerce_types = "hub"
  )
  expect_snapshot(
    check_tbl_values_required(tbl, round_id, file_path, hub_path)
  )

  missing_required <- check_tbl_values_required(tbl[-(24:25), ], round_id, file_path, hub_path)
  expect_snapshot(
    str(missing_required)
  )
  expect_equal(
    missing_required$missing, tbl_hub[24:25, names(tbl_hub) != "value"]
  )

  missing_opt_otid <- check_tbl_values_required(
    tbl[-(1:2), ],
    round_id, file_path, hub_path
  )
  expect_snapshot(
    str(missing_opt_otid)
  )
  expect_equal(
    missing_opt_otid$missing, tbl_hub[1:2, names(tbl_hub) != "value"]
  )

  pmf_row <- tbl[24, ]
  pmf_row$output_type <- "pmf"
  pmf_row$output_type_id <- "large_decrease"
  pmf_row$target <- "wk flu hosp rate change"
  pmf_row$value <- "0.5"

  missing_pmf <- check_tbl_values_required(
    pmf_row, round_id,
    file_path, hub_path
  )
  expect_snapshot(
    str(missing_pmf)
  )
  expect_equal(
    missing_pmf$missing$output_type_id,
    c("decrease", "stable", "increase", "large_increase")
  )

  expect_equal(
    check_tbl_values_required(
      pmf_row, round_id,
      file_path, hub_path
    ),
    check_tbl_values_required(
      rbind(tbl, pmf_row), round_id,
      file_path, hub_path
    ),
    ignore_attr = TRUE
  )


  pmf_row$horizon <- "1"
  missing_horizon <- check_tbl_values_required(
    pmf_row, round_id,
    file_path, hub_path
  )
  expect_snapshot(
    str(missing_horizon)
  )
})

test_that(
  "check_tbl_values_required correctly matches numeric output type IDs when output type ID col is character.",
  {
    hub_path <- test_path("testdata/hub-chr")
    file_path <- "UMass-gbq/2023-10-28-UMass-gbq.csv"
    round_id <- "2023-10-28"
    tbl <- read_model_out_file(
      file_path = file_path,
      hub_path = hub_path,
      coerce_types = "chr"
    )

    check <- check_tbl_values_required(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )

    expect_s3_class(
      check,
      c("check_failure")
    )

    # Expect that values for output type IDs "0.1000000000000000055511",
    # and "0.150" (trailing zero retained yet lost on read of tasks config)
    # are not correctly interpreted and are part of the missing output
    # whereas "0.2" matches the values in config without the trailing zeros.
    expect_length(
      intersect(
        c("0.1", "0.15", "0.2"),
        check$missing$output_type_id
      ),
      2L
    )
  }
)



test_that(
  "check_tbl_values_required works when config contains non required modeling task.",
  {
    hub_path <- test_path("testdata/hub-it")
    file_path <- "Tm-Md/2023-11-04-Tm-Md.csv"
    round_id <- "2023-11-04"
    tbl <- read_model_out_file(
      file_path = file_path,
      hub_path = hub_path,
      coerce_types = "chr"
    )
    expect_s3_class(
      check_tbl_values_required(
        tbl = tbl,
        round_id = round_id,
        file_path = file_path,
        hub_path = hub_path
      ),
      c("check_success")
    )
  }
)

test_that("check_tbl_values_required works with v3 spec samples", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_values_required(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )
  # Remove US location to test missing required values identified and reported
  # correctly.
  tbl <- tbl[tbl$location != "US", ]
  expect_snapshot(
    check_tbl_values_required(
      tbl = tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )
  missing <- check_tbl_values_required(
    tbl = tbl,
    round_id = round_id,
    file_path = file_path,
    hub_path = hub_path
  )$missing
  expect_snapshot(missing)
  # Missing required values reported should include optional values
  # (e.g optional horizons 0:2) and output types (e.g. mean & median)
  # for which other locations have been submitted but the required
  #  US location is now missing.
  expect_equal(
    unique(missing$output_type),
    c("pmf", "mean", "median", "sample")
  )
  expect_true(all(missing$location == "US"))
  expect_equal(unique(missing$horizon),  0:2)

  # Remove some optional submission values to check that they are not
  # flagged as required when required US value is missing.
  tbl <- tbl[tbl$horizon == 1L, ]
  tbl <- tbl[tbl$output_type != "median", ]

  missing <- check_tbl_values_required(
    tbl = tbl,
    round_id = round_id,
    file_path = file_path,
    hub_path = hub_path
  )$missing

  expect_equal(unique(missing$horizon),  1)
  expect_equal(
    unique(missing$output_type),
    c("pmf", "mean", "sample")
  )
})

test_that("Ignoring derived_task_ids in check_tbl_values_required works", {
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
    check_tbl_values_required(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  # Check that ignoring derived task ids returns same result as not ignoring.
  expect_equal(
    check_tbl_values_required(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    ),
    check_tbl_values_required(tbl_orig, round_id, file_path, hub_path,
      derived_task_ids = "target_end_date"
    )
  )
})

test_that("(#123) check_tbl_values_required works with all optional output types", {
  skip_if_offline()

  hub_path <- test_path("testdata", "hub-now")
  file_path <- "UMass-HMLR/2024-10-02-UMass-HMLR.parquet"
  round_id <- "2024-10-02"
  tbl <- read_model_out_file(
    hub_path = hub_path, file_path = file_path,
    coerce_types = "chr"
  )

  opt_output_type_ids_result <- check_tbl_values_required(
    tbl, round_id, file_path, hub_path
  )
  # Check output correct
  expect_snapshot(opt_output_type_ids_result)
  # Missing output structure correct
  expect_snapshot(opt_output_type_ids_result$missing)
  # Missing clades identified correctly
  expect_equal(
    unique(opt_output_type_ids_result$missing$clade),
    c("24A", "24B")
  )
  # Ensure that req_vals check is the only one that fails
  expect_snapshot(
    check_for_errors(validate_submission(
      hub_path, file_path,
      skip_submit_window_check = TRUE
    )),
    error = TRUE
  )
})

test_that("check_tbl_values_required works with v4 hubs", {
  hub_path <- system.file("testhubs/v4/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  round_id <- "2023-05-08"
  config_tasks <- read_config(hub_path, "tasks")
  tbl <- read_model_out_file(file_path, hub_path,
    coerce_types = "chr"
  )
  tbl_hub <- read_model_out_file(file_path, hub_path,
    coerce_types = "hub"
  )
  expect_s3_class(
    check_tbl_values_required(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_date"
    ),
    c("check_success", "hub_check", "rlang_message", "message", "condition"),
    exact = TRUE
  )

  missing_required <- check_tbl_values_required(
    tbl[-(24:25), ], round_id, file_path, hub_path,
    derived_task_ids = "target_date"
  )
  missing <- missing_required$missing
  expect_true(nrow(missing) == 2L)
  expect_equal(
    missing[, names(missing) != "target_date"],
    tbl_hub[24:25, !names(tbl_hub) %in% c("target_date", "value")]
  )

  missing_opt_otid <- check_tbl_values_required(
    tbl[-(1:2), ],
    round_id, file_path, hub_path,
    derived_task_ids = "target_date"
  )
  missing <- missing_opt_otid$missing
  expect_equal(
    missing[, names(missing) != "target_date"],
    tbl_hub[1:2, !names(tbl_hub) %in% c("target_date", "value")]
  )

  pmf_row <- tbl[24, ]
  pmf_row$output_type <- "pmf"
  pmf_row$output_type_id <- "large_decrease"
  pmf_row$target <- "wk flu hosp rate change"
  pmf_row$value <- "0.5"

  missing_pmf <- check_tbl_values_required(
    pmf_row, round_id,
    file_path, hub_path,
    derived_task_ids = "target_date"
  )
  expect_equal(
    missing_pmf$missing$output_type_id,
    c("decrease", "stable", "increase", "large_increase")
  )

  pmf_row$horizon <- "1"
  missing_horizon <- check_tbl_values_required(
    pmf_row, round_id,
    file_path, hub_path,
    derived_task_ids = "target_date"
  )
  missing <- missing_horizon$missing
  expect_equal(nrow(missing), 9L)
  expect_equal(nrow(missing[missing$horizon == 1L, ]), 4L)
  expect_equal(nrow(missing[missing$horizon == 2L, ]), 5L)
})


test_that("Reading derived_task_ids from config works", {
  hub_path <- system.file("testhubs/v4/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  round_id <- "2023-05-08"
  config_tasks <- read_config(hub_path, "tasks")
  tbl <- read_model_out_file(file_path, hub_path,
    coerce_types = "chr"
  )

  # Ensure reading derived_task_ids from config gives same result as when
  # explicitly provided as argument
  expect_equal(
    check_tbl_values_required(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_date"
    ),
    check_tbl_values_required(tbl, round_id, file_path, hub_path)
  )
})

test_that("v4 config output type leak fixed (#177)", {
  hub_path <- test_path("testdata", "hub-177")
  file_path <- "FluSight-baseline/2024-12-14-FluSight-baseline.parquet"
  round_id <- "2024-12-14"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  res <- check_tbl_values_required(tbl,
    round_id = round_id,
    file_path = file_path, hub_path = hub_path
  )

  expect_s3_class(res,
    c(
      "check_success", "hub_check",
      "rlang_message", "message",
      "condition"
    ),
    exact = TRUE
  )
})

test_that("Missing required modeling task detected (#203)", {
  file_path <- test_path("testdata/files/missing-req-vals-203.parquet")
  tbl_chr <- arrow::read_parquet(file_path) |>
    hubData::coerce_to_character()

  local_mocked_bindings(
    read_config = function(...) {
      read_config_file(test_path("testdata/configs/tasks-v5-req-task-id.json"))
    }
  )

  res <- check_tbl_values_required(tbl_chr,
    round_id = "2022-11-05",
    file_path = "missing-req-vals-203.parquet", hub_path = "test-hub",
    derived_task_ids = "target_end_date"
  )

  expect_s3_class(res, "check_failure")

  expect_equal(
    res$missing,
    structure(
      list(
        reference_date = structure(
          c(19301, 19301, 19301, 19301),
          class = "Date"
        ),
        target = c(
          "wk inc flu hosp", "wk inc flu hosp",
          "wk inc flu hosp", "wk inc flu hosp"
        ),
        horizon = c(1L, 1L, 1L, 1L),
        location = c("US", "01", "US", "01"),
        variant = c("AA", "AA", "BB", "BB"),
        target_end_date = structure(c(
          NA_real_, NA_real_,
          NA_real_, NA_real_
        ), class = "Date"),
        output_type = c("mean", "mean", "mean", "mean"),
        output_type_id = c(
          NA_character_, NA_character_, NA_character_, NA_character_
        )
      ),
      class = c("tbl_df", "tbl", "data.frame"),
      row.names = c(NA, -4L)
    )
  )
})
