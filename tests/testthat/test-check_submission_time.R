test_that("resolve_hub_timezone keeps a timezone the system recognises", {
  expect_equal(resolve_hub_timezone("America/New_York"), "America/New_York")

  local_mocked_bindings(
    tz_recognised = function(tz) tz %in% c("America/New_York", "US/Eastern")
  )
  expect_equal(resolve_hub_timezone("US/Eastern"), "US/Eastern")
})

test_that("resolve_hub_timezone maps a legacy name the system lacks", {
  local_mocked_bindings(
    tz_recognised = function(tz) {
      tz %in% c("America/New_York", "America/Vancouver")
    }
  )
  expect_equal(resolve_hub_timezone("US/Eastern"), "America/New_York")
  expect_equal(resolve_hub_timezone("Canada/Pacific"), "America/Vancouver")
})

test_that("resolve_hub_timezone errors for an unrecognised timezone", {
  expect_snapshot(resolve_hub_timezone("Mars/Olympus_Mons"), error = TRUE)

  # A legacy name whose canonical name the system also lacks.
  local_mocked_bindings(tz_recognised = function(tz) FALSE)
  expect_snapshot(resolve_hub_timezone("Canada/Pacific"), error = TRUE)
})

test_that("submission window uses the canonical name of a legacy timezone", {
  # The simple test hub sets US/Eastern.
  local_mocked_bindings(tz_recognised = function(tz) tz == "America/New_York")
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"

  expect_equal(
    get_submission_window(hub_path, file_path, ref_date_from = "file_path"),
    lubridate::interval(
      as.POSIXct("2022-10-02 00:00:00", tz = "America/New_York"),
      as.POSIXct("2022-10-09 23:59:59", tz = "America/New_York")
    )
  )
  # The window closed in 2022, so the check fails rather than erroring.
  res <- check_submission_time(hub_path, file_path)
  expect_s3_class(
    res,
    c("check_failure", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )
  expect_equal(res$where, file_path)
})
