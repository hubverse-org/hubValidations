test_that("parse_file_name works", {
  expect_snapshot(
    parse_file_name(
      "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    )
  )
  expect_snapshot(
    parse_file_name(
      "model-output/team1-goodmodel/2022-10-08-team1-good_model.csv"
    )
  )
  expect_snapshot(
    parse_file_name(
      "model-output/team1-goodmodel/round_1-team1-goodmodel.parquet"
    )
  )


  expect_snapshot(
    parse_file_name(
      "hub-baseline.yml",
      file_type = "model_metadata"
    )
  )
  expect_snapshot(
    parse_file_name(
      "hubBaseline.yml",
      file_type = "model_metadata"
    ),
    error = TRUE
  )

  file_path <- "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  file_meta <- parse_file_name(file_path)
  expect_equal(
    basename(file_path),
    paste(file_meta$round_id, file_meta$model_id, sep = "-") %>%
      paste(file_meta$ext, sep = ".")
  )

  file_path <- "model-output/team1-goodmodel/round_1-team1-good_model.parquet"
  file_meta <- parse_file_name(file_path)
  expect_equal(
      basename(file_path),
      paste(file_meta$round_id, file_meta$team_abbr, file_meta$model_abbr,
            sep = "-") %>%
          paste(file_meta$ext, sep = ".")
  )


})

test_that("parse_file_name fails correctly", {
  expect_snapshot(
    parse_file_name(
      "model-output/team1-goodmodel/2022-10-08-team1_goodmodel.csv"
    ),
    error = TRUE
  )
  expect_error(
    parse_file_name(
      "model-output/team1-goodmodel/round_1-team1-good-model.parquet"
    )
  )
})
