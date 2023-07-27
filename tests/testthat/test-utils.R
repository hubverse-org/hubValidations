test_that("get_hub_file_formats works", {
  expect_snapshot(
    get_hub_file_formats(
      hub_path = system.file("testhubs/simple", package = "hubValidations"),
      round_id = "2022-10-08"
    )
  )
  expect_snapshot(
    get_hub_file_formats(
      hub_path = system.file("testhubs/flusight", package = "hubUtils"),
      round_id = "2023-01-30"
    )
  )
})

test_that("get_hub_timezone works", {
  expect_snapshot(
    get_hub_timezone(
      hub_path = system.file("testhubs/simple", package = "hubValidations")
    )
  )
})

test_that("get_hub_model_output_dir works", {
  expect_snapshot(
    get_hub_model_output_dir(
      hub_path = system.file("testhubs/simple", package = "hubValidations")
    )
  )
  expect_snapshot(
    get_hub_model_output_dir(
      hub_path = system.file("testhubs/flusight", package = "hubUtils")
    )
  )
})

test_that("full_file_path works", {
  path_simple <- full_file_path(
    hub_path = system.file("testhubs/simple", package = "hubValidations"),
    file_path = "test/file.csv"
  )
  expect_equal(
    fs::path("hubUtils/testhubs/simple/model-output/test/file.csv"),
    # test portable version of path
    gsub("^.*library/", "", path_simple)
  )

  path_flusight <- full_file_path(
    hub_path = system.file("testhubs/flusight", package = "hubUtils"),
    file_path = "test/file.csv"
  )
  expect_equal(
    fs::path("hubUtils/testhubs/flusight/forecasts/test/file.csv"),
    # test portable version of path
    gsub("^.*library/", "", path_flusight)
  )
})

test_that("get_file_round_id works", {
    expect_equal(
        get_file_round_id(
            file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ),
        "2022-10-08"
    )
    expect_snapshot(
        get_file_round_id(
            file_path = "team1-goodmodel/2022-10-08-team-1-goodmodel.csv"
        ),
        error = TRUE
    )
})

test_that("get_file_* utils work", {
    expect_equal(
        get_file_round_idx(
            file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
            hub_path = system.file("testhubs/simple", package = "hubValidations")
        ),
        1L
    )
    expect_equal(
        get_file_round_idx(
            file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
            hub_path = system.file("testhubs/simple", package = "hubValidations")
        ),
        2L
    )

    expect_snapshot(
        get_file_round_config(
            file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
            hub_path = system.file("testhubs/simple", package = "hubValidations")
        )
    )

    expect_true(
        is_round_id_from_variable(
            file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
            hub_path = system.file("testhubs/simple", package = "hubValidations")
        )
    )

})
