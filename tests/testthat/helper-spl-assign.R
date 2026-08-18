# Sample assignment as it was done before value sets replaced it: expand the
# sample grid for each modeling task and join the data to it. Kept here as the
# reference the new code is checked against.

# What `spl_hash_tbl()` used to do to split a table across modeling tasks and
# give each row its compound index.
spl_mt_tbls_via_grid <- function(
  tbl,
  round_id,
  config_tasks,
  compound_taskid_set = NULL,
  derived_task_ids = get_config_derived_task_ids(config_tasks, round_id)
) {
  tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }

  mt_spl_grid <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    all_character = TRUE,
    include_sample_ids = TRUE,
    bind_model_tasks = FALSE,
    compound_taskid_set = compound_taskid_set,
    output_types = "sample",
    derived_task_ids = derived_task_ids
  )
  mt_spl_grid <- stats::setNames(mt_spl_grid, seq_along(mt_spl_grid))

  purrr::map(
    mt_spl_grid,
    function(.x) {
      if (nrow(.x) == 0L) {
        return(NULL)
      }
      join_by <- setdiff(names(tbl), c("output_type_id", "compound_idx"))
      mt_spl <- dplyr::rename(.x, compound_idx = "output_type_id")
      dplyr::inner_join(tbl, mt_spl, by = join_by)
    }
  )
}

# `spl_hash_tbl()` as it was, on top of the grid split above. Everything from
# `get_mt_spl_hash_tbl()` onwards is untouched, so this differs from the current
# function only in how rows reach their modeling task and compound index.
spl_hash_tbl_via_grid <- function(
  tbl,
  round_id,
  config_tasks,
  compound_taskid_set = NULL,
  derived_task_ids = get_config_derived_task_ids(config_tasks, round_id)
) {
  mt_tbls <- spl_mt_tbls_via_grid(
    tbl,
    round_id = round_id,
    config_tasks = config_tasks,
    compound_taskid_set = compound_taskid_set,
    derived_task_ids = derived_task_ids
  )

  if (is.null(compound_taskid_set)) {
    compound_taskid_set <- get_round_compound_task_ids(config_tasks, round_id)
  }

  purrr::map2(
    mt_tbls,
    compound_taskid_set,
    ~ hubValidations:::get_mt_spl_hash_tbl(
      tbl = .x,
      compound_taskids = .y,
      round_task_ids = hubUtils::get_round_task_id_names(config_tasks, round_id)
    )
  ) |>
    purrr::compact() |>
    purrr::imap(~ dplyr::mutate(.x, mt_id = as.integer(.y))) |>
    purrr::list_rbind()
}

# What `get_tbl_compound_taskid_set()` used to do to split a table across
# modeling tasks.
spl_mt_rows_via_grid <- function(
  tbl,
  round_id,
  config_tasks,
  derived_task_ids = get_config_derived_task_ids(config_tasks, round_id)
) {
  tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }
  out_tid <- hubUtils::std_colnames["output_type_id"]

  purrr::map(
    expand_model_out_grid(
      config_tasks = config_tasks,
      round_id = round_id,
      all_character = TRUE,
      include_sample_ids = FALSE,
      bind_model_tasks = FALSE,
      output_types = "sample",
      derived_task_ids = derived_task_ids
    ),
    function(.x) {
      if (nrow(.x) == 0L) {
        return(NULL)
      }
      dplyr::inner_join(
        tbl,
        .x[, names(.x) != out_tid],
        by = setdiff(names(tbl), out_tid)
      )
    }
  )
}

# Every hub in the test suite with a sample submission, so the comparison covers
# a single modeling task and several, a declared compound task ID set and none,
# character and numeric sample IDs, and derived task IDs.
spl_fixtures <- function() {
  fixtures <- list(
    list(
      hub_path = system.file("testhubs/samples", package = "hubValidations"),
      file_path = "flu-base/2022-10-22-flu-base.csv",
      round_id = "2022-10-22"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-spl"),
      file_path = "flu-base/2022-10-22-flu-base.parquet",
      round_id = "2022-10-22"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-spl-multi-mt"),
      file_path = "team-model/2022-10-22-team-model.csv",
      round_id = "2022-10-22"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-177"),
      file_path = "FluSight-baseline/2024-12-14-FluSight-baseline.parquet",
      round_id = "2024-12-14"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-04-Tm-Md.csv",
      round_id = "2023-11-04"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-now"),
      file_path = "UMass-HMLR/2024-10-02-UMass-HMLR.parquet",
      round_id = "2024-10-02"
    )
  )
  # `system.file()` returns "" when the installed build does not ship the hub,
  # so drop that fixture rather than fail on a path that does not exist.
  purrr::keep(fixtures, \(x) nzchar(x[["hub_path"]]))
}

# Read a fixture's submission as the sample checks receive it.
read_spl_fixture <- function(fixture) {
  read_model_out_file(
    file_path = fixture[["file_path"]],
    hub_path = fixture[["hub_path"]],
    coerce_types = "chr"
  )
}
