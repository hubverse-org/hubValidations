test_that("check_tbl_values_required works with 1 model task & completely opt cols", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- hubValidations::read_model_out_file(file_path, hub_path) %>%
    hubUtils::coerce_to_hub_schema(config_tasks)
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
    missing_req_block$missing, tbl[1:23, names(tbl) != "value"]
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
    res_missing_otid$missing, tbl[24:26, names(tbl) != "value"]
  )
})


test_that("check_tbl_values_required works with 2 separate model tasks & completely missing cols", {
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  round_id <- "2023-05-08"
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- hubValidations::read_model_out_file(file_path, hub_path) %>%
    hubUtils::coerce_to_hub_schema(config_tasks)

  expect_snapshot(
    check_tbl_values_required(tbl, round_id, file_path, hub_path)
  )

  missing_required <- check_tbl_values_required(tbl[-(24:25), ], round_id, file_path, hub_path)
  expect_snapshot(
    str(missing_required)
  )
  expect_equal(
    missing_required$missing, tbl[24:25, names(tbl) != "value"]
  )

  missing_opt_otid <- check_tbl_values_required(
    tbl[-(1:2), ],
    round_id, file_path, hub_path
  )
  expect_snapshot(
    str(missing_opt_otid)
  )
  expect_equal(
    missing_opt_otid$missing, tbl[1:2, names(tbl) != "value"]
  )

  pmf_row <- tbl[24, ]
  pmf_row$output_type <- "pmf"
  pmf_row$output_type_id <- "large_decrease"
  pmf_row$target <- "wk flu hosp rate change"
  pmf_row$value <- 0.5

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


  pmf_row$horizon <- 1L
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
      hub_path = hub_path
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

    # Expect that values for output type IDs "0.1000000000000000055511", "0.150" and
    #  "0.2" are correctly interpretted and not part of the missing output type IDs.
    expect_length(
      intersect(
        c("0.1", "0.15", "0.2"),
        check$missing$output_type_id
      ),
      0L
    )
  }
)
