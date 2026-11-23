test_that("validate_derived_task_ids keeps a derived task ID the first modeling task does not list", {
  config_tasks <- read_config(test_path("testdata/hub-177"))
  config_tasks$rounds[[1]]$model_tasks[[1]]$task_ids$target_end_date <- NULL
  round_id <- hubUtils::get_round_ids(config_tasks)[1]

  expect_equal(
    validate_derived_task_ids("target_end_date", config_tasks, round_id),
    "target_end_date"
  )
})
