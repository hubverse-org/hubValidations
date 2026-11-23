test_that("get_config_mt_value_sets returns NA for a null task ID stored as {}", {
  # jsonlite::toJSON() writes a null property as `{}`, which reads back as an
  # empty list rather than NULL.
  config_tasks <- read_config(test_path("testdata/hub-177"))
  config_path <- withr::local_tempfile(fileext = ".json")
  writeLines(jsonlite::toJSON(config_tasks), config_path)
  config_tasks <- read_config_file(config_path)
  round_id <- hubUtils::get_round_ids(config_tasks)[1]

  value_sets <- get_config_mt_value_sets(config_tasks, round_id)
  expect_identical(value_sets[[3]]$task_ids$horizon, NA_character_)
  expect_identical(value_sets[[3]]$task_ids$target_end_date, NA_character_)
})
