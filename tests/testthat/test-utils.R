test_that("abs_file_path works", {
  path_simple <- abs_file_path(
    hub_path = system.file("testhubs/simple", package = "hubValidations"),
    file_path = "test/file.csv"
  )
  expect_equal(
    fs::path("simple/model-output/test/file.csv"),
    # test portable version of path
    gsub("^.*testhubs/", "", path_simple)
  )

  path_flusight <- abs_file_path(
    hub_path = system.file("testhubs/flusight", package = "hubUtils"),
    file_path = "test/file.csv"
  )
  expect_equal(
    fs::path("flusight/forecasts/test/file.csv"),
    # test portable version of path
    gsub("^.*testhubs/", "", path_flusight)
  )
})

test_that("rel_file_path works", {
  path_simple <- rel_file_path(
    hub_path = system.file("testhubs/simple", package = "hubValidations"),
    file_path = "test/file.csv"
  )
  expect_equal(
    fs::path("model-output/test/file.csv"),
    path_simple
  )

  path_flusight <- rel_file_path(
    hub_path = system.file("testhubs/flusight", package = "hubUtils"),
    file_path = "test/file.csv"
  )
  expect_equal(
    fs::path("forecasts/test/file.csv"),
    path_flusight
  )
})

test_that("rel_file_path works when hub_path included in file_path", {
  hub_path <- hubutils_target_file_hub()
  target_path <- hubData::get_target_path(hub_path, "time-series")
  expect_equal(
    rel_file_path(
      file_path = target_path,
      hub_path = hub_path,
      subdir = "target-data"
    ),
    fs::path("time-series.csv")
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

test_that("get_metadata_file_name works", {
  expect_equal(
    get_metadata_file_name(
      hub_path = system.file("testhubs/simple", package = "hubValidations"),
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
    ),
    fs::path("team1-goodmodel.yml")
  )

  expect_equal(
    get_metadata_file_name(
      hub_path = system.file("testhubs/simple", package = "hubValidations"),
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      ext = "yaml"
    ),
    fs::path("team1-goodmodel.yaml")
  )

  expect_equal(
    get_metadata_file_name(
      hub_path = system.file("testhubs/simple", package = "hubValidations"),
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      ext = "auto"
    ),
    fs::path("team1-goodmodel.yaml")
  )

  expect_error(
    get_metadata_file_name(
      hub_path = system.file("testhubs/simple", package = "hubValidations"),
      file_path = "team1-goodmodel/2022-10-08-random-goodmodel.csv",
      ext = "auto"
    )
  )

  expect_error(
    get_metadata_file_name(
      hub_path = system.file("testhubs/simple", package = "hubValidations"),
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      ext = "random_extension"
    )
  )
})
