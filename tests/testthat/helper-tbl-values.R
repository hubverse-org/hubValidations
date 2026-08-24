# Value validation as it was done before value sets replaced it: per output
# type, expand every value combination the config allows and join the data to
# it. Kept here as the reference the new code is checked against.

# `check_tbl_values()` as it was. One deliberate difference: the join returns
# the rows grouped by output type, and the `rowid` column existed to map an
# invalid row back to the row it came from. The rows are put back in submitted
# order here, because that is the order the new code reports them in.
check_tbl_values_via_grid <- function(
  tbl,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
) {
  config_tasks <- read_config(hub_path, "tasks")

  valid_tbl <- tbl |>
    tibble::rowid_to_column() |>
    split(f = tbl$output_type) |>
    purrr::imap(
      ~ check_values_by_output_type_via_grid(
        tbl = .x,
        output_type = .y,
        config_tasks = config_tasks,
        round_id = round_id,
        derived_task_ids = derived_task_ids
      )
    ) |>
    purrr::list_rbind()
  valid_tbl <- valid_tbl[order(valid_tbl$rowid), ]

  check <- !any(is.na(valid_tbl$valid))

  if (check) {
    details <- NULL
    error_tbl <- NULL
  } else {
    error_summary <- summarise_invalid_values_via_grid(
      valid_tbl,
      config_tasks,
      round_id,
      derived_task_ids
    )
    details <- error_summary$msg
    if (length(error_summary$invalid_combs_idx) == 0L) {
      error_tbl <- NULL
    } else {
      error_tbl <- tbl[
        error_summary$invalid_combs_idx,
        names(tbl) != "value"
      ]
    }
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var tbl}",
    msg_attribute = "",
    msg_verbs = c(
      "contains valid values/value combinations.",
      "contains invalid values/value combinations."
    ),
    error_tbl = error_tbl,
    error = TRUE,
    details = details
  )
}

check_values_by_output_type_via_grid <- function(
  tbl,
  output_type,
  config_tasks,
  round_id,
  derived_task_ids = NULL
) {
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }

  accepted_vals <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    all_character = TRUE,
    output_types = output_type,
    derived_task_ids = derived_task_ids
  )

  accepted_vals$valid <- TRUE
  if (hubUtils::is_v3_config(config_tasks) && output_type == "sample") {
    tbl[tbl$output_type == "sample", "output_type_id"] <- NA
  }

  dplyr::left_join(
    tbl,
    accepted_vals,
    by = setdiff(names(tbl), c("value", "rowid"))
  )
}

summarise_invalid_values_via_grid <- function(
  valid_tbl,
  config_tasks,
  round_id,
  derived_task_ids
) {
  invalid_row_idx <- which(is.na(valid_tbl$valid))
  cols <- setdiff(names(valid_tbl), c("value", "valid", "rowid"))
  uniq_tbl <- purrr::map(valid_tbl[invalid_row_idx, cols], unique)
  uniq_config <- get_round_config_values(
    config_tasks,
    round_id,
    derived_task_ids
  )[cols]

  invalid_vals <- purrr::map2(
    uniq_tbl,
    uniq_config,
    ~ .x[!.x %in% .y]
  ) |>
    purrr::compact()

  if (length(invalid_vals) != 0L) {
    invalid_vals_msg <- purrr::imap_chr(
      invalid_vals,
      ~ cli::format_inline(
        "Column {.var {.y}} contains invalid {cli::qty(length(.x))}
        value{?s} {.val {.x}}."
      )
    ) |>
      paste(collapse = " ")
  } else {
    invalid_vals_msg <- NULL
  }

  invalid_val_idx <- purrr::imap(
    invalid_vals,
    ~ which(valid_tbl[[.y]] %in% .x)
  ) |>
    unlist(use.names = FALSE) |>
    unique()
  invalid_combs_idx <- setdiff(invalid_row_idx, invalid_val_idx)
  if (length(invalid_combs_idx) == 0L) {
    invalid_combs_msg <- NULL
  } else {
    invalid_combs_idx <- valid_tbl$rowid[invalid_combs_idx]
    invalid_combs_msg <- cli::format_inline(
      "Additionally {cli::qty(length(invalid_combs_idx))} row{?s}
      {.val {invalid_combs_idx}} {cli::qty(length(invalid_combs_idx))}
      {?contains/contain} invalid combinations of valid values.
      See {.var error_tbl} for details."
    )
  }
  list(
    msg = paste(invalid_vals_msg, invalid_combs_msg, sep = "\n"),
    invalid_combs_idx = invalid_combs_idx
  )
}

# Every hub in the test suite with a submission the round accepts, so the
# comparison covers one modeling task and several, v2 to v4 configs, character
# and numeric output type IDs, task IDs a modeling task does not use, samples,
# and modeling tasks that only `output_type_id` tells apart.
#
# `derived_task_ids` is what to pass the check, for a hub whose config does not
# declare any but which has a task ID derived from the others all the same.
values_fixtures <- function() {
  fixtures <- list(
    list(
      hub_path = system.file("testhubs/simple", package = "hubValidations"),
      file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
      round_id = "2022-10-08"
    ),
    list(
      hub_path = system.file("testhubs/samples", package = "hubValidations"),
      file_path = "flu-base/2022-10-22-flu-base.csv",
      round_id = "2022-10-22"
    ),
    list(
      hub_path = system.file("testhubs/samples", package = "hubValidations"),
      file_path = "flu-base/2022-10-22-flu-base.csv",
      round_id = "2022-10-22",
      derived_task_ids = "target_end_date"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-chr"),
      file_path = "UMass-gbq/2023-10-28-UMass-gbq.csv",
      round_id = "2023-10-28"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-num"),
      file_path = "UMass-gbq/2023-11-11-UMass-gbq.csv",
      round_id = "2023-11-11"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-diff-otid-per-task"),
      file_path = "ISI-NotOrdered/2024-01-10-ILI-model.csv",
      round_id = "2024-01-10"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-nul"),
      file_path = "team-model/2023-11-19-team-model.parquet",
      round_id = "2023-11-19"
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-unordered"),
      file_path = "ISI-NotOrdered/2024-01-10-ISI-NotOrdered.csv",
      round_id = "2024-01-10"
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
    ),
    list(
      hub_path = testthat::test_path("testdata/hub-spl-multi-mt"),
      file_path = "team-model/2022-10-22-team-model.csv",
      round_id = "2022-10-22"
    )
  )
  # `system.file()` returns "" when the installed build does not ship the hub,
  # so drop that fixture rather than fail on a path that does not exist.
  purrr::keep(fixtures, \(x) nzchar(x[["hub_path"]]))
}

# Call a check on a fixture.
call_with_fixture <- function(check, tbl, fixture) {
  check(
    tbl = tbl,
    round_id = fixture[["round_id"]],
    file_path = fixture[["file_path"]],
    hub_path = fixture[["hub_path"]],
    derived_task_ids = fixture_derived_task_ids(fixture)
  )
}

# A fixture's submission as the check receives it, and copies of it that make
# the check fail. Each column gives two. `invalid_<col>` replaces a single
# value with one no modeling task allows. `reversed_<col>` reverses the whole
# column, pairing each row's value in it with another row's values in the rest;
# a hub of several modeling tasks rejects most of those pairings as
# combinations no single modeling task allows.
#
# A derived task ID gets no `invalid_` variant, because the check is told to
# ignore what those columns hold. Neither does `output_type_id` on a sample
# row: a sample's `output_type_id` is an identifier the submitter chose, so
# every value is valid there. That variant alters the first row of another
# output type instead, and a submission of nothing but samples does not get one.
values_variants <- function(fixture) {
  tbl <- read_model_out_file(
    file_path = fixture[["file_path"]],
    hub_path = fixture[["hub_path"]],
    coerce_types = "chr"
  )
  config_tasks <- read_config(fixture[["hub_path"]], "tasks")
  task_ids <- hubUtils::get_round_task_id_names(
    config_tasks,
    fixture[["round_id"]]
  )
  out_tid <- hubUtils::std_colnames[["output_type_id"]]
  out_type <- tbl[[hubUtils::std_colnames[["output_type"]]]]
  derived_task_ids <- fixture_derived_task_ids(fixture)

  variants <- list(submitted = tbl)
  for (col in c(task_ids, out_tid)) {
    row <- if (col == out_tid) which(out_type != "sample")[1L] else 1L
    if (!col %in% derived_task_ids && !is.na(row)) {
      invalid <- tbl
      invalid[row, col] <- "not-a-value"
      variants[[paste0("invalid_", col)]] <- invalid
    }
    reversed <- tbl
    reversed[[col]] <- rev(reversed[[col]])
    variants[[paste0("reversed_", col)]] <- reversed
  }
  variants
}

# The derived task IDs the check ignores for a fixture.
fixture_derived_task_ids <- function(fixture) {
  if (!is.null(fixture[["derived_task_ids"]])) {
    return(fixture[["derived_task_ids"]])
  }
  get_hub_derived_task_ids(fixture[["hub_path"]], fixture[["round_id"]])
}

# The condition each implementation returns records the name of the function
# that built it, which is the one field that is meant to differ.
without_call <- function(cnd) {
  cnd[["call"]] <- NULL
  cnd
}
