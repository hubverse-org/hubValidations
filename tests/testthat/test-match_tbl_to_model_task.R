test_that("match_tbl_to_model_task works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  tbl <- read_model_out_file(
    file_path = "flu-base/2022-10-22-flu-base.csv",
    hub_path,
    coerce_types = "chr"
  )
  config_tasks <- read_config(hub_path, "tasks")

  expect_snapshot(
    match_tbl_to_model_task(tbl, config_tasks, round_id = "2022-10-22")
  )
  expect_snapshot(
    match_tbl_to_model_task(
      tbl,
      config_tasks,
      round_id = "2022-10-22",
      output_types = "sample"
    )
  )
  expect_snapshot(
    match_tbl_to_model_task(
      tbl,
      config_tasks,
      round_id = "2022-10-22",
      order_by_config = TRUE
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
