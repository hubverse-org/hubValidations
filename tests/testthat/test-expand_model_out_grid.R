test_that("expand_model_out_grid works correctly", {
  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")

  x <- expand_model_out_grid(config_tasks, round_id = "2023-01-02")
  expect_tbl(
    x,
    n_rows = 3132L,
    types = flusight_grid_types,
    values = list(
      forecast_date = as.Date("2023-01-02"),
      location = hub_locations,
      output_type_id = flusight_output_type_ids
    ),
    # Each target has its own output types.
    counts = tibble::tibble(
      target = rep(
        c("wk ahead inc flu hosp", "wk flu hosp rate change"),
        c(4L, 2L)
      ),
      output_type = rep(c("mean", "quantile", "pmf"), each = 2L),
      horizon = rep(1:2, times = 3L),
      n = rep(c(54L, 1242L, 270L), each = 2L)
    )
  )
  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2023-01-02",
    required_vals_only = TRUE
  )
  expect_tbl(
    x,
    n_rows = 28L,
    types = c(
      forecast_date = "Date",
      horizon = "integer",
      location = "character",
      output_type = "character",
      output_type_id = "character"
    ),
    values = list(
      forecast_date = as.Date("2023-01-02"),
      horizon = 2L,
      location = "US",
      output_type = c("pmf", "quantile")
    ),
    unchecked = "output_type_id"
  )
  # Each output type holds its own required output type IDs, in config order.
  expect_equal(x$output_type, rep(c("pmf", "quantile"), c(5L, 23L)))
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

  # Specifying a round in a hub with multiple rounds
  hub_con <- hubData::connect_hub(
    system.file("testhubs/simple", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")

  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-01"
  )
  expect_tbl(
    x,
    n_rows = 5184L,
    types = simple_grid_types,
    values = list(
      origin_date = as.Date("2022-10-01"),
      target = "wk inc flu hosp",
      horizon = 1:4,
      location = hub_locations,
      output_type = c("mean", "quantile"),
      output_type_id = c(hub_quantiles, NA)
    )
  )
  # Only mean rows have no output type ID.
  expect_equal(
    dplyr::count(x, output_type, no_id = is.na(output_type_id)),
    tibble::tibble(
      output_type = c("mean", "quantile"),
      no_id = c(TRUE, FALSE),
      n = c(216L, 4968L)
    )
  )

  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-01",
    required_vals_only = TRUE
  )
  expect_tbl(
    x,
    n_rows = 23L,
    types = c(
      origin_date = "Date",
      target = "character",
      horizon = "integer",
      output_type = "character",
      output_type_id = "numeric"
    ),
    values = list(
      origin_date = as.Date("2022-10-01"),
      target = "wk inc flu hosp",
      horizon = 1L,
      output_type = "quantile",
      output_type_id = hub_quantiles
    )
  )
  expect_equal(x$output_type_id, hub_quantiles)
  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-29",
    required_vals_only = TRUE
  )
  expect_tbl(
    x,
    n_rows = 23L,
    types = c(
      origin_date = "Date",
      target = "character",
      horizon = "integer",
      age_group = "character",
      output_type = "character",
      output_type_id = "numeric"
    ),
    values = list(
      origin_date = as.Date("2022-10-29"),
      target = "wk inc flu hosp",
      horizon = 1L,
      age_group = "65+",
      output_type = "quantile",
      output_type_id = hub_quantiles
    )
  )
  expect_equal(x$output_type_id, hub_quantiles)
  x_chr <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-29",
    required_vals_only = TRUE,
    all_character = TRUE
  )
  expect_equal(x_chr, as_chr(x))
  expect_arrow_tbl(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      as_arrow_table = TRUE
    ),
    x,
    c(
      origin_date = "date32[day]",
      target = "string",
      horizon = "int32",
      age_group = "string",
      output_type = "string",
      output_type_id = "double"
    )
  )
  expect_arrow_tbl(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      all_character = TRUE,
      as_arrow_table = TRUE
    ),
    x_chr,
    string_types(x_chr)
  )

  x <- expand_model_out_grid(
    jsonlite::fromJSON(
      test_path(
        "testdata",
        "configs",
        "both_null_tasks.json"
      ),
      simplifyVector = TRUE,
      simplifyDataFrame = FALSE
    ),
    round_id = "2023-11-26"
  ) |>
    dplyr::filter(is.na(horizon))
  expect_tbl(
    x,
    n_rows = 24L,
    types = simple_age_grid_types,
    values = list(
      origin_date = as.Date("2023-11-26"),
      target = "peak time hosp",
      horizon = NA_integer_,
      location = c("01", "02", "US"),
      age_group = c(
        "0-0.99",
        "0-130",
        "1-4",
        "18-49",
        "5-17",
        "5-64",
        "50-64",
        "65-130"
      ),
      output_type = "cdf",
      output_type_id = 1
    )
  )

  # Swapping the order of the two model tasks gives the same rows.
  expect_equal(
    expand_model_out_grid(
      jsonlite::fromJSON(
        test_path(
          "testdata",
          "configs",
          "both_null_tasks_swap.json"
        ),
        simplifyVector = TRUE,
        simplifyDataFrame = FALSE
      ),
      round_id = "2023-11-26"
    ) |>
      dplyr::filter(is.na(horizon)),
    x
  )
})

test_that("Setting of round_id value works correctly", {
  hub_con <- hubData::connect_hub(
    system.file("testhubs/simple", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")
  expect_equal(
    unique(
      expand_model_out_grid(
        config_tasks,
        round_id = "2022-10-01"
      )$origin_date
    ),
    as.Date("2022-10-01")
  )

  expect_equal(
    unique(
      expand_model_out_grid(
        config_tasks,
        required_vals_only = TRUE,
        round_id = "2022-10-29"
      )$origin_date
    ),
    as.Date("2022-10-29")
  )

  # Test in hub with single round
  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")

  expect_equal(
    unique(
      expand_model_out_grid(
        config_tasks,
        required_vals_only = TRUE,
        round_id = "2023-01-30"
      )$forecast_date
    ),
    as.Date("2023-01-30")
  )
})


test_that("expand_model_out_grid output controls work correctly", {
  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")
  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2023-01-02",
    all_character = TRUE
  )
  expect_equal(
    x,
    as_chr(expand_model_out_grid(config_tasks, round_id = "2023-01-02"))
  )
  expect_arrow_tbl(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      all_character = TRUE,
      as_arrow_table = TRUE
    ),
    x,
    string_types(x)
  )
  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2023-01-02",
    required_vals_only = TRUE,
    all_character = TRUE
  )
  expect_equal(
    x,
    as_chr(
      expand_model_out_grid(
        config_tasks,
        round_id = "2023-01-02",
        required_vals_only = TRUE
      )
    )
  )
  expect_arrow_tbl(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      required_vals_only = TRUE,
      all_character = TRUE,
      as_arrow_table = TRUE
    ),
    x,
    string_types(x)
  )
  x_split <- expand_model_out_grid(
    config_tasks,
    round_id = "2023-01-02",
    required_vals_only = TRUE,
    all_character = TRUE,
    as_arrow_table = FALSE,
    bind_model_tasks = FALSE
  )
  expect_equal(purrr::map_int(x_split, nrow), c(5L, 23L))
  expect_equal(dplyr::bind_rows(x_split), x)
  expect_equal(unique(x_split[[1]]$output_type), "pmf")
  expect_equal(unique(x_split[[2]]$output_type), "quantile")
  expect_arrow_tbl(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      required_vals_only = TRUE,
      all_character = TRUE,
      as_arrow_table = TRUE,
      bind_model_tasks = FALSE
    ),
    x_split,
    string_types(x_split[[1]])
  )
})


test_that("expand_model_out_grid output controls with samples work correctly", {
  # Hub with sample output type
  config_tasks <- read_config_file(system.file(
    "config",
    "tasks.json",
    package = "hubValidations"
  ))

  x <- expand_model_out_grid(config_tasks, round_id = "2022-12-26")
  expect_tbl(
    x,
    n_rows = 42L,
    types = flusight_grid_types,
    values = list(
      forecast_date = as.Date("2022-12-26"),
      horizon = 1:2,
      location = c("01", "02", "US"),
      output_type_id = c(
        "decrease",
        "increase",
        "large_decrease",
        "large_increase",
        "stable",
        NA
      )
    ),
    counts = tibble::tibble(
      target = rep(
        c("wk ahead inc flu hosp", "wk flu hosp rate change"),
        c(2L, 1L)
      ),
      output_type = c("mean", "sample", "pmf"),
      n = c(6L, 6L, 30L)
    )
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE
    ) |>
      dplyr::filter(.data$output_type == "sample")
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      required_vals_only = TRUE,
      all_character = TRUE
    )
  )
  expect_warning(
    x_arrow <- expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      required_vals_only = TRUE,
      as_arrow_table = TRUE
    ),
    "compound task ID target has all optional values"
  )
  expect_warning(
    x <- expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      required_vals_only = TRUE
    ),
    "compound task ID target has all optional values"
  )
  expect_equal(
    x,
    tibble::tibble(
      forecast_date = as.Date("2022-12-26"),
      horizon = 2L,
      location = "US",
      output_type = c("sample", rep("pmf", 5L)),
      output_type_id = c(
        "s1",
        "large_decrease",
        "decrease",
        "stable",
        "increase",
        "large_increase"
      )
    )
  )
  expect_arrow_tbl(
    x_arrow,
    x,
    c(
      forecast_date = "date32[day]",
      horizon = "int32",
      location = "string",
      output_type = "string",
      output_type_id = "string"
    )
  )
  # Hub with sample output type and compound task ID structure
  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json", package = "hubValidations")
  )
  grid_spl <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-12-26",
    include_sample_ids = TRUE
  )
  x_split <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-12-26",
    include_sample_ids = TRUE,
    bind_model_tasks = FALSE
  )
  expect_length(x_split, 2L)
  expect_equal(dplyr::bind_rows(x_split), grid_spl)
  # The first modeling task's `compound_taskid_set` is `forecast_date`,
  # `target` and `horizon`, so its samples are joint across locations. Each
  # horizon gets one sample ID, shared by all three locations.
  expect_equal(
    x_split[[1]],
    tibble::tibble(
      forecast_date = as.Date("2022-12-26"),
      target = "wk ahead inc flu hosp",
      horizon = c(rep(c(2L, 1L), times = 3L), rep(c(2L, 1L), each = 3L)),
      location = c(
        rep(c("US", "01", "02"), each = 2L),
        rep(c("US", "01", "02"), times = 2L)
      ),
      output_type = rep(c("mean", "sample"), each = 6L),
      output_type_id = c(rep(NA, 6L), rep(c("1", "2"), each = 3L))
    )
  )
  # 2 horizons x 3 locations x 5 categories, so every combination is present.
  expect_tbl(
    x_split[[2]],
    n_rows = 30L,
    types = flusight_grid_types,
    values = list(
      forecast_date = as.Date("2022-12-26"),
      target = "wk flu hosp rate change",
      horizon = 1:2,
      location = c("01", "02", "US"),
      output_type = "pmf",
      output_type_id = c(
        "decrease",
        "increase",
        "large_decrease",
        "large_increase",
        "stable"
      )
    )
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      required_vals_only = TRUE
    )
  )
  # Check back-compatibility on older sample specification
  config_tasks <- read_config_file(
    test_path("testdata", "configs", "tasks-samples-old-schema.json")
  )
  x <- expand_model_out_grid(config_tasks, round_id = "2022-12-26")
  expect_tbl(
    x,
    n_rows = 66L,
    types = flusight_grid_types,
    values = list(
      forecast_date = as.Date("2022-12-26"),
      horizon = 1:2,
      location = c("01", "02", "US"),
      output_type_id = c(
        as.character(1:5),
        "decrease",
        "increase",
        "large_decrease",
        "large_increase",
        "stable",
        NA
      )
    ),
    counts = tibble::tibble(
      target = rep(
        c("wk ahead inc flu hosp", "wk flu hosp rate change"),
        c(2L, 1L)
      ),
      output_type = c("mean", "sample", "pmf"),
      n = c(6L, 30L, 30L)
    )
  )
  # The old specification lists sample IDs 1 to 5 as output type IDs, so they
  # appear only on sample rows.
  expect_equal(
    purrr::map(
      split(x$output_type_id, x$output_type),
      \(id) sort(unique(id), na.last = TRUE, method = "radix")
    ),
    list(
      mean = NA_character_,
      pmf = c(
        "decrease",
        "increase",
        "large_decrease",
        "large_increase",
        "stable"
      ),
      sample = as.character(1:5)
    )
  )
  # check that included sample IDs are not generated for older versions
  # of the sample specification
  expect_equal(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      bind_model_tasks = FALSE
    )[[1]],
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = FALSE,
      bind_model_tasks = FALSE
    )[[1]]
  )

  # Check sample IDs unique across multiple modeling task groups
  expect_snapshot(
    expand_model_out_grid(
      hubUtils::read_config_file(
        test_path("testdata", "configs", "tasks-samples-2mt.json")
      ),
      round_id = "2022-12-26",
      include_sample_ids = TRUE
    ) |>
      dplyr::filter(.data$output_type == "sample")
  )

  # Override config compound_taskid_set.
  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json", package = "hubValidations")
  )
  # Create coarser samples
  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-12-26",
    include_sample_ids = TRUE,
    compound_taskid_set = list(
      c("forecast_date", "target"),
      NULL
    )
  )
  expect_spl_override(x, grid_spl, spl_ids = rep("1", 6L))
  # Create finer samples
  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-12-26",
    include_sample_ids = TRUE,
    compound_taskid_set = list(
      c("forecast_date", "target", "horizon", "location"),
      NULL
    )
  )
  expect_spl_override(x, grid_spl, spl_ids = as.character(1:6))
  # Create samples with full compound_taskid_set
  x <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-12-26",
    include_sample_ids = TRUE,
    compound_taskid_set = list(
      NULL,
      NULL
    )
  )
  expect_spl_override(x, grid_spl, spl_ids = as.character(1:6))
})


test_that("expand_model_out_grid output type subsetting works", {
  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json", package = "hubValidations")
  )
  x_split <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-12-26",
    include_sample_ids = TRUE,
    bind_model_tasks = FALSE,
    output_types = c("pmf", "sample"),
  )
  expect_equal(
    purrr::map(x_split, ~ unique(.x$output_type)),
    list("sample", "pmf")
  )
  expect_equal(purrr::map_int(x_split, nrow), c(6L, 30L))
  expect_equal(
    dplyr::bind_rows(x_split),
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE
    ) |>
      dplyr::filter(.data$output_type %in% c("pmf", "sample"))
  )

  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      bind_model_tasks = FALSE,
      output_types = "sample",
    )
  )

  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      bind_model_tasks = TRUE,
      output_types = "sample",
    )
  )

  # If a valid output type is provided, invalid ones just ignored
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = FALSE,
      bind_model_tasks = TRUE,
      output_types = c("random", "sample"),
    ),
    error = TRUE
  )

  # If no valid output type provided, errors
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = FALSE,
      bind_model_tasks = FALSE,
      output_types = c("random"),
    ),
    error = TRUE
  )
})

test_that("force_output_types works as expected with v4", {
  # Try with v4 config where samples are optional
  config_tasks <- read_config_file(
    test_path(
      "testdata",
      "configs",
      "tasks-samples-v4.json"
    )
  )
  # test optional samples ----
  # Without forcing output_types should be list of zero dim tbls
  v4_opt_spls <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-22",
    include_sample_ids = FALSE,
    bind_model_tasks = FALSE,
    output_types = "sample",
    derived_task_ids = "target_end_date",
    required_vals_only = TRUE,
    force_output_types = FALSE
  )
  expect_equal(purrr::map(v4_opt_spls, dim), list(c(0L, 0L), c(0L, 0L)))
  # With forcing, a grid that includes sample output type ids as required.

  v4_opt_spls_force <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-22",
    include_sample_ids = FALSE,
    bind_model_tasks = FALSE,
    output_types = "sample",
    derived_task_ids = "target_end_date",
    required_vals_only = TRUE,
    force_output_types = TRUE
  )
  expect_snapshot(v4_opt_spls_force)

  # With forcing, ensure include_sample_ids still works and issues compound_idx
  # warning.
  v4_opt_spls_force_spl_idx <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-22",
    include_sample_ids = TRUE,
    bind_model_tasks = FALSE,
    output_types = "sample",
    derived_task_ids = "target_end_date",
    required_vals_only = TRUE,
    force_output_types = TRUE
  ) |>
    suppressWarnings()
  expect_snapshot(v4_opt_spls_force_spl_idx)

  # test optional point estimate - median ----
  # Without forcing output_types should be list of zero dim tbls
  v4_opt_mdn <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-22",
    include_sample_ids = FALSE,
    bind_model_tasks = FALSE,
    output_types = "median",
    derived_task_ids = "target_end_date",
    required_vals_only = TRUE,
    force_output_types = FALSE
  )
  expect_equal(purrr::map(v4_opt_mdn, dim), list(c(0L, 0L), c(0L, 0L)))
  # With forcing, a grid that includes median output type ids as required.
  v4_opt_mdn_force <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-10-22",
    include_sample_ids = FALSE,
    bind_model_tasks = FALSE,
    output_types = "median",
    derived_task_ids = "target_end_date",
    required_vals_only = TRUE,
    force_output_types = TRUE
  )
  expect_snapshot(v4_opt_mdn_force)

  # test optional output type with output type IDs - quantile ----
  config_tasks <- read_config(system.file(
    "testhubs",
    "v4",
    "flusight",
    package = "hubUtils"
  ))
  # Without forcing output_types, should be list of zero dim tbls
  v4_opt_qntl <- expand_model_out_grid(
    config_tasks,
    round_id = "2023-04-24",
    include_sample_ids = FALSE,
    bind_model_tasks = FALSE,
    output_types = "quantile",
    required_vals_only = TRUE,
    force_output_types = FALSE
  )
  expect_equal(purrr::map(v4_opt_qntl, dim), list(c(0L, 0L), c(0L, 0L)))
  # With forcing, a grid that includes quantile output type ids as required.
  v4_opt_qntl_force <- expand_model_out_grid(
    config_tasks,
    round_id = "2023-04-24",
    include_sample_ids = FALSE,
    bind_model_tasks = FALSE,
    output_types = "quantile",
    required_vals_only = TRUE,
    force_output_types = TRUE
  )
  expect_length(v4_opt_qntl_force, 2L)
  expect_equal(dim(v4_opt_qntl_force[[1]]), c(0L, 0L))
  expect_tbl(
    v4_opt_qntl_force[[2]],
    n_rows = 23L,
    types = c(
      forecast_date = "Date",
      horizon = "integer",
      location = "character",
      output_type = "character",
      output_type_id = "character"
    ),
    values = list(
      forecast_date = as.Date("2023-04-24"),
      horizon = 2L,
      location = "US",
      output_type = "quantile"
    ),
    unchecked = "output_type_id"
  )
  expect_equal(
    v4_opt_qntl_force[[2]]$output_type_id,
    as.character(hub_quantiles)
  )
  # test with all output types ----
  v4_req_only <- expand_model_out_grid(
    config_tasks,
    round_id = "2023-04-24",
    include_sample_ids = FALSE,
    bind_model_tasks = TRUE,
    required_vals_only = TRUE,
    force_output_types = FALSE
  )
  expect_snapshot(v4_req_only)
  # With forcing, a grid that includes quantile output type ids as required.
  v4_force_all <- expand_model_out_grid(
    config_tasks,
    round_id = "2023-04-24",
    include_sample_ids = FALSE,
    bind_model_tasks = TRUE,
    required_vals_only = TRUE,
    force_output_types = TRUE
  )
  expect_tbl(
    v4_force_all,
    n_rows = 29L,
    types = c(
      forecast_date = "Date",
      horizon = "integer",
      location = "character",
      output_type = "character",
      output_type_id = "character"
    ),
    values = list(
      forecast_date = as.Date("2023-04-24"),
      horizon = 2L,
      location = "US",
      output_type = c("mean", "pmf", "quantile")
    ),
    unchecked = "output_type_id"
  )
  expect_equal(
    v4_force_all$output_type,
    rep(c("pmf", "quantile", "mean"), c(5L, 23L, 1L))
  )
  expect_equal(
    v4_force_all$output_type_id,
    c(
      "large_decrease",
      "decrease",
      "stable",
      "increase",
      "large_increase",
      as.character(hub_quantiles),
      NA
    )
  )
})
test_that("force_output_types works as expected with v3", {
  # Test behaviour with v3 config where median is optional
  v3_config_tasks <- read_config(test_path("testdata", "hub-spl"))
  v3_req <- expand_model_out_grid(
    v3_config_tasks,
    round_id = "2022-10-22",
    include_sample_ids = FALSE,
    bind_model_tasks = TRUE,
    output_types = "median",
    derived_task_ids = "target_end_date",
    required_vals_only = TRUE
  )
  expect_equal(dim(v3_req), c(0L, 0L))

  v3_forced <- expand_model_out_grid(
    v3_config_tasks,
    round_id = "2022-10-22",
    include_sample_ids = FALSE,
    bind_model_tasks = TRUE,
    output_types = "median",
    derived_task_ids = "target_end_date",
    required_vals_only = TRUE,
    force_output_types = TRUE
  )

  expect_equal(dim(v3_forced), c(4L, 5L))
  expect_snapshot(v3_forced)

  v3_forced_all <- expand_model_out_grid(
    v3_config_tasks,
    round_id = "2022-10-22",
    include_sample_ids = FALSE,
    bind_model_tasks = TRUE,
    derived_task_ids = "target_end_date",
    required_vals_only = TRUE,
    force_output_types = TRUE
  )

  expect_equal(dim(v3_forced_all), c(20L, 5L))
  expect_snapshot(v3_forced_all)
})

test_that("expand_model_out_grid derived_task_ids ignoring works", {
  config_tasks <- read_config(test_path("testdata", "hub-spl"))

  # The derived task ID is left NA.
  expect_tbl(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-22",
      include_sample_ids = FALSE,
      bind_model_tasks = TRUE,
      output_types = "sample",
      derived_task_ids = "target_end_date"
    ),
    n_rows = 80L,
    types = c(
      reference_date = "Date",
      target = "character",
      horizon = "integer",
      location = "character",
      variant = "character",
      target_end_date = "Date",
      output_type = "character",
      output_type_id = "character"
    ),
    values = list(
      reference_date = as.Date("2022-10-22"),
      target = "wk inc flu hosp",
      horizon = 0:3,
      location = c("01", "02", "04", "05", "US"),
      variant = c("AA", "BB", "CC", "DD"),
      target_end_date = as.Date(NA),
      output_type = "sample",
      output_type_id = NA_character_
    )
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-22",
      include_sample_ids = TRUE,
      bind_model_tasks = TRUE,
      output_types = "sample",
      derived_task_ids = "target_end_date",
      required_vals_only = TRUE
    )
  )

  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-22",
      include_sample_ids = FALSE,
      bind_model_tasks = FALSE,
      output_types = "sample",
      derived_task_ids = c("location", "variant")
    ),
    error = TRUE
  )
})


test_that("expand_model_out_grid errors correctly", {
  # Specifying a round in a hub with multiple rounds
  hub_con <- hubData::connect_hub(
    system.file("testhubs/simple", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")

  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "random_round_id"
    ),
    error = TRUE
  )
  expect_snapshot(
    expand_model_out_grid(config_tasks),
    error = TRUE
  )

  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")

  expect_snapshot(
    expand_model_out_grid(config_tasks),
    error = TRUE
  )

  # TODO: re-snapshot when error better handled by create_hub_schema
  # when all horizon properties are null
  expect_snapshot(
    expand_model_out_grid(
      jsonlite::fromJSON(
        test_path(
          "testdata",
          "configs",
          "both_null_tasks_all.json"
        ),
        simplifyVector = TRUE,
        simplifyDataFrame = FALSE
      ),
      round_id = "2023-11-26"
    ) |>
      dplyr::filter(is.na(horizon)),
    error = TRUE
  )

  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json", package = "hubValidations")
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      compound_taskid_set = list(
        c("forecast_date", "target", "random_var"),
        NULL
      )
    ),
    error = TRUE
  )

  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      compound_taskid_set = list(
        c("forecast_date", "target")
      )
    ),
    error = TRUE
  )

  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      compound_taskid_set = list()
    ),
    error = TRUE
  )
})

test_that("(#123) expand_model_task_grid() returns expected outputs with optional output_type_id", {
  tasks <- list(
    nowcast_date = "2024-10-02",
    target_date = NULL,
    clade = c("24A", "24B", "recombinant", "other"),
    other_task = 1:2,
    location = NULL
  )
  # If specific output type subset is requested
  i_have_no_rows <- expand_model_task_grid(
    task_id_values = tasks,
    output_type_values = list(),
    all_output_types = FALSE
  )
  expect_equal(nrow(i_have_no_rows), 0)
  expect_equal(ncol(i_have_no_rows), 0)

  # When no specific output_type subset is requested
  i_have_eight_rows <- expand_model_task_grid(
    task_id_values = tasks,
    output_type_values = list(),
    all_output_types = TRUE
  )
  expect_equal(nrow(i_have_eight_rows), 8)
  expect_equal(ncol(i_have_eight_rows), 3)
})

test_that("v4 point estimate output type IDs extracted correctly as NAs", {
  hub_path <- system.file("testhubs", "v4", "flusight", package = "hubUtils")
  file_name <- "hub-baseline/2023-05-01-hub-baseline.csv"
  round_id <- parse_file_name(file_name)$round_id
  config_tasks <- read_config(hub_path = hub_path)

  point_est_grid <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = "mean",
  )
  expect_type(point_est_grid$output_type_id, "character")
  expect_equal(unique(point_est_grid$output_type_id), NA_character_)
})

test_that("v4 required output type ID values extracted correctly", {
  hub_path <- system.file("testhubs", "v4", "flusight", package = "hubUtils")
  file_name <- "hub-baseline/2023-05-01-hub-baseline.csv"
  round_id <- parse_file_name(file_name)$round_id
  config_tasks <- read_config(hub_path = hub_path)

  x <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = "pmf",
    derived_task_ids = get_hub_derived_task_ids(hub_path)
  )
  expect_tbl(
    x,
    n_rows = 540L,
    types = c(
      forecast_date = "Date",
      target = "character",
      horizon = "integer",
      target_date = "Date",
      location = "character",
      output_type = "character",
      output_type_id = "character"
    ),
    values = list(
      forecast_date = as.Date("2023-05-01"),
      target = "wk flu hosp rate change",
      horizon = 1:2,
      target_date = as.Date(NA),
      location = hub_locations,
      output_type = "pmf",
      output_type_id = c(
        "decrease",
        "increase",
        "large_decrease",
        "large_increase",
        "stable"
      )
    )
  )

  expect_equal(
    dim(
      expand_model_out_grid(
        config_tasks = config_tasks,
        round_id = round_id,
        output_types = "pmf",
        required_vals_only = TRUE
      )
    ),
    c(0L, 0L)
  )

  force_pmf <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = "pmf",
    required_vals_only = TRUE,
    force_output_types = TRUE
  )
  expect_equal(
    force_pmf,
    tibble::tibble(
      forecast_date = as.Date("2023-05-01"),
      horizon = 2L,
      location = "US",
      output_type = "pmf",
      output_type_id = c(
        "large_decrease",
        "decrease",
        "stable",
        "increase",
        "large_increase"
      )
    )
  )
})

test_that("expand_model_out_grid leaves out task IDs a modeling task does not list", {
  # Only the second modeling task lists `age_group`.
  config_tasks <- read_config_file(
    test_path("testdata", "configs", "tasks-samples-tid-from-sample.json")
  )
  grids <- expand_model_out_grid(
    config_tasks,
    round_id = "2022-12-12",
    bind_model_tasks = FALSE
  )
  expect_named(
    grids[[1]],
    c(
      "forecast_date",
      "target",
      "horizon",
      "location",
      "output_type",
      "output_type_id"
    )
  )
  expect_true("age_group" %in% names(grids[[2]]))
})

test_that("expand_model_out_grid treats a derived task ID the first modeling task does not list as derived", {
  config_tasks <- read_config(test_path("testdata/hub-177"))
  config_tasks$rounds[[1]]$model_tasks[[1]]$task_ids$target_end_date <- NULL
  round_id <- hubUtils::get_round_ids(config_tasks)[1]

  grid <- expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    derived_task_ids = "target_end_date"
  )
  expect_true(all(is.na(grid$target_end_date)))
})
