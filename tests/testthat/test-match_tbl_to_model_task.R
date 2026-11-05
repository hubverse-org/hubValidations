test_that("match_tbl_to_model_task works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  tbl <- read_model_out_file(
    file_path = "flu-base/2022-10-22-flu-base.csv",
    hub_path,
    coerce_types = "chr"
  )
  config_tasks <- read_config(hub_path, "tasks")

  res <- match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22")
  expect_equal(purrr::map_int(res, nrow), c(60L, 1530L))
  chr_types <- purrr::set_names(
    rep("character", 8),
    c(
      "reference_date",
      "target",
      "horizon",
      "location",
      "target_end_date",
      "output_type",
      "output_type_id",
      "value"
    )
  )
  purrr::walk(res, ~ expect_equal(first_classes(.x), chr_types))
  expect_equal(
    purrr::map(res, ~ unique(.x$target)),
    list("wk flu hosp rate category", "wk inc flu hosp")
  )
  expect_equal(
    sort(unique(res[[1]]$output_type_id)),
    c("high", "low", "moderate", "very high")
  )
  expect_equal(
    dplyr::count(res[[2]], output_type),
    tibble::tibble(
      output_type = c("mean", "median", "sample"),
      n = c(15L, 15L, 1500L)
    )
  )
  # Rows keep the order of the file.
  expect_equal(
    res[[1]][1:5, c("horizon", "location", "output_type_id")],
    tibble::tibble(
      horizon = c("0", "0", "0", "0", "1"),
      location = "01",
      output_type_id = c("low", "moderate", "high", "very high", "low")
    )
  )
  expect_equal(
    res[[2]][1:4, c("horizon", "location", "output_type")],
    tibble::tibble(
      horizon = c("0", "1", "2", "0"),
      location = c("US", "US", "US", "01"),
      output_type = "median"
    )
  )

  res_spl <- match_tbl_to_model_task(
    tbl,
    config_tasks,
    round_id = "2022-10-22",
    output_types = "sample"
  )
  expect_null(res_spl[[1]])
  expect_equal(res_spl[[2]], res[[2]][res[[2]]$output_type == "sample", ])
  expect_equal(dplyr::n_distinct(res_spl[[2]]$output_type_id), 500L)

  res_ord <- match_tbl_to_model_task(
    tbl,
    config_tasks,
    round_id = "2022-10-22",
    order_by_config = TRUE
  )
  # Rows sort on output type, then output type ID, then horizon, then
  # location, each in config order. Required locations (US, 01) come before
  # optional ones. Sample IDs have no config order, so sample rows that share
  # task IDs keep the order of the file.
  cols <- c("horizon", "location", "output_type", "output_type_id")
  expect_equal(
    res_ord[[1]][c(1:6, 30, 31, 59, 60), cols],
    tibble::tibble(
      horizon = c("0", "0", "0", "0", "0", "1", "2", "0", "2", "2"),
      location = c("US", "01", "02", "04", "05", "US", "05", "US", "04", "05"),
      output_type = "pmf",
      output_type_id = c(
        rep("low", 6),
        "moderate",
        "high",
        "very high",
        "very high"
      )
    )
  )
  expect_equal(
    res_ord[[2]][c(1:6, 16, 30, 31, 32, 1529, 1530), cols],
    tibble::tibble(
      horizon = c("0", "0", "0", "0", "0", "1", "0", "2", "0", "0", "2", "2"),
      location = c(
        "US",
        "01",
        "02",
        "04",
        "05",
        "US",
        "US",
        "05",
        "US",
        "US",
        "05",
        "05"
      ),
      output_type = c(rep("mean", 6), "median", "median", rep("sample", 4)),
      output_type_id = c(rep(NA_character_, 8), "5201", "5202", "399", "400")
    )
  )
  # Ordering returns the same rows as matching without it.
  purrr::walk2(
    res_ord,
    res,
    ~ expect_equal(
      dplyr::arrange(.x, dplyr::pick(dplyr::everything())),
      dplyr::arrange(.y, dplyr::pick(dplyr::everything()))
    )
  )
})

test_that("matching splits data the same way the expanded grid did", {
  for (fixture in match_fixtures()) {
    hub_path <- fixture[["hub_path"]]
    file_path <- fixture[["file_path"]]
    round_id <- get_file_round_id(file_path)
    config_tasks <- read_config(hub_path, "tasks")
    derived_task_ids <- get_hub_derived_task_ids(hub_path, round_id)

    tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
    if (hubUtils::is_v3_config(config_tasks)) {
      tbl[tbl$output_type == "sample", "output_type_id"] <- NA
    }
    if (!is.null(derived_task_ids)) {
      tbl[, derived_task_ids] <- NA_character_
    }

    # Once for the whole submission and once per output type, since the checks
    # that match data ask about one output type at a time.
    output_types <- c(list(NULL), as.list(unique(tbl$output_type)))
    for (output_type in output_types) {
      for (subset_to_tbl_cols in c(TRUE, FALSE)) {
        expect_equal(
          sort_partition(assign_tbl_to_model_task(
            tbl,
            config_tasks,
            round_id,
            output_types = output_type,
            derived_task_ids = derived_task_ids,
            subset_to_tbl_cols = subset_to_tbl_cols
          )),
          sort_partition(match_via_grid(
            tbl,
            config_tasks,
            round_id,
            output_types = output_type,
            derived_task_ids = derived_task_ids,
            subset_to_tbl_cols = subset_to_tbl_cols
          )),
          info = paste(basename(hub_path), output_type, subset_to_tbl_cols)
        )
      }
    }
  }
})

test_that("matching errors when a column it matches on is missing", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  tbl <- read_model_out_file(
    file_path = "flu-base/2022-10-22-flu-base.csv",
    hub_path,
    coerce_types = "chr"
  )
  config_tasks <- read_config(hub_path, "tasks")
  tbl[["location"]] <- NULL

  expect_snapshot(
    match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22"),
    error = TRUE
  )
})

test_that("order_by_config sorts on output type, then its IDs, then task IDs", {
  # Two task IDs that vary independently, so putting them in the wrong order
  # shows.
  config_tasks <- hubAdmin::create_config(hubAdmin::create_rounds(
    hubAdmin::create_round(
      round_id_from_variable = TRUE,
      round_id = "origin_date",
      model_tasks = hubAdmin::create_model_tasks(hubAdmin::create_model_task(
        task_ids = hubAdmin::create_task_ids(
          hubAdmin::create_task_id(
            "origin_date",
            required = "2024-01-01",
            optional = NULL
          ),
          hubAdmin::create_task_id(
            "horizon",
            required = c(1L, 2L),
            optional = NULL
          ),
          hubAdmin::create_task_id(
            "location",
            required = c("a", "b"),
            optional = NULL
          )
        ),
        output_type = hubAdmin::create_output_type(
          hubAdmin::create_output_type_quantile(
            required = c(0.25, 0.75),
            is_required = TRUE,
            value_type = "double"
          )
        ),
        target_metadata = hubAdmin::create_target_metadata(
          hubAdmin::create_target_metadata_item(
            target_id = "inc",
            target_name = "incidence",
            target_units = "count",
            target_keys = NULL,
            target_type = "discrete",
            is_step_ahead = FALSE
          )
        )
      )),
      submissions_due = list(start = "2024-01-01", end = "2024-01-08")
    )
  ))

  tbl <- expand.grid(
    origin_date = "2024-01-01",
    horizon = c("1", "2"),
    location = c("a", "b"),
    output_type = "quantile",
    output_type_id = c("0.25", "0.75"),
    stringsAsFactors = FALSE
  )
  tbl$value <- "1"
  withr::local_seed(1)
  tbl <- tbl[sample(nrow(tbl)), ]

  ordered <- match_tbl_to_model_task(
    tbl,
    config_tasks,
    round_id = "2024-01-01",
    order_by_config = TRUE
  )[[1]]

  # Output type ID first, then horizon, then location: the config's order of
  # each.
  expect_equal(ordered$output_type_id, rep(c("0.25", "0.75"), each = 4))
  expect_equal(ordered$horizon, rep(rep(c("1", "2"), each = 2), 2))
  expect_equal(ordered$location, rep(c("a", "b"), 4))
})
