test_that("opt_check_metadata_team_max_model_n works", {
  hub_path <- system.file("testhubs/flusight", package = "hubValidations")

  expect_snapshot(
    opt_check_metadata_team_max_model_n(
      hub_path = hub_path,
      file_path = "hub-baseline.yml"
    )
  )

  expect_snapshot(
    opt_check_metadata_team_max_model_n(
      hub_path = hub_path,
      file_path = "hub-baseline.yml",
      n_max = 1L
    )
  )
})
