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
      c("check_failure", "hub_check", "rlang_warning", "warning", "condition")
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
      c("check_success", "hub_check", "rlang_message", "message", "condition")
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
  expect_equal(
    unique(missing$output_type),
    c("pmf", "sample", "mean", "median")
  )
  expect_true(all(missing$location == "US"))
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
  # TODO: Remove suppressWarnings when v4 is released
  config_tasks <- read_config(hub_path, "tasks") |> suppressWarnings()
  tbl <- read_model_out_file(file_path, hub_path,
    coerce_types = "chr"
  ) |> suppressWarnings() # TODO: Remove suppressWarnings when v4 is released
  tbl_hub <- read_model_out_file(file_path, hub_path,
    coerce_types = "hub"
  ) |> suppressWarnings() # TODO: Remove suppressWarnings when v4 is released
  expect_s3_class(
    check_tbl_values_required(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_date"
    ) |> suppressWarnings(), # TODO: Remove suppressWarnings when v4 is released
    c("check_success", "hub_check", "rlang_message", "message", "condition"),
    exact = TRUE
  )

  missing_required <- check_tbl_values_required(
    tbl[-(24:25), ], round_id, file_path, hub_path,
    derived_task_ids = "target_date"
  ) |> suppressWarnings() # TODO: Remove suppressWarnings when v4 is released
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
  ) |> suppressWarnings() # TODO: Remove suppressWarnings when v4 is released
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
  ) |> suppressWarnings() # TODO: Remove suppressWarnings when v4 is released
  expect_equal(
    missing_pmf$missing$output_type_id,
    c("decrease", "stable", "increase", "large_increase")
  )

  pmf_row$horizon <- "1"
  missing_horizon <- check_tbl_values_required(
    pmf_row, round_id,
    file_path, hub_path,
    derived_task_ids = "target_date"
  ) |> suppressWarnings() # TODO: Remove suppressWarnings when v4 is released
  missing <- missing_horizon$missing
  expect_equal(nrow(missing), 9L)
  expect_equal(nrow(missing[missing$horizon == 1L, ]), 4L)
  expect_equal(nrow(missing[missing$horizon == 2L, ]), 5L)
})


test_that("Reading derived_task_ids from config works", {
  hub_path <- system.file("testhubs/v4/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  round_id <- "2023-05-08"
  # TODO: Remove suppressWarnings when v4 is released
  config_tasks <- read_config(hub_path, "tasks") |> suppressWarnings()
  tbl <- read_model_out_file(file_path, hub_path,
    coerce_types = "chr"
  ) |> suppressWarnings() # TODO: Remove suppressWarnings when v4 is released

  # Ensure reading derived_task_ids from config gives same result as when
  # explicitly provided as argument
  expect_equal(
    check_tbl_values_required(tbl, round_id, file_path, hub_path,
      derived_task_ids = "target_date"
    ) |> suppressWarnings(), # TODO: Remove suppressWarnings when v4 is released
    check_tbl_values_required(tbl, round_id, file_path, hub_path) |>
      suppressWarnings() # TODO: Remove suppressWarnings when v4 is released
  )
})
