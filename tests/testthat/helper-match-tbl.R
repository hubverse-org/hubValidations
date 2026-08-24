# Matching as it was done before the modeling task value sets replaced it:
# build the grid of every valid value combination for each modeling task and
# join the data to it. Kept here as the reference the new matching is measured
# against.
match_via_grid <- function(
  tbl,
  config_tasks,
  round_id,
  output_types = NULL,
  derived_task_ids = NULL,
  subset_to_tbl_cols = FALSE,
  all_character = TRUE
) {
  join_cols <- setdiff(names(tbl), "value")
  expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    all_character = all_character,
    bind_model_tasks = FALSE,
    output_types = output_types,
    derived_task_ids = derived_task_ids
  ) |>
    purrr::map(\(grid) {
      if (ncol(grid) == 0L) {
        return(NULL)
      }
      matched <- dplyr::inner_join(grid, tbl, by = join_cols)
      if (subset_to_tbl_cols) {
        matched[, join_cols]
      } else {
        matched
      }
    })
}

# The rows each modeling task gets, in a fixed order so two ways of arriving at
# the same partition can be compared without also pinning how they order it.
sort_partition <- function(x) {
  purrr::map(x, \(mt) {
    if (is.null(mt)) {
      return(NULL)
    }
    dplyr::arrange(mt, dplyr::across(dplyr::everything()))
  })
}

# Every hub the test suite has a submission for, so the comparison covers
# schema versions v3 to v6, samples, derived task IDs, several output types and
# rounds split across more than one modeling task.
match_fixtures <- function() {
  fixtures <- list(
    list(
      hub_path = system.file("testhubs/samples", package = "hubValidations"),
      file_path = "flu-base/2022-10-22-flu-base.csv"
    ),
    list(
      hub_path = system.file("testhubs/simple", package = "hubValidations"),
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
    ),
    list(
      hub_path = system.file("testhubs/flusight", package = "hubValidations"),
      file_path = "hub-baseline/2023-05-08-hub-baseline.parquet"
    ),
    list(
      hub_path = system.file("testhubs/v4/simple", package = "hubUtils"),
      file_path = "hub-baseline/2022-10-08-hub-baseline.csv"
    ),
    list(
      hub_path = system.file("testhubs/v5/target_file", package = "hubUtils"),
      file_path = "Flusight-base/2022-10-22-Flusight-base.csv"
    ),
    list(
      hub_path = system.file("testhubs/v6/target_file", package = "hubUtils"),
      file_path = "Flusight-base/2022-10-22-Flusight-base.csv"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-177"),
      file_path = "FluSight-baseline/2024-12-14-FluSight-baseline.parquet"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-chr"),
      file_path = "UMass-gbq/2023-10-28-UMass-gbq.csv"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-num"),
      file_path = "UMass-gbq/2023-10-28-UMass-gbq.csv"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-diff-otid-per-task"),
      file_path = "ISI-NotOrdered/2024-01-10-ILI-model.csv"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-it"),
      file_path = "Tm-Md/2023-11-04-Tm-Md.csv"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-now"),
      file_path = "UMass-HMLR/2024-10-02-UMass-HMLR.parquet"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-nul"),
      file_path = "team-model/2023-11-19-team-model.parquet"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-spl"),
      file_path = "flu-base/2022-10-22-flu-base.parquet"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-spl-multi-mt"),
      file_path = "team-model/2022-10-22-team-model.csv"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-unordered"),
      file_path = "ISI-NotOrdered/2024-01-10-ISI-NotOrdered.csv"
    )
  )
  # A hub that comes from another package is skipped rather than failed if
  # the installed version does not ship it.
  purrr::keep(fixtures, \(x) nzchar(x[["hub_path"]]))
}
