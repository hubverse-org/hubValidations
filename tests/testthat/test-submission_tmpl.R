test_that("submission_tmpl works correctly with path to hub", {
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")

  x <- submission_tmpl(hub_path, round_id = "2023-01-30")
  expect_tbl(
    x,
    n_rows = 3132L,
    types = c(flusight_grid_types, value = "numeric"),
    values = list(
      forecast_date = as.Date("2023-01-30"),
      horizon = 1:2,
      location = hub_locations,
      output_type_id = flusight_output_type_ids,
      value = NA_real_
    ),
    counts = tibble::tibble(
      target = c(
        "wk ahead inc flu hosp",
        "wk ahead inc flu hosp",
        "wk flu hosp rate change"
      ),
      output_type = c("mean", "quantile", "pmf"),
      n = c(108L, 2484L, 540L)
    )
  )
  expect_equal(
    x[1:4, c("target", "horizon", "location", "output_type", "output_type_id")],
    tibble::tibble(
      target = "wk flu hosp rate change",
      horizon = c(2L, 1L, 2L, 1L),
      location = c("US", "US", "01", "01"),
      output_type = "pmf",
      output_type_id = "large_decrease"
    )
  )

  x_jan16 <- submission_tmpl(hub_path, round_id = "2023-01-16")
  expect_equal(unique(x_jan16$forecast_date), as.Date("2023-01-16"))
  expect_equal(
    dplyr::select(x_jan16, -forecast_date),
    dplyr::select(x, -forecast_date)
  )
  expect_equal(
    unique(suppressMessages(
      submission_tmpl(
        hub_path,
        round_id = "2022-12-19"
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )

  x <- submission_tmpl(
    hub_path,
    round_id = "2023-01-16",
    required_vals_only = TRUE
  )
  expect_tbl(
    x,
    n_rows = 0L,
    types = c(flusight_grid_types, value = "numeric"),
    values = list(
      forecast_date = as.Date(character()),
      target = character(),
      horizon = integer(),
      location = character(),
      output_type = character(),
      output_type_id = character(),
      value = numeric()
    )
  )
  expect_equal(
    unique(suppressMessages(
      submission_tmpl(
        hub_path,
        round_id = "2022-12-19",
        required_vals_only = TRUE,
        complete_cases_only = FALSE
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )

  expect_snapshot(
    x <- submission_tmpl(
      hub_path,
      round_id = "2023-01-16",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  )
  expect_tbl(
    x,
    n_rows = 28L,
    types = c(flusight_grid_types, value = "numeric"),
    values = list(
      forecast_date = as.Date("2023-01-16"),
      target = NA_character_,
      horizon = 2L,
      location = "US",
      output_type = c("pmf", "quantile"),
      value = NA_real_
    ),
    unchecked = "output_type_id"
  )
  expect_equal(
    x$output_type_id,
    c(
      "large_decrease",
      "decrease",
      "stable",
      "increase",
      "large_increase",
      as.character(hub_quantiles)
    )
  )

  expect_equal(
    unique(suppressMessages(
      submission_tmpl(
        hub_path,
        round_id = "2022-12-19",
        required_vals_only = TRUE,
        complete_cases_only = FALSE
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )

  # Specifying a round in a hub with multiple rounds
  hub_path <- system.file("testhubs/simple", package = "hubUtils")

  x <- submission_tmpl(
    hub_path,
    round_id = "2022-10-01"
  )
  expect_tbl(
    x,
    n_rows = 5184L,
    types = c(simple_grid_types, value = "integer"),
    values = list(
      origin_date = as.Date("2022-10-01"),
      target = "wk inc flu hosp",
      horizon = 1:4,
      location = hub_locations,
      output_type_id = c(hub_quantiles, NA),
      value = NA_integer_
    ),
    counts = tibble::tibble(
      output_type = c("mean", "quantile"),
      n = c(216L, 4968L)
    )
  )
  expect_equal(
    x[1:4, c("horizon", "location", "output_type")],
    tibble::tibble(horizon = 1:4, location = "US", output_type = "mean")
  )

  expect_snapshot(
    x <- submission_tmpl(
      hub_path,
      round_id = "2022-10-01",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  )
  expect_tbl(
    x,
    n_rows = 23L,
    types = c(simple_grid_types, value = "integer"),
    values = list(
      origin_date = as.Date("2022-10-01"),
      target = "wk inc flu hosp",
      horizon = 1L,
      location = NA_character_,
      output_type = "quantile",
      output_type_id = hub_quantiles,
      value = NA_integer_
    )
  )
  expect_equal(x$output_type_id, hub_quantiles)
  expect_snapshot(
    x <- submission_tmpl(
      hub_path,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  )
  expect_tbl(
    x,
    n_rows = 23L,
    types = c(simple_age_grid_types, value = "integer"),
    values = list(
      origin_date = as.Date("2022-10-29"),
      target = "wk inc flu hosp",
      horizon = 1L,
      location = NA_character_,
      age_group = "65+",
      output_type = "quantile",
      output_type_id = hub_quantiles,
      value = NA_integer_
    )
  )
  expect_equal(x$output_type_id, hub_quantiles)

  x <- submission_tmpl(
    hub_path,
    round_id = "2022-10-29",
    required_vals_only = TRUE
  )
  expect_tbl(
    x,
    n_rows = 0L,
    types = c(simple_age_grid_types, value = "integer"),
    values = list(
      origin_date = as.Date(character()),
      target = character(),
      horizon = integer(),
      location = character(),
      age_group = character(),
      output_type = character(),
      output_type_id = numeric(),
      value = integer()
    )
  )
})

test_that("submission_tmpl works correctly with path to task config file", {
  config_path <- system.file("config", "tasks.json", package = "hubValidations")
  x <- submission_tmpl(config_path, round_id = "2022-12-26")
  expect_tbl(
    x,
    n_rows = 42L,
    types = c(flusight_grid_types, value = "numeric"),
    values = list(
      forecast_date = as.Date("2022-12-26"),
      target = c("wk ahead inc flu hosp", "wk flu hosp rate change"),
      horizon = 1:2,
      location = c("01", "02", "US"),
      output_type_id = c(
        "decrease",
        "increase",
        "large_decrease",
        "large_increase",
        paste0("s", 1:6),
        "stable",
        NA
      ),
      value = NA_real_
    ),
    counts = tibble::tibble(
      output_type = c("mean", "pmf", "sample"),
      n = c(6L, 30L, 6L)
    )
  )
  # The config sets no `compound_taskid_set`, so it defaults to every task ID
  # and each sample row is its own sample.
  expect_equal(
    x[x$output_type == "sample", c("horizon", "location", "output_type_id")],
    tibble::tibble(
      horizon = rep(c(2L, 1L), 3),
      location = rep(c("US", "01", "02"), each = 2),
      output_type_id = paste0("s", 1:6)
    )
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  config_path <- file.path(hub_path, "hub-config", "tasks.json")
  expect_equal(
    submission_tmpl(hub_path, round_id = "2023-01-30"),
    submission_tmpl(config_path, round_id = "2023-01-30")
  )
})


test_that("submission_tmpl works correctly with deprecated args", {
  withr::local_options(lifecycle_verbosity = "quiet")
  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )

  expect_equal(
    submission_tmpl(hub_con = hub_con, round_id = "2023-01-30"),
    submission_tmpl(
      system.file("testhubs/flusight", package = "hubUtils"),
      round_id = "2023-01-30"
    )
  )

  # Using config_tasks instead of hub_con
  config_path <- system.file("config", "tasks.json", package = "hubValidations")
  expect_equal(
    submission_tmpl(
      config_tasks = read_config_file(config_path),
      round_id = "2022-12-26"
    ),
    submission_tmpl(config_path, round_id = "2022-12-26")
  )
})

test_that("submission_tmpl errors correctly", {
  # Specifying a round in a hub with multiple rounds
  hub_path <- system.file("testhubs/simple", package = "hubUtils")

  expect_error(
    submission_tmpl(
      hub_path,
      round_id = "random_round_id"
    ),
    regexp = "`round_id` must be one of"
  )
  expect_error(
    submission_tmpl(hub_path),
    regexp = 'argument "round_id" is missing, with no default'
  )

  expect_error(
    submission_tmpl(path = "random_hub_path"),
    regexp = "does not exist."
  )

  config_path <- system.file(
    "config",
    "tasks-comp-tid.json",
    package = "hubValidations"
  )
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26",
      compound_taskid_set = list(
        c("forecast_date", "target", "random_var"),
        NULL
      )
    ),
    error = TRUE
  )
})

test_that("submission_tmpl output type subsetting works", {
  config_path <- system.file(
    "config",
    "tasks-comp-tid.json",
    package = "hubValidations"
  )
  # Subsetting for a single output type
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26",
      output_types = "sample"
    )
  )

  # Subsetting for a two output types
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26",
      output_types = c("mean", "sample")
    )
  )
})

test_that("submission_tmpl handles samples correctly", {
  config_path <- system.file(
    "config",
    "tasks-comp-tid.json",
    package = "hubValidations"
  )
  tmpl <- submission_tmpl(config_path, round_id = "2022-12-26")
  expect_tbl(
    tmpl,
    n_rows = 42L,
    types = c(flusight_grid_types, value = "numeric"),
    values = list(
      forecast_date = as.Date("2022-12-26"),
      target = c("wk ahead inc flu hosp", "wk flu hosp rate change"),
      horizon = 1:2,
      location = c("01", "02", "US"),
      output_type_id = c(
        "1",
        "2",
        "decrease",
        "increase",
        "large_decrease",
        "large_increase",
        "stable",
        NA
      ),
      value = NA_real_
    ),
    counts = tibble::tibble(
      output_type = c("mean", "pmf", "sample"),
      n = c(6L, 30L, 6L)
    )
  )
  # The configured `compound_taskid_set` is forecast_date, target and horizon,
  # so the sample rows form one sample per horizon.
  expect_equal(
    tmpl[tmpl$output_type == "sample", ],
    tibble::tibble(
      forecast_date = as.Date("2022-12-26"),
      target = "wk ahead inc flu hosp",
      horizon = rep(c(2L, 1L), each = 3L),
      location = rep(c("US", "01", "02"), times = 2L),
      output_type = "sample",
      output_type_id = rep(c("1", "2"), each = 3L),
      value = NA_real_
    )
  )

  expect_equal(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26",
      output_types = "sample"
    ),
    submission_tmpl(
      config_path,
      round_id = "2022-12-26"
    ) |>
      dplyr::filter(.data$output_type == "sample")
  )

  # Override config compound task ID structure
  x <- submission_tmpl(
    config_path,
    round_id = "2022-12-26",
    compound_taskid_set = list(
      c("forecast_date", "target"),
      NULL
    )
  )
  expect_spl_override(x, tmpl, spl_ids = rep("1", 6L))

  # Check that everything works with a single compound_taskid_set column
  x <- submission_tmpl(
    config_path,
    round_id = "2022-12-26",
    compound_taskid_set = list(
      c("forecast_date"),
      NULL
    )
  )
  expect_spl_override(x, tmpl, spl_ids = rep("1", 6L))

  # Check that a list with `NULL` compound_taskid_set specification results in
  # all task ids being included in the compound_taskid_set
  x <- submission_tmpl(
    config_path,
    round_id = "2022-12-26",
    compound_taskid_set = list(
      NULL,
      NULL
    )
  )
  expect_spl_override(x, tmpl, spl_ids = as.character(1:6))

  # `target` takes a single value in the sample modeling task above, so a
  # `compound_taskid_set` of forecast_date alone groups rows as forecast_date
  # and target do. A config with a second target tells the two apart: joint
  # across targets, or one sample per target.
  config <- jsonlite::read_json(config_path, simplifyVector = FALSE)
  mt <- config$rounds[[1]]$model_tasks[[1]]
  mt$task_ids$target$optional <- list(
    "wk ahead inc flu hosp",
    "wk ahead inc flu death"
  )
  death_metadata <- mt$target_metadata[[1]]
  death_metadata$target_id <- "wk ahead inc flu death"
  death_metadata$target_name <- "weekly influenza death incidence"
  death_metadata$description <-
    "This target represents the counts of new deaths per horizon week."
  death_metadata$target_units <- "count"
  death_metadata$target_keys$target <- list("wk ahead inc flu death")
  mt$target_metadata <- c(mt$target_metadata, list(death_metadata))
  config$rounds[[1]]$model_tasks[[1]] <- mt
  two_targets <- withr::local_tempfile(fileext = ".json")
  jsonlite::write_json(
    config,
    two_targets,
    auto_unbox = TRUE,
    null = "null",
    pretty = TRUE
  )
  spl_targets <- function(compound_taskid_set) {
    x <- submission_tmpl(
      two_targets,
      round_id = "2022-12-26",
      compound_taskid_set = compound_taskid_set
    )
    x <- x[x$output_type == "sample", c("target", "output_type_id")]
    dplyr::distinct(x)
  }
  expect_equal(
    spl_targets(list("forecast_date", NULL)),
    tibble::tibble(
      target = c("wk ahead inc flu hosp", "wk ahead inc flu death"),
      output_type_id = "1"
    )
  )
  expect_equal(
    spl_targets(list(c("forecast_date", "target"), NULL)),
    tibble::tibble(
      target = c("wk ahead inc flu hosp", "wk ahead inc flu death"),
      output_type_id = c("1", "2")
    )
  )

  # Character sample output type IDs returned as strings with "s" prefix
  spl_output_type_ids <- submission_tmpl(
    path = system.file("config", "tasks.json", package = "hubValidations"),
    round_id = "2022-12-26",
    output_types = "sample"
  )$output_type_id

  expect_equal(spl_output_type_ids, c("s1", "s2", "s3", "s4", "s5", "s6"))
})

test_that("submission_tmpl ignoring derived task ids works", {
  hub_path <- test_path("testdata", "hub-spl")
  x <- submission_tmpl(
    hub_path,
    round_id = "2022-10-22",
    output_types = "sample",
    derived_task_ids = "target_end_date",
    complete_cases_only = FALSE
  )
  # The configured `compound_taskid_set` holds every task ID but target, which
  # has one value, so every row is its own sample. The derived task ID is left
  # NA.
  expect_tbl(
    x,
    n_rows = 80L,
    types = c(
      reference_date = "Date",
      target = "character",
      horizon = "integer",
      location = "character",
      variant = "character",
      target_end_date = "Date",
      output_type = "character",
      output_type_id = "character",
      value = "numeric"
    ),
    values = list(
      reference_date = as.Date("2022-10-22"),
      target = "wk inc flu hosp",
      horizon = 0:3,
      location = c("01", "02", "04", "05", "US"),
      variant = c("AA", "BB", "CC", "DD"),
      target_end_date = as.Date(NA),
      output_type = "sample",
      value = NA_real_
    ),
    unchecked = "output_type_id"
  )
  expect_equal(x$output_type_id, as.character(1:80))
  expect_equal(
    x[1:5, c("horizon", "location", "variant")],
    tibble::tibble(
      horizon = c(0:3, 0L),
      location = c(rep("US", 4), "01"),
      variant = "AA"
    )
  )
})


test_that("submission_tmpl force_output_types works", {
  config_path <- test_path(
    "testdata",
    "configs",
    "tasks-samples-v4.json"
  )
  # When force_output_types is not set, all output_types are optional, a
  #  zero row and column data.frame is returned  by default.
  req_non_force_default <- submission_tmpl(
    config_path,
    round_id = "2022-10-22",
    required_vals_only = TRUE,
    output_types = "sample"
  )
  expect_equal(dim(req_non_force_default), c(0L, 0L))
  # When force_output_types is not set, all output_types are optional and
  # complete_cases_only = FALSE a data.frame containing required task ID
  # values is returned, with all optional task ids and output type related
  # columns set to NA.
  expect_warning(
    {
      req_non_force <- submission_tmpl(
        config_path,
        round_id = "2022-10-22",
        required_vals_only = TRUE,
        output_types = "sample",
        complete_cases_only = FALSE
      )
    },
    "all optional values"
  ) |>
    suppressMessages()
  expect_equal(dim(req_non_force), c(4L, 9L))
  expect_equal(unique(req_non_force$output_type), NA_character_)

  # When force_output_types is TRUE, the requested output type should be
  # returned.
  expect_warning(
    {
      req_force <- submission_tmpl(
        config_path,
        round_id = "2022-10-22",
        required_vals_only = TRUE,
        force_output_types = TRUE,
        output_types = "sample",
        complete_cases_only = FALSE
      )
    },
    "all optional values"
  ) |>
    suppressMessages()
  expect_equal(dim(req_force), c(4L, 9L))
  expect_equal(unique(req_force$output_type), "sample")
})

test_that("submission_tmpl works with URLs as inputs", {
  skip_if_offline()

  gh_repo_tmpl <- submission_tmpl(
    path = "https://github.com/hubverse-org/example-simple-forecast-hub",
    round_id = "2022-11-28",
    output_types = "quantile"
  )
  expect_s3_class(gh_repo_tmpl, "tbl_df")
  expect_equal(dim(gh_repo_tmpl), c(26082L, 7L))

  config_raw_url <- paste0(
    "https://raw.githubusercontent.com/hubverse-org/",
    "example-simple-forecast-hub/refs/heads/main/hub-config/tasks.json"
  )
  gh_config_tmpl <- submission_tmpl(
    path = config_raw_url,
    round_id = "2022-11-28",
    output_types = "quantile"
  )
  expect_equal(gh_config_tmpl, gh_repo_tmpl)

  md_raw_url <- paste0(
    "https://raw.githubusercontent.com/hubverse-org/",
    "example-simple-forecast-hub/refs/heads/main/README.md"
  )
  expect_error(
    submission_tmpl(
      path = md_raw_url,
      round_id = "2022-11-28",
      output_types = "quantile"
    ),
    regexp = "is not a JSON file."
  )
  expect_error(
    submission_tmpl(
      path = "https://github.com/hubverse-org/random-repo",
      round_id = "2022-11-28",
      output_types = "quantile"
    ),
    regexp = "is invalid or unreachable"
  )

  expect_error(
    submission_tmpl(
      path = "https://github.com/hubverse-org/schemas/tree/main/v5.0.0",
      round_id = "2022-11-28",
      output_types = "quantile"
    ),
    regexp = "is.*invalid.*URL to the repository root directory"
  )

  # TODO: Handle exception of file without extension being interpreted as directory
  # explicitly
  expect_error(
    submission_tmpl(
      path = "https://raw.githubusercontent.com/hubverse-org/hubValidations/refs/heads/main/LICENSE",
      round_id = "2022-11-28",
      output_types = "quantile"
    ),
    regexp = "is invalid or unreachable."
  )
})

test_that("submission_tmpl works with SubTreeFileSystems", {
  skip_if_offline()

  s3_hub_path <- arrow::s3_bucket("hubverse/hubutils/testhubs/simple/")
  s3_hub_tmpl <- submission_tmpl(
    path = s3_hub_path,
    round_id = "2022-10-01",
    output_types = "quantile"
  ) |>
    suppressMessages()

  expect_s3_class(s3_hub_tmpl, "tbl_df")
  expect_equal(dim(s3_hub_tmpl), c(4968L, 7L))

  # Use `path()` method to create a path to the tasks.json file relative to the
  # the S3 cloud hub's root directory
  s3_config_path <- s3_hub_path$path("hub-config/tasks.json")
  s3_config_tmpl <- submission_tmpl(
    path = s3_config_path,
    round_id = "2022-10-01",
    output_types = "quantile"
  ) |>
    suppressMessages()

  expect_equal(s3_config_tmpl, s3_hub_tmpl)

  s3_error_path <- s3_hub_path$path("random.json")
  expect_error(
    submission_tmpl(
      path = s3_error_path,
      round_id = "2022-11-28",
      output_types = "quantile"
    ),
    regexp = "does not.*exist."
  )

  base_path <- "model-output/hub-baseline/2022-10-01-hub-baseline.csv"
  s3_ext_error_path <- s3_hub_path$path(base_path)
  expect_error(
    submission_tmpl(
      path = s3_ext_error_path,
      round_id = "2022-11-28",
      output_types = "quantile"
    ),
    regexp = "is not a JSON file"
  )
})

test_that("submission_tmpl handles an empty compound_taskid_set", {
  hub_path <- empty_cts_hub()

  # No compound task IDs means the modeling task is a single compound modeling task,
  # so the template carries one sample covering every task ID value combination.
  expect_no_warning(
    tmpl <- submission_tmpl(hub_path, round_id = "2022-10-22")
  )
  spl <- tmpl[tmpl$output_type == "sample", ]
  task_ids <- setdiff(names(spl), c(hubUtils::std_colnames, "value"))

  expect_equal(dplyr::n_distinct(spl$output_type_id), 1L)
  expect_equal(nrow(spl), nrow(unique(spl[, task_ids])))
})
