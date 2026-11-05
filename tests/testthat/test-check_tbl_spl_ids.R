test_that("check_tbl_spl_ids passes valid integer and character sample IDs", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  expect_s3_class(
    check_tbl_spl_ids(tbl, "2022-10-22", file_path, hub_path),
    "check_success"
  )

  # The hub-now config sets `type` to "character" and `max_length` to 15.
  hub_path <- test_path("testdata/hub-now")
  file_path <- "UMass-HMLR/2024-10-02-UMass-HMLR.parquet"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  tbl$output_type_id <- paste0(tbl$output_type_id, "_run.sample")
  expect_equal(unique(nchar(tbl$output_type_id)), 15L)
  expect_s3_class(
    check_tbl_spl_ids(tbl, "2024-10-02", file_path, hub_path),
    "check_success"
  )
})

test_that("check_tbl_spl_ids fails sample IDs that are not non-negative integers (#406)", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  invalid <- c("s1", "1.5", "1.0", "1e3", "+1", " 1", "01", "-1", "s{id1}")
  is_spl <- tbl$output_type == "sample"
  spl_id <- tbl$output_type_id
  for (i in seq_along(invalid)) {
    tbl$output_type_id[is_spl & spl_id == as.character(i)] <- invalid[i]
  }
  tbl$output_type_id[is_spl & spl_id == "10"] <- "0"

  result <- check_tbl_spl_ids(tbl, "2022-10-22", file_path, hub_path)
  expect_s3_class(result, "check_error")
  expect_snapshot(result)
  expect_named(result$errors, "2")
  expect_equal(
    result$errors[["2"]],
    list(type = "integer", problems = list(integer = invalid))
  )
  expect_match(result$message, "\"s{id1}\"", fixed = TRUE)
})

test_that("check_tbl_spl_ids fails character sample IDs that are too long or contain disallowed characters (#406)", {
  # The hub-now config sets `type` to "character" and `max_length` to 15.
  hub_path <- test_path("testdata/hub-now")
  file_path <- "UMass-HMLR/2024-10-02-UMass-HMLR.parquet"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  invalid <- c(
    AL01 = "AL01_run-sample1",
    CA02 = "CA02{x}",
    CA03 = "CA03:run-sample1"
  )
  for (id in names(invalid)) {
    tbl$output_type_id[tbl$output_type_id == id] <- invalid[[id]]
  }

  result <- check_tbl_spl_ids(tbl, "2024-10-02", file_path, hub_path)
  expect_s3_class(result, "check_error")
  expect_snapshot(result)
  expect_equal(
    result$errors,
    list(
      `1` = list(
        type = "character",
        max_length = 15L,
        problems = list(
          max_length = unname(invalid[c("AL01", "CA03")]),
          characters = unname(invalid[c("CA02", "CA03")])
        )
      )
    )
  )
  expect_match(result$message, "\"CA02{x}\"", fixed = TRUE)
})

test_that("check_tbl_spl_ids fails sample rows with a missing or empty output_type_id (#406)", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  is_missing <- tbl$output_type == "sample" &
    tbl$output_type_id %in% c("1", "2")
  tbl$output_type_id[is_missing & tbl$output_type_id == "1"] <- NA
  tbl$output_type_id[is_missing & tbl$output_type_id == "2"] <- ""
  tbl$output_type_id[tbl$output_type == "sample" & tbl$output_type_id == "3"] <-
    "s3"

  result <- check_tbl_spl_ids(tbl, "2022-10-22", file_path, hub_path)
  expect_s3_class(result, "check_error")
  expect_snapshot(result)
  expect_equal(
    result$errors[["2"]]$problems,
    list(missing = sum(is_missing), integer = "s3")
  )
})

test_that("check_tbl_spl_ids reports sample IDs that are not valid UTF-8 (#406)", {
  hub_path <- test_path("testdata/hub-now")
  file_path <- "UMass-HMLR/2024-10-02-UMass-HMLR.parquet"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  invalid <- rawToChar(as.raw(c(0x61, 0xff)))
  tbl$output_type_id[tbl$output_type_id == "AL01"] <- invalid

  result <- check_tbl_spl_ids(tbl, "2024-10-02", file_path, hub_path)
  expect_s3_class(result, "check_error")
  expect_equal(result$errors[["1"]]$problems, list(characters = invalid))
  expect_match(result$message, "\"a<ff>\"", fixed = TRUE)
})

test_that("validate_model_data stops the sample checks on invalid sample IDs (#406)", {
  hub_path <- withr::local_tempdir()
  fs::dir_copy(
    system.file("testhubs/samples", package = "hubValidations"),
    hub_path,
    overwrite = TRUE
  )
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  tbl <- read_model_out_file(file_path, hub_path, coerce_types = "chr")
  tbl <- brace_spl_ids(tbl)
  utils::write.csv(
    tbl,
    fs::path(hub_path, "model-output", file_path),
    row.names = FALSE
  )

  checks <- validate_model_data(hub_path, file_path)
  expect_equal(
    first_classes(checks[startsWith(names(checks), "spl_")]),
    c(spl_ids = "check_error")
  )
  msgs <- capture_messages(print(checks))
  expect_true(any(grepl("\"s{id1}\"", msgs, fixed = TRUE)))
})
