test_that("check_tbl_value_col_ascending works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  file_meta <- parse_file_name(file_path)
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  file_meta <- parse_file_name(file_path)

  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  expect_snapshot(
    check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
  )
})

test_that("check_tbl_value_col_ascending works when output type IDs not ordered", {
  hub_path <- test_path("testdata/hub-unordered/")
  tbl <- arrow::read_csv_arrow(
    fs::path(hub_path, "model-output/2024-01-10-ISI-NotOrdered.csv")
  ) %>%
    hubData::coerce_to_character()
  file_path <- "ISI-NotOrdered/2024-01-10-ISI-NotOrdered.csv"
  file_meta <- parse_file_name(file_path)
  expect_snapshot(
    check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
  )
})

test_that("check_tbl_value_col_ascending errors correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  file_meta <- parse_file_name(file_path)
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)

  tbl$value[c(1, 10)] <- 150

  expect_snapshot(
    str(check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id))
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
  file_meta <- parse_file_name(file_path)
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl_error <- tbl
  tbl_error$target <- "wk ahead inc covid hosp"
  tbl_error$value[1] <- 800

  expect_snapshot(
    str(
      check_tbl_value_col_ascending(tbl_error, file_path, hub_path, file_meta$round_id)
    )
  )
  expect_snapshot(
    str(
      check_tbl_value_col_ascending(
        rbind(tbl, tbl_error),
        file_path,
        hub_path,
        file_meta$round_id
      )
    )
  )
})

test_that("check_tbl_value_col_ascending skips correctly", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  file_meta <- parse_file_name(file_path)
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl <- tbl[tbl$output_type == "mean", ]

  expect_snapshot(
    check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
  )
})


test_that("(#78) check_tbl_value_col_ascending will sort even if the data doesn't naturally sort", {
  # In this situaton, I am duplicating the simple testhub and modifying it in
  # one way:
  #
  # I am replacing the `quantile` model task with `cdf` and adding a cumulative
  # sum so that we can get unsortable numbers.
  make_unsortable <- function(x) suppressWarnings(x + 1:23)

  # Duplicating the simple test hub ---------------------------------------
  hub_path <- withr::local_tempdir()
  fs::dir_copy(system.file("testhubs/simple", package = "hubValidations"),
    hub_path,
    overwrite = TRUE
  )

  # Creating the CFG output -----------------------------------------------
  cfg <- attr(hubData::connect_hub(hub_path), "config_tasks")
  outputs <- cfg$rounds[[1]]$model_tasks[[1]]$output_type
  outputs$cfg <- outputs$quantile
  outputs$quantile <- NULL
  otid <- outputs$cfg$output_type_id$required
  outputs$cfg$output_type_id$required <- make_unsortable(otid)
  cfg$rounds[[1]]$model_tasks[[1]]$output_type <- outputs
  jsonlite::toJSON(cfg) %>%
    jsonlite::prettify() %>%
    writeLines(fs::path(hub_path, "hub-config", "tasks.json"))

  # Updating the data to match the config --------------------------------
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  file_meta <- parse_file_name(file_path)
  tbl <- hubValidations::read_model_out_file(file_path, hub_path)
  tbl$output_type_id <- make_unsortable(tbl$output_type_id)

  # validating when it is sorted -----------------------------------------
  res <- check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
  expect_s3_class(res, "check_success")
  expect_null(res$error_tbl)

  # validating when it is unsorted ---------------------------------------
  res_unordered <- check_tbl_value_col_ascending(
    tbl[sample(nrow(tbl)), ],
    file_path,
    hub_path,
    file_meta$round_id
  )
  expect_s3_class(res_unordered, "check_success")
  expect_null(res_unordered$error_tbl)
})
