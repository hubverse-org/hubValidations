test_that("spl_idx_tbl for compiling sample properties works", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  file_path <- "flu-base/2022-10-22-flu-base.csv"
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  tbl_spl <- tbl[tbl$output_type == "sample", ]
  config_tasks <- read_config(hub_path)

  spl_idx <- spl_idx_tbl(tbl, round_id, config_tasks)
  idx_tbl <- spl_idx$rows

  expect_s3_class(idx_tbl, "tbl_df")
  # One row per sample row, pointing back at it
  expect_equal(nrow(idx_tbl), nrow(tbl_spl))
  expect_equal(tbl$output_type_id[idx_tbl$row_idx], idx_tbl$output_type_id)
  # The first modeling task offers no samples
  expect_equal(
    spl_idx$comp_tids,
    list(NULL, c("reference_date", "location"))
  )
  # Every sample covers a single compound_idx
  slice_tbl <- spl_slice_tbl(idx_tbl)
  expect_equal(nrow(slice_tbl), dplyr::n_distinct(tbl_spl$output_type_id))
  expect_equal(sort(unique(slice_tbl$compound_idx)), c("1", "2", "3", "4", "5"))
  # Every slice covers the same non compound task ID values
  expect_equal(
    nrow(
      mismatched_non_comp_slices(
        spl_idx_tbl(tbl, round_id, config_tasks, non_comp_key = TRUE)$rows
      )$slices
    ),
    0L
  )

  # A sample covering two compound idxs has a slice in each ----
  spl_1_ctid <- tbl_spl[tbl_spl$output_type_id == "1", ]
  spl_1_ctid$location[1] <- "02"
  expect_equal(
    spl_slice_tbl(
      spl_idx_tbl(spl_1_ctid, round_id, config_tasks)$rows
    )$compound_idx,
    c("3", "2")
  )

  # A slice missing a non compound task ID value does not match ----
  spl_mismatch <- tbl_spl[
    !(tbl_spl$output_type_id == "1" & tbl_spl$horizon == "0"),
  ]
  mismatched <- mismatched_non_comp_slices(
    spl_idx_tbl(spl_mismatch, round_id, config_tasks, non_comp_key = TRUE)$rows
  )
  expect_equal(mismatched$slices$output_type_id, "1")
  expect_equal(
    spl_mismatch$horizon[mismatched$reference$row_idx],
    sort(unique(tbl_spl$horizon))
  )

  # A tbl with no samples gives a zero row table ----
  no_spl <- spl_idx_tbl(
    tbl[tbl$output_type != "sample", ],
    round_id,
    config_tasks,
    non_comp_key = TRUE
  )
  expect_equal(nrow(no_spl$rows), 0L)
  expect_named(
    no_spl$rows,
    c("mt_id", "output_type_id", "compound_idx", "row_idx", "non_comp_key")
  )
})

test_that("overlapping_spl_slices flags samples covering different compound idxs", {
  slices <- function(...) {
    spls <- list(...)
    tibble::tibble(
      mt_id = 1L,
      output_type_id = rep(names(spls), lengths(spls)),
      compound_idx = unlist(spls, use.names = FALSE)
    )
  }
  flagged <- function(x) unique(overlapping_spl_slices(x)$output_type_id)

  # Groups of samples each covering their own compound idxs
  expect_length(flagged(slices(a1 = 1:2, a2 = 1:2, b1 = 3, b2 = 3)), 0L)
  # Each sample overlaps another
  expect_equal(flagged(slices(x = 1:2, y = 2:3, z = c(1, 3))), c("x", "y", "z"))
  # One sample covers part of what another covers
  expect_equal(flagged(slices(s1 = 1:2, s2 = 2)), c("s1", "s2"))
  # Only the samples involved are flagged
  expect_equal(flagged(slices(a = 1:2, b = 2:3, c = 4)), c("a", "b"))
  # A sample sharing a compound idx with a rule-breaking sample is included,
  # even though it covers only compound idxs that sample covers too
  expect_equal(
    flagged(slices(x = 1:2, y = 2:3, w = 3)),
    c("x", "y", "w")
  )
  # Compound idxs are numbered across modeling tasks, so samples in different
  # modeling tasks never share one
  expect_length(
    flagged(dplyr::bind_rows(
      slices(a = 1:2),
      dplyr::mutate(slices(b = 3), mt_id = 2L)
    )),
    0L
  )
})

test_that("mismatched_non_comp_slices always has a reference to compare against", {
  idx_tbl <- function(...) {
    spls <- list(...)
    keys <- unlist(spls, use.names = FALSE)
    tibble::tibble(
      mt_id = 1L,
      output_type_id = rep(names(spls), lengths(spls)),
      compound_idx = "1",
      row_idx = seq_along(keys),
      non_comp_key = keys
    )
  }

  # The set most slices cover is the reference
  out <- mismatched_non_comp_slices(idx_tbl(a = 1:2, b = 1:2, c = 1L))
  expect_equal(out$slices$output_type_id, "c")
  expect_equal(out$reference$row_idx, 1:2)

  # Where no set is covered by more slices than another, one set is still the
  # reference, and only the slices covering the other are reported
  out <- mismatched_non_comp_slices(idx_tbl(a = 1:2, b = 3:4))
  expect_equal(out$slices$output_type_id, "b")
  expect_equal(out$reference$row_idx, 1:2)
})

test_that("spl_idx_tbl leaves derived task IDs out of comp_tids", {
  hub_path <- system.file("testhubs/samples", package = "hubValidations")
  tbl <- read_model_out_file(
    "flu-base/2022-10-22-flu-base.csv",
    hub_path,
    coerce_types = "chr"
  )
  spl_idx <- spl_idx_tbl(
    tbl,
    "2022-10-22",
    read_config(hub_path, "tasks"),
    compound_taskid_set = list(
      NULL,
      c("reference_date", "location", "target_end_date")
    ),
    derived_task_ids = "target_end_date"
  )
  expect_equal(spl_idx$comp_tids[[2]], c("reference_date", "location"))
})

test_that("compound_idx_labels escapes braces", {
  spl_idx <- list(
    rows = tibble::tibble(compound_idx = "1", row_idx = 1L, mt_id = 1L),
    comp_tids = list("location")
  )
  tbl <- tibble::tibble(location = "{x}")
  units <- compound_idx_labels("1", spl_idx, tbl)

  expect_equal(units, "(location: {{x}})")
  expect_equal(
    cli::format_inline(cli::format_inline("values {units}")),
    "values (location: {x})"
  )
})
