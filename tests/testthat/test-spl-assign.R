test_that("sample rows assign to the same modeling tasks as they did through the grid", {
  for (fixture in spl_fixtures()) {
    config_tasks <- read_config(fixture[["hub_path"]], "tasks")
    round_id <- fixture[["round_id"]]
    tbl <- read_spl_fixture(fixture)

    spl_tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]
    derived_task_ids <- get_config_derived_task_ids(config_tasks, round_id)
    if (!is.null(derived_task_ids)) {
      spl_tbl[, derived_task_ids] <- NA_character_
    }

    row_idx <- assign_spl_tbl_rows(
      spl_tbl,
      config_tasks = config_tasks,
      round_id = round_id,
      derived_task_ids = derived_task_ids
    )
    expect_equal(
      purrr::map(row_idx, \(x) if (is.null(x)) NULL else spl_tbl[x, ]),
      spl_mt_rows_via_grid(tbl, round_id, config_tasks),
      info = fixture[["hub_path"]]
    )
  }
})

test_that("the sample hash table is built as it was through the grid", {
  for (fixture in spl_fixtures()) {
    config_tasks <- read_config(fixture[["hub_path"]], "tasks")
    round_id <- fixture[["round_id"]]
    tbl <- read_spl_fixture(fixture)

    expect_equal(
      spl_hash_tbl(tbl, round_id, config_tasks),
      spl_hash_tbl_via_grid(tbl, round_id, config_tasks),
      info = fixture[["hub_path"]]
    )

    # Samples can be coarser than the config declares, in which case the checks
    # pass the set they detected instead of the configured one, and the
    # compound indices are numbered from that.
    detected <- get_tbl_compound_taskid_set(
      tbl,
      config_tasks,
      round_id,
      compact = FALSE,
      error = FALSE
    )
    expect_equal(
      spl_hash_tbl(tbl, round_id, config_tasks, detected),
      spl_hash_tbl_via_grid(tbl, round_id, config_tasks, detected),
      info = fixture[["hub_path"]]
    )
  }
})

test_that("a modeling task with no samples is numbered as it was through the grid", {
  # Detection returns `NULL` for a modeling task with no samples, and the
  # numbering reads `NULL` as every task ID being compound. That modeling task
  # therefore takes the largest block of indices it could, and every modeling
  # task after it starts past the whole of it. This tests against what the grid
  # also did. Whether this is the right numbering is an open issue, see #377.
  hub_path <- test_path("testdata/hub-spl-multi-mt")
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    "team-model/2022-10-22-team-model.csv",
    hub_path,
    coerce_types = "chr"
  )
  config_tasks <- read_config(hub_path, "tasks")

  # The first modeling task takes the `hosp` samples, so dropping them leaves it
  # with none.
  tbl <- tbl[tbl$output_type != "sample" | tbl$target == "ed_visits", ]
  detected <- get_tbl_compound_taskid_set(
    tbl,
    config_tasks,
    round_id,
    compact = FALSE,
    error = FALSE
  )
  expect_null(detected[[1L]])

  expect_equal(
    spl_hash_tbl(tbl, round_id, config_tasks, detected),
    spl_hash_tbl_via_grid(tbl, round_id, config_tasks, detected)
  )
})

test_that("the order a compound_taskid_set is written in does not change compound_idx numbering", {
  # A compound_idx is calculated from the values of compound task IDs in the
  # order the config lists them, so config order decides the numbering, not the
  # order the set happens to be written in. `get_mt_compound_idx_numbering()`
  # reorders the set to match the config. Every fixture hub already declares its
  # set in config order, so without this test a failure to reorder would go
  # unnoticed.
  hub_path <- test_path("testdata/hub-spl")
  round_id <- "2022-10-22"
  tbl <- read_model_out_file(
    "flu-base/2022-10-22-flu-base.parquet",
    hub_path,
    coerce_types = "chr"
  )
  config_tasks <- read_config(hub_path, "tasks")

  declared <- get_round_compound_task_ids(config_tasks, round_id)
  permuted <- purrr::map(declared, rev)

  expect_equal(
    spl_hash_tbl(tbl, round_id, config_tasks, permuted),
    spl_hash_tbl_via_grid(tbl, round_id, config_tasks, permuted)
  )
  expect_equal(
    spl_hash_tbl(tbl, round_id, config_tasks, permuted),
    spl_hash_tbl(tbl, round_id, config_tasks, declared)
  )
})

test_that("the sample checks still validate compound_taskid_set names without building the grid", {
  hub_path <- test_path("testdata/hub-spl-multi-mt")
  tbl <- read_model_out_file(
    "team-model/2022-10-22-team-model.csv",
    hub_path,
    coerce_types = "chr"
  )

  expect_snapshot(
    check_tbl_spl_compound_tid(
      tbl,
      "2022-10-22",
      "team-model/2022-10-22-team-model.csv",
      hub_path,
      compound_taskid_set = list(
        c("target", "locatoin"),
        c("target", "location")
      )
    ),
    error = TRUE
  )
})

test_that("the sample checks still validate compound_taskid_set length without building the grid", {
  hub_path <- test_path("testdata/hub-spl-multi-mt")
  tbl <- read_model_out_file(
    "team-model/2022-10-22-team-model.csv",
    hub_path,
    coerce_types = "chr"
  )

  expect_snapshot(
    check_tbl_spl_n(
      tbl,
      "2022-10-22",
      "team-model/2022-10-22-team-model.csv",
      hub_path,
      compound_taskid_set = list(c("target", "location"))
    ),
    error = TRUE
  )
})

test_that("a large compound index is not written in scientific notation", {
  # A config allowing a million combinations reaches indices that
  # `as.character()` would render as "1e+06".
  numbering <- list(
    comp_tid_values = list(a = seq_len(1000L), b = seq_len(1000L)),
    start_idx = 0,
    character_ids = FALSE
  )
  mt_tbl <- tibble::tibble(a = c("1", "1000"), b = c("1", "1000"))

  expect_equal(get_compound_idx(mt_tbl, numbering), c("1", "1000000"))
})

test_that("compound task ID sets are detected as they were through the grid", {
  for (fixture in spl_fixtures()) {
    config_tasks <- read_config(fixture[["hub_path"]], "tasks")
    round_id <- fixture[["round_id"]]
    tbl <- read_spl_fixture(fixture)

    expect_equal(
      get_tbl_compound_taskid_set(tbl, config_tasks, round_id, compact = FALSE),
      purrr::set_names(
        purrr::map2(
          spl_mt_rows_via_grid(tbl, round_id, config_tasks),
          get_round_compound_task_ids(config_tasks, round_id),
          \(mt_tbl, comp_tids) {
            hubValidations:::get_mt_compound_taskid_set(
              mt_tbl,
              comp_tids,
              config_tasks
            )
          }
        ),
        \(x) as.character(seq_along(x))
      ),
      info = fixture[["hub_path"]]
    )
  }
})
