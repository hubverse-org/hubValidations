test_that("submission_tmpl works correctly with path to hub", {
  hub_path <- system.file("testhubs/flusight", package = "hubUtils")

  expect_snapshot(str(
    submission_tmpl(hub_path,
      round_id = "2023-01-30"
    )
  ))

  expect_snapshot(str(
    submission_tmpl(hub_path,
      round_id = "2023-01-16"
    )
  ))
  expect_equal(
    unique(suppressMessages(
      submission_tmpl(
        hub_path,
        round_id = "2022-12-19"
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )

  expect_snapshot(str(
    submission_tmpl(
      hub_path,
      round_id = "2023-01-16",
      required_vals_only = TRUE
    )
  ))
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


  expect_snapshot(str(
    submission_tmpl(
      hub_path,
      round_id = "2023-01-16",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))

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

  expect_snapshot(str(
    submission_tmpl(
      hub_path,
      round_id = "2022-10-01"
    )
  ))

  expect_snapshot(str(
    submission_tmpl(
      hub_path,
      round_id = "2022-10-01",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))
  expect_snapshot(str(
    submission_tmpl(
      hub_path,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))


  expect_snapshot(str(
    submission_tmpl(
      hub_path,
      round_id = "2022-10-29",
      required_vals_only = TRUE
    )
  ))
})

test_that("submission_tmpl works correctly with path to task config file", {
  config_path <- system.file("config", "tasks.json",
    package = "hubValidations"
  )
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26"
    )
  )

  hub_path <- system.file("testhubs/flusight", package = "hubUtils")
  config_path <- file.path(hub_path, "hub-config", "tasks.json")
  expect_equal(
    submission_tmpl(hub_path,
      round_id = "2023-01-30"
    ),
    submission_tmpl(config_path,
      round_id = "2023-01-30"
    )
  )
})


test_that("submission_tmpl works correctly with deprecated args", {
  withr::local_options(lifecycle_verbosity = "quiet")
  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )

  expect_snapshot(str(
    submission_tmpl(
      hub_con = hub_con,
      round_id = "2023-01-30"
    )
  ))

  # Using config_tasks instead of hub_con
  expect_snapshot(
    submission_tmpl(
      config_tasks = read_config_file(system.file("config", "tasks.json",
        package = "hubValidations"
      )),
      round_id = "2022-12-26"
    )
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

  config_path <- system.file("config", "tasks-comp-tid.json",
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
  config_path <- system.file("config", "tasks-comp-tid.json",
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
  config_path <- system.file("config", "tasks-comp-tid.json",
    package = "hubValidations"
  )
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26"
    )
  )
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26"
    ) %>%
      dplyr::filter(.data$output_type == "sample")
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
    ) %>%
      dplyr::filter(.data$output_type == "sample")
  )

  # Override config compound task ID structure
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26",
      compound_taskid_set = list(
        c("forecast_date", "target"),
        NULL
      )
    )
  )

  # Check that everything works with a single compound_taskid_set column
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26",
      compound_taskid_set = list(
        c("forecast_date"),
        NULL
      )
    )
  )

  # Check that a list with `NULL` compound_taskid_set specification results in
  # all task ids being included in the compound_taskid_set
  expect_snapshot(
    submission_tmpl(
      config_path,
      round_id = "2022-12-26",
      compound_taskid_set = list(
        NULL,
        NULL
      )
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
  expect_snapshot(
    submission_tmpl(
      hub_path,
      round_id = "2022-10-22",
      output_types = "sample",
      derived_task_ids = "target_end_date",
      complete_cases_only = FALSE
    )
  )
})


test_that("submission_tmpl force_output_types works", {
  config_path <- test_path(
    "testdata", "configs",
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
  ) |> suppressMessages()
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
  ) |> suppressMessages()
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
  ) |> suppressMessages()

  expect_s3_class(s3_hub_tmpl, "tbl_df")
  expect_equal(dim(s3_hub_tmpl), c(4968L, 7L))

  # Use `path()` method to create a path to the tasks.json file relative to the
  # the S3 cloud hub's root directory
  s3_config_path <- s3_hub_path$path("hub-config/tasks.json")
  s3_config_tmpl <- submission_tmpl(
    path = s3_config_path,
    round_id = "2022-10-01",
    output_types = "quantile"
  ) |> suppressMessages()

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
