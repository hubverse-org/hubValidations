test_that("submission_tmpl works correctly", {
  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )

  expect_snapshot(str(
    submission_tmpl(hub_con,
      round_id = "2023-01-30"
    )
  ))

  expect_snapshot(str(
    submission_tmpl(hub_con,
      round_id = "2023-01-16"
    )
  ))
  expect_equal(
    unique(suppressMessages(
      submission_tmpl(
        hub_con,
        round_id = "2022-12-19"
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )

  expect_snapshot(str(
    submission_tmpl(
      hub_con,
      round_id = "2023-01-16",
      required_vals_only = TRUE
    )
  ))
  expect_equal(
    unique(suppressMessages(
      submission_tmpl(
        hub_con,
        round_id = "2022-12-19",
        required_vals_only = TRUE,
        complete_cases_only = FALSE
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )


  expect_snapshot(str(
    submission_tmpl(
      hub_con,
      round_id = "2023-01-16",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))

  expect_equal(
    unique(suppressMessages(
      submission_tmpl(
        hub_con,
        round_id = "2022-12-19",
        required_vals_only = TRUE,
        complete_cases_only = FALSE
      )$forecast_date
    )),
    as.Date("2022-12-19")
  )

  # Specifying a round in a hub with multiple rounds
  hub_con <- hubData::connect_hub(
    system.file("testhubs/simple", package = "hubUtils")
  )

  expect_snapshot(str(
    submission_tmpl(
      hub_con,
      round_id = "2022-10-01"
    )
  ))

  expect_snapshot(str(
    submission_tmpl(
      hub_con,
      round_id = "2022-10-01",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))
  expect_snapshot(str(
    submission_tmpl(
      hub_con,
      round_id = "2022-10-29",
      required_vals_only = TRUE,
      complete_cases_only = FALSE
    )
  ))


  expect_snapshot(str(
    submission_tmpl(
      hub_con,
      round_id = "2022-10-29",
      required_vals_only = TRUE
    )
  ))

  # Hub with sample output type
  expect_snapshot(
    submission_tmpl(
      config_tasks = read_config_file(system.file("config", "tasks.json",
        package = "hubValidations"
      )),
      round_id = "2022-12-26"
    )
  )

  # Hub with sample output type and compound task ID structure
  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json",
      package = "hubValidations"
    )
  )
  expect_snapshot(
    submission_tmpl(
      config_tasks = config_tasks,
      round_id = "2022-12-26"
    )
  )
  expect_snapshot(
    submission_tmpl(
      config_tasks = config_tasks,
      round_id = "2022-12-26"
    ) %>%
      dplyr::filter(.data$output_type == "sample")
  )

  # Override config compound task ID structure
  expect_snapshot(
    submission_tmpl(
      config_tasks = config_tasks,
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
      config_tasks = config_tasks,
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
      config_tasks = config_tasks,
      round_id = "2022-12-26",
      compound_taskid_set = list(
        NULL,
        NULL
      )
    )
  )
})

test_that("submission_tmpl errors correctly", {
  # Specifying a round in a hub with multiple rounds
  hub_con <- hubData::connect_hub(system.file("testhubs/simple", package = "hubUtils"))

  expect_snapshot(
    submission_tmpl(
      hub_con,
      round_id = "random_round_id"
    ),
    error = TRUE
  )
  expect_snapshot(
    submission_tmpl(hub_con),
    error = TRUE
  )

  hub_con <- hubData::connect_hub(
    system.file("testhubs/flusight", package = "hubUtils")
  )
  expect_snapshot(
    submission_tmpl(hub_con),
    error = TRUE
  )

  expect_snapshot(
    submission_tmpl(list()),
    error = TRUE
  )

  config_tasks <- read_config_file(
    system.file("config", "tasks-comp-tid.json",
      package = "hubValidations"
    )
  )
  expect_snapshot(
    submission_tmpl(
      config_tasks = config_tasks,
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
  config_tasks <- read_config_file(system.file("config", "tasks-comp-tid.json",
    package = "hubValidations"
  ))

  # Subsetting for a single output type
  expect_snapshot(
    submission_tmpl(
      config_tasks = config_tasks,
      round_id = "2022-12-26",
      output_types = "sample"
    )
  )

  # Subsetting for a two output types
  expect_snapshot(
    submission_tmpl(
      config_tasks = config_tasks,
      round_id = "2022-12-26",
      output_types = c("mean", "sample")
    )
  )
})

test_that("submission_tmpl ignoring derived task ids works", {
  config_tasks <- read_config(test_path("testdata", "hub-spl"))

  expect_snapshot(
    submission_tmpl(
      config_tasks = config_tasks,
      round_id = "2022-10-22",
      output_types = "sample",
      derived_task_ids = "target_end_date",
      complete_cases_only = FALSE
    )
  )
})


test_that("submission_tmpl force_output_types works", {
  config_tasks <- read_config_file(
    test_path(
      "testdata", "configs",
      "tasks-samples-v4.json"
    )
  )
  # When force_output_types is not set, all output_types are optional, a
  #  zero row and column data.frame is returned  by default.
  req_non_force_default <- suppressMessages(
    suppressWarnings(
      submission_tmpl(
        config_tasks = config_tasks,
        round_id = "2022-10-22",
        required_vals_only = TRUE,
        output_types = "sample"
      )
    )
  )
  expect_equal(dim(req_non_force), c(0L, 0L))
  # When force_output_types is not set, all output_types are optional and
  # complete_cases_only = FALSE a data.frame containing required task ID
  # values is returned, with all optional task ids and output type related
  # columns set to NA.
  req_non_force <- suppressMessages(
    suppressWarnings(
      submission_tmpl(
        config_tasks = config_tasks,
        round_id = "2022-10-22",
        required_vals_only = TRUE,
        output_types = "sample",
        complete_cases_only = FALSE
      )
    )
  )
  expect_equal(dim(req_non_force), c(4L, 9L))
  expect_equal(unique(req_non_force$output_type), NA_character_)

  # When force_output_types is TRUE, the requested output type should be
  # returned.
  req_force <- suppressMessages(
    suppressWarnings(
      submission_tmpl(
        config_tasks = config_tasks,
        round_id = "2022-10-22",
        required_vals_only = TRUE,
        force_output_types = TRUE,
        output_types = "sample",
        complete_cases_only = FALSE
      )
    )
  )
  expect_equal(dim(req_force), c(4L, 9L))
  expect_equal(unique(req_force$output_type), "sample")
})
