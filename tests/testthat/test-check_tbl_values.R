test_that("values are validated as they were through the grid", {
  for (fixture in values_fixtures()) {
    variants <- values_variants(fixture)
    for (variant in names(variants)) {
      info <- paste(fixture[["hub_path"]], variant)
      res <- call_with_fixture(check_tbl_values, variants[[variant]], fixture)

      # The comparison below says nothing unless the altered tables fail, and a
      # value no modeling task allows must fail whatever the hub looks like.
      if (startsWith(variant, "invalid_")) {
        expect_true(inherits(res, "check_error"), info = info)
      }
      expect_equal(
        without_call(res),
        without_call(
          call_with_fixture(
            check_tbl_values_via_grid,
            variants[[variant]],
            fixture
          )
        ),
        info = info
      )
    }
  }
})

test_that("check_tbl_values reports an output type the round does not define", {
  # The grid this replaced was built one output type at a time, so a value that
  # named no output type stopped the check before it could report it.
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  round_id <- "2022-10-08"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  tbl_chr[1, "output_type"] <- "sample"

  expect_snapshot(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )
})

test_that("check_tbl_values works", {
  hub_path <- system.file("testhubs/simple", package = "hubValidations")
  file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
  round_id <- "2022-10-08"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )

  tbl_chr[1, "horizon"] <- "11"
  expect_snapshot(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )
})


# nolint start: line_length_linter
test_that("check_tbl_values consistent across numeric & character output type id columns & does not ignore trailing zeros", {
  # nolint end
  # Hub with both character & numeric output type ids & trailing zeros in
  # numeric output type id
  hub_path <- test_path("testdata/hub-chr")
  # File with both character & numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` as well as by `arrow::cast`.
  # Also contains trailing zeros.
  file_path <- "UMass-gbq/2023-10-28-UMass-gbq.csv"
  round_id <- "2023-10-28"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  expect_s3_class(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` as well as by `arrow::cast`.
  file_path <- "UMass-gbq/2023-11-04-UMass-gbq.csv"
  round_id <- "2023-11-04"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  file_path <- "UMass-gbq/2023-11-11-UMass-gbq.csv"
  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` but not by `arrow::cast`
  round_id <- "2023-11-11"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  # Hub with only numeric output type ids ----
  hub_path <- test_path("testdata/hub-num")
  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` as well as by `arrow::cast`.
  file_path <- "UMass-gbq/2023-11-04-UMass-gbq.csv"
  round_id <- "2023-11-04"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` as well as by `arrow::cast`.
  # Also contains trailing zeros
  file_path <- "UMass-gbq/2023-10-28-UMass-gbq.csv"
  round_id <- "2023-10-28"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )

  expect_s3_class(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )

  # File with only numeric output type ids.
  # Contains Number that is coerced
  # to 0.1 by `as.character` but not by `arrow::cast`
  file_path <- "UMass-gbq/2023-11-11-UMass-gbq.csv"
  round_id <- "2023-11-11"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ),
    c("check_error", "hub_check", "rlang_error", "error", "condition"),
    exact = TRUE
  )
})

test_that("check_tbl_values works with v3 spec samples", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_snapshot(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )

  tbl_chr[
    utils::head(which(tbl_chr$output_type == "sample"), 2),
    "horizon"
  ] <- c(
    "11",
    "12"
  )
  expect_snapshot(
    check_tbl_values(
      tbl_chr = tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    )
  )
})


test_that("check_tbl_values validates derived task ID values", {
  # `target_end_date` is derived from `reference_date` and `horizon`, and the
  # config declares it as derived.
  hub_path <- test_path("testdata/hub-177")
  file_path <- "FluSight-baseline/2024-12-14-FluSight-baseline.parquet"
  round_id <- "2024-12-14"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  expect_s3_class(
    check_tbl_values(tbl_chr, round_id, file_path, hub_path),
    "check_success"
  )

  # A date the config does not list. Two of the modeling tasks allow only `NA`
  # in `target_end_date`, so pick a row from one that lists dates.
  row <- which(!is.na(tbl_chr$target_end_date))[1L]
  tbl_chr[row, "target_end_date"] <- "2092-10-22"
  expect_snapshot(
    check_tbl_values(tbl_chr, round_id, file_path, hub_path)
  )

  # A value only another modeling task allows. The modeling tasks without a
  # horizon allow `NA` alone in `target_end_date`, and the row's own modeling
  # task does not allow `NA`, so no modeling task matches the row. Skipping
  # the column when matching would let the row pass.
  tbl_chr[row, "target_end_date"] <- NA_character_
  expect_snapshot(
    check_tbl_values(tbl_chr, round_id, file_path, hub_path)
  )
})

test_that("check_tbl_values(derived_task_ids) is deprecated and has no effect", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  tbl_chr[1, "target_end_date"] <- "random_date"

  lifecycle::expect_deprecated(
    res <- check_tbl_values(
      tbl_chr,
      round_id,
      file_path,
      hub_path,
      derived_task_ids = "target_end_date"
    )
  )
  expect_equal(
    res,
    check_tbl_values(tbl_chr, round_id, file_path, hub_path)
  )
})
