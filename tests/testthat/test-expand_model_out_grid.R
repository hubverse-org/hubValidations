test_that("expand_model_out_grid works correctly", {
  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")

  expect_snapshot(str(
    expand_model_out_grid(config_tasks, round_id = "2023-01-02")
  ))
  expect_snapshot(str(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      required_vals_only = TRUE
    )
  ))

  # Specifying a round in a hub with multiple rounds
  hub_con <- hubData::connect_hub(
    system.file("testhubs/simple", package = "hubUtils")
  )
  config_tasks <- attr(hub_con, "config_tasks")

  expect_snapshot(str(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-01"
    )
  ))

  expect_snapshot(str(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-01",
      required_vals_only = TRUE
    )
  ))
  expect_snapshot(str(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-29",
      required_vals_only = TRUE
    )
  ))
  expect_snapshot(str(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      all_character = TRUE
    )
  ))
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      as_arrow_table = TRUE
    )
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      all_character = TRUE,
      as_arrow_table = TRUE
    )
  )

  expect_snapshot(
    str(
      expand_model_out_grid(
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
      ) %>%
        dplyr::filter(is.na(horizon))
    )
  )

  expect_snapshot(
    str(
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
      ) %>%
        dplyr::filter(is.na(horizon))
    )
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

  expect_snapshot(str(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      all_character = TRUE
    )
  ))
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      all_character = TRUE,
      as_arrow_table = TRUE
    )
  )
  expect_snapshot(str(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      required_vals_only = TRUE,
      all_character = TRUE
    )
  ))
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      required_vals_only = TRUE,
      all_character = TRUE,
      as_arrow_table = TRUE
    )
  )
  expect_snapshot(str(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      required_vals_only = TRUE,
      all_character = TRUE,
      as_arrow_table = FALSE,
      bind_model_tasks = FALSE
    )
  ))
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2023-01-02",
      required_vals_only = TRUE,
      all_character = TRUE,
      as_arrow_table = TRUE,
      bind_model_tasks = FALSE
    )
  )
})


test_that("expand_model_out_grid output controls with samples work correctly", {
  # Hub with sample output type
  config_tasks <- read_config_file(system.file(
    "config",
    "tasks.json",
    package = "hubValidations"
  ))

  expect_snapshot(
    expand_model_out_grid(config_tasks, round_id = "2022-12-26")
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE
    ) %>%
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
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      required_vals_only = TRUE,
      as_arrow_table = TRUE
    )
  )
  # Hub with sample output type and compound task ID structure
  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json", package = "hubValidations")
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      bind_model_tasks = FALSE
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
  expect_snapshot(
    expand_model_out_grid(config_tasks, round_id = "2022-12-26")
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
    ) %>%
      dplyr::filter(.data$output_type == "sample")
  )

  # Override config compound_taskid_set
  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json", package = "hubValidations")
  )
  # Create coarser samples
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      compound_taskid_set = list(
        c("forecast_date", "target"),
        NULL
      )
    )
  )
  # Create finer samples
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      compound_taskid_set = list(
        c("forecast_date", "target", "horizon", "location"),
        NULL
      )
    )
  )
  # Create samples with full compound_taskid_set
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      compound_taskid_set = list(
        NULL,
        NULL
      )
    )
  )
})


test_that("expand_model_out_grid output type subsetting works", {
  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json", package = "hubValidations")
  )
  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-12-26",
      include_sample_ids = TRUE,
      bind_model_tasks = FALSE,
      output_types = c("pmf", "sample"),
    )
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
  expect_equal(lengths(v4_opt_spls), c(0L, 0L))
  expect_snapshot(v4_opt_spls)
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
  expect_equal(lengths(v4_opt_spls), c(0L, 0L))
  expect_snapshot(v4_opt_mdn)
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
  expect_equal(lengths(v4_opt_spls), c(0L, 0L))
  expect_snapshot(v4_opt_qntl)
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
  expect_snapshot(v4_opt_qntl_force)
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
  expect_snapshot(v4_force_all)
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

  expect_snapshot(
    expand_model_out_grid(
      config_tasks,
      round_id = "2022-10-22",
      include_sample_ids = FALSE,
      bind_model_tasks = TRUE,
      output_types = "sample",
      derived_task_ids = "target_end_date"
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
    str(
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
      ) %>%
        dplyr::filter(is.na(horizon))
    ),
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

  expect_snapshot(
    expand_model_out_grid(
      config_tasks = config_tasks,
      round_id = round_id,
      output_types = "pmf",
      derived_task_ids = get_hub_derived_task_ids(hub_path)
    )
  )

  expect_length(
    expand_model_out_grid(
      config_tasks = config_tasks,
      round_id = round_id,
      output_types = "pmf",
      required_vals_only = TRUE
    ),
    0L
  )

  force_pmf <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = "pmf",
    required_vals_only = TRUE,
    force_output_types = TRUE
  )
  expect_length(force_pmf, 5L)
  expect_equal(
    force_pmf$output_type_id,
    c("large_decrease", "decrease", "stable", "increase", "large_increase")
  )
})
