#' Check all required task ID/output type/output type ID value combinations present
#' in model data.
#'
#' @inheritParams check_tbl_values
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
#' @details
#' Note that it is **necessary for `derived_task_ids` to be specified if any of
#' the task IDs with `required` values have dependent derived task IDs**. If this is the
#' case and derived task IDs are not specified, the dependent nature of derived
#' task ID values will result in **false validation errors when validating
#' required values**.
check_tbl_values_required <- function(
  tbl,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path)
) {
  tbl[["value"]] <- NULL
  config_tasks <- read_config(hub_path, "tasks")

  if (hubUtils::is_v3_config(config_tasks)) {
    tbl[tbl$output_type == "sample", "output_type_id"] <- NA
  }
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }
  # The v4 path never builds the grid of every valid value combination. The
  # pre-v4 path still does, and is much slower and heavier for it.
  if (hubUtils::version_gte("v4.0.0", config = config_tasks)) {
    missing_df <- purrr::map(
      get_submission_required_output_types(tbl, config_tasks, round_id),
      \(.x) {
        missing_required_by_output_type(
          tbl = tbl,
          config_tasks = config_tasks,
          round_id = round_id,
          output_type = .x,
          derived_task_ids = derived_task_ids
        )
      }
    ) |>
      purrr::list_rbind()
  } else {
    missing_df <- missing_required_via_grid(
      tbl = tbl,
      config_tasks = config_tasks,
      round_id = round_id,
      derived_task_ids = derived_task_ids
    )
  }

  check <- nrow(missing_df) == 0L

  if (check) {
    details <- NULL
  } else {
    missing_df <- coerce_to_hub_schema(missing_df, config_tasks)
    details <- cli::format_inline("See {.var missing} attribute for details.")
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Required task ID/output type/output type ID combinations",
    msg_attribute = NULL,
    msg_verbs = c("all present.", "missing."),
    details = details,
    missing = missing_df
  )
}

#' Find the required value combinations a submission is missing, for a single
#' output type
#'
#' Compares the values a modeling task requires against those the submission
#' holds. Only the required values are expanded, and rows are matched with
#' [assign_tbl_to_model_task()], so the grid of every valid value combination is
#' never built.
#'
#' Serves configs of schema version `v4.0.0` and later.
#' `missing_required_via_grid()` serves earlier ones.
#'
#' @inheritParams expand_model_out_grid
#' @param tbl a tibble/data.frame of the contents of the file being validated,
#' with the `value` column dropped and any derived task ID columns blanked to
#' `NA`. Column types must **all be character**.
#' @param output_type Single output type name. Callers map over the output types
#' the submission has to account for.
#' @param derived_task_ids Character vector of derived task ID names, or `NULL`
#' for none. A derived task ID's value follows from the task IDs it is derived
#' from, so derived task IDs are excluded from the required values and left to
#' `check_tbl_derived_task_id_vals()`.
#'
#' @returns A tibble with one row per required value combination the submission
#' does not contain, in the columns of `tbl`. Zero rows when none are missing.
#' @noRd
missing_required_by_output_type <- function(
  tbl,
  config_tasks,
  round_id,
  output_type,
  derived_task_ids
) {
  req <- expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    output_types = output_type,
    required_vals_only = TRUE,
    # From v4, an output type the submission includes is required in full,
    # whether or not the config marks the output type itself required.
    force_output_types = TRUE,
    all_character = TRUE,
    bind_model_tasks = FALSE,
    derived_task_ids = derived_task_ids
  )

  mt_tbl_list <- assign_tbl_to_model_task(
    tbl,
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = output_type,
    derived_task_ids = derived_task_ids,
    subset_to_tbl_cols = TRUE
  )

  purrr::pmap(
    combine_mt_inputs(mt_tbl_list, req),
    check_modeling_task_values_required,
    derived_task_ids = derived_task_ids
  ) |>
    purrr::list_rbind()
}

#' Find the required value combinations one modeling task is missing
#'
#' A modeling task can fall short in two ways: nothing at all was submitted for
#' it, or what was submitted does not cover everything it requires.
#'
#' @details
#' An empty `tbl` is only a failure when the modeling task requires something of
#' every column. If `req` covers every column of `tbl`, each column has at least
#' one required value, so the whole of `req` is missing. If `req` does not, some
#' column(s) hold only optional values, the modeling task requires no submission
#' at all, and nothing is reported as missing. Note that derived task IDs are
#' left out of that comparison, because they never enter `req`.
#'
#' Otherwise the rows are grouped by the combination of optional values they
#' hold, the required ones having been blanked so only the optional ones form
#' the key. With `location` `US` and `horizon` `1` required, the rows `US`/`1`,
#' `01`/`1` and `01`/`2` key on `NA`/`NA`, `01`/`NA` and `01`/`2`. Each group is
#' checked on its own, because each combination of optional values has to appear
#' with every combination the remaining columns require.
#'
#' A row whose values are all required keys on `NA` in every column, so those
#' rows collect into one group, and that group is what compares the submission
#' against the whole of `req`. When every column has required values but the
#' submission contains no row in which every value is required, that group is
#' never formed, nothing else compares whole `req` rows, and all of `req` is
#' taken as missing.
#'
#' Each group is checked separately, so a row one group reports as missing may
#' have been submitted in another. With `location` `US` and `horizon` `1`
#' required, a submission of `US`/`1`, `01`/`2` and `US`/`2` has its `01`/`2`
#' group report `US`/`2` missing, which the submission does hold. Anything the
#' submission holds is dropped from the result at the end, leaving only `01`/`1`
#' reported as missing.
#'
#' @param tbl The rows of the submission assigned to one modeling task, in the
#' columns of the submission without `value`. Column types must **all be
#' character**.
#' @param req The values the modeling task requires, expanded. A column with no
#' required values is absent from it.
#' @param derived_task_ids Character vector of derived task ID names, or `NULL`
#' for none.
#' @param full The grid of every combination the modeling task allows, supplied
#' on the pre-v4 path only. See the pre-v4 section at the foot of this file.
#'
#' @returns A tibble of the required rows `tbl` does not hold, in the columns of
#' `tbl`. Zero rows when none are missing.
#' @noRd
check_modeling_task_values_required <- function(
  tbl,
  req,
  derived_task_ids,
  full = NULL
) {
  if (nrow(tbl) == 0L) {
    tbl_names <- setdiff(names(tbl), derived_task_ids)
    if (setequal(tbl_names, names(req))) {
      return(req[, tbl_names])
    } else {
      return(tbl)
    }
  }
  req_mask <- are_required_vals(tbl, req)

  # Check each combination of optional values against the values it has to
  # appear with.
  new_missing_df <- get_group_rows(tbl, mask = req_mask) |>
    purrr::map(
      ~ missing_required(
        x = tbl[.x, ],
        mask = req_mask[.x, , drop = FALSE],
        req,
        full
      )
    )

  # Take the whole of `req` as missing when no group compared against it.
  if (full_req_grid_tested(req_mask, req)) {
    missing_df <- list(NULL)
  } else {
    missing_df <- list(req)
  }

  missing_df <- purrr::list_rbind(c(missing_df, new_missing_df)) |>
    unique()

  if (nrow(missing_df) == 0L) {
    return(missing_df)
  }
  # Drop whatever the submission does hold.
  dplyr::anti_join(missing_df, tbl, by = names(tbl))
}

#' Check a combination of optional values appears with every required one
#'
#' Submitting an optional value obliges the submission to contain a row pairing
#' that value with each combination the other columns require. The obligation
#' falls on the submission as a whole, not on any one row.
#'
#' Take a modeling task requiring `location` `"US"` and `horizon` `"1"`, which
#' also allows the optional `location` `"01"` and `horizon` `"2"`. Submitting
#' `US`/`1` and `01`/`2` is incomplete twice over: `01` arrived without the
#' required horizon `1`, and `2` without the required location `US`. Both
#' `01`/`1` and `US`/`2` are reported missing.
#'
#' Each optional value therefore has to be tested against the required values on
#' its own, not only in the combination `x` happens to hold.
#' `get_opt_col_list()` derives the sets to test from the columns in which `x`
#' holds optional values.
#'
#' @param x The rows of a single modeling task that share one combination of
#' optional values, in the columns of the submission without `value`.
#' @param mask Logical matrix over the rows and columns of `x`, `TRUE` where the
#' value is one the modeling task requires.
#' @param req The values the modeling task requires, expanded. A column with no
#' required values is absent from it.
#' @param full The grid of every combination the modeling task allows, or `NULL`
#' on the v4 path. See the pre-v4 section at the foot of this file.
#'
#' @returns A tibble of the required rows `x` does not hold, in the columns of
#' `x`. Zero rows when none are missing.
#' @noRd
missing_required <- function(x, mask, req, full) {
  opt_cols_list <- get_opt_col_list(x, mask, full, req)
  map_missing_req_rows(opt_cols_list, x, req, full)
}

#' List the sets of optional columns to test for one group of rows
#'
#' The first set is every column `x` holds an optional value in. Testing only
#' that set would leave a column carrying both required and optional values
#' unchecked for its required ones, because the whole column is set aside as
#' optional. So the set is listed again with each combination of those columns
#' held to the value `x` submitted and treated as required instead, leaving
#' successively fewer columns marked optional.
#'
#' Take `location` requiring `US` and allowing `01`, and `horizon` requiring `1`
#' and allowing `2`. For rows holding `01`/`2` the sets are both columns, then
#' `horizon` alone, then `location` alone. The second asks what is required of
#' `01` across the remaining columns, the third the same for `2`.
#'
#' @param x The rows of a single modeling task that share one combination of
#' optional values, in the columns of the submission without `value`.
#' @param mask Logical matrix over the rows and columns of `x`, `TRUE` where the
#' value is one the modeling task requires.
#' @param full The grid of every combination the modeling task allows, or `NULL`
#' on the v4 path. See the pre-v4 section at the foot of this file.
#' @param req The values the modeling task requires, expanded. A column with no
#' required values is absent from it.
#'
#' @returns A list of named logical vectors, one per set, each over the columns
#' of `x` and `TRUE` where the column is to be treated as optional. Duplicates
#' are dropped, so the list can be shorter than the number of combinations.
#' `missing_req_rows()` is called once per element.
#' @noRd
get_opt_col_list <- function(x, mask, full, req) {
  min_opt_col <- ncol(x) - ncol(req)
  # A column the config gives no required values is absent from `req`. Forcing
  # it to stay optional stops the smaller sets treating it as required and
  # expecting values the config never asks for.
  all_opt_cols <- setdiff(names(x), names(req)) # nolint: object_usage_linter

  opt_vals <- get_opt_vals(x, mask)
  if (!is.null(full)) {
    opt_vals <- ignore_optional_output_type(opt_vals, x, mask, full, req)
  }

  opt_val_combs <- get_opt_val_combs(opt_vals, min_opt_col)

  c(
    list(get_opt_cols(mask)),
    purrr::map(
      opt_val_combs,
      ~ get_opt_cols(mask, .x, all_opt_cols)
    )
  ) |>
    unique()
}

#' Find the required rows missing, for one set of optional columns
#'
#' One step of the check `missing_required()` documents. Compares `x` against
#' the values required in the columns `opt_cols` does not mark optional, and
#' returns those the submission left out.
#'
#' @param opt_cols Named logical vector over the columns of `x`, `TRUE` for the
#' columns to treat as optional in this pass. `get_opt_col_list()` returns one
#' of these for each combination of optional columns that has to be tested.
#' @param x The rows of a single modeling task that share one combination of
#' optional values, in the columns of the submission without `value`.
#' @param req The values the modeling task requires, expanded. A column with no
#' required values is absent from it.
#' @param full The grid of every combination the modeling task allows, or `NULL`
#' on the v4 path. See the pre-v4 section at the foot of this file.
#'
#' @returns A tibble of the required rows `x` does not hold, in the columns of
#' `x`. Zero rows when none are missing.
#' @noRd
missing_req_rows <- function(opt_cols, x, req, full) {
  # When the rows hold no optional values there is nothing to narrow the
  # expectation with, so every row of `req` is expected and what is missing is
  # whatever `x` does not hold. The path below cannot express that: it both
  # narrows and reports by the optional columns, and here there are none.
  if (all(opt_cols == FALSE)) {
    return(dplyr::anti_join(req, x[, names(req)], by = names(req)))
  }
  opt_colnms <- names(x)[opt_cols]

  req <- req[, !names(req) %in% opt_colnms]
  # No columns with required values left to compare, so nothing is missing.
  if (ncol(req) == 0L) {
    return(x[0L, , drop = FALSE])
  }
  if (is.null(full)) {
    # The v4 path, where `req` covers a single output type, so it is one
    # Cartesian product and every row of it is a combination the modeling task
    # accepts. Nothing needs filtering out.
    expected_req <- unique(req)
  } else {
    # The pre-v4 path, which still needs the grid. See the section at the foot
    # of this file.
    expected_req <- narrow_expected_req_by_grid(req, x, opt_colnms, full)
  }

  # Compare the expected required values for the optional value combination
  # being validated to those in x, and return any expected rows x does not hold.
  missing <- dplyr::anti_join(
    expected_req,
    x[, names(expected_req)],
    by = names(expected_req)
  )
  if (nrow(missing) != 0L) {
    cbind(
      missing,
      unique(x[, opt_cols])
    )[, names(x)]
  } else {
    x[0L, , drop = FALSE]
  }
}

map_missing_req_rows <- function(opt_cols_list, x, req, full) {
  purrr::map(
    opt_cols_list,
    ~ missing_req_rows(.x, x, req, full)
  ) |>
    purrr::list_rbind()
}

are_required_vals <- function(tbl, req) {
  req[, setdiff(names(tbl), names(req))] <- ""
  req <- req[, names(tbl)]

  req_vals <- purrr::map2(
    tbl,
    purrr::map(req, unique),
    ~ .x %in% .y
  )
  do.call(cbind, req_vals)
}

# If all columns have been configured with required values, check that there is
# a block in the file of all required values.
full_req_grid_tested <- function(req_mask, req) {
  if (setequal(colnames(req_mask), names(req))) {
    any(apply(req_mask, 1, FUN = function(x, req_cols = names(req)) {
      all(req_cols %in% names(x)[x])
    }))
  } else {
    TRUE
  }
}

# Get a named list of the unique optional value in each optional column in x.
get_opt_vals <- function(x, mask) {
  n <- nrow(mask)
  idx <- colSums(mask) == n
  if (all(idx)) {
    return(NULL)
  }
  as.vector(unique(x[!idx]))
}

# Get each subset of combination of optional values of successively smaller n.
get_opt_val_combs <- function(opt_vals, min_opt_col = 0L) {
  if (is.null(opt_vals)) {
    return(NULL)
  }

  if (min_opt_col == 0L) {
    base_opt_vals <- list(NULL)
  } else {
    base_opt_vals <- NULL
  }
  c(
    base_opt_vals,
    purrr::map(
      seq(1, length(opt_vals)) - 1L,
      ~ combn(opt_vals, m = .x, simplify = FALSE)
    ) |>
      unlist(recursive = FALSE) |>
      purrr::compact()
  )
}

# Get a logical vector of whether a column contains all optional values or not.
get_opt_cols <- function(mask, check_opt_comb = NULL, all_opt_cols = NULL) {
  n <- nrow(mask)
  opt_cols <- colSums(mask) < n
  if (!is.null(check_opt_comb)) {
    opt_cols[names(check_opt_comb)] <- FALSE
  }
  # Always include columns whose values are all optional in opt_cols if provided.
  # This ensures correct applicable values are subset from appropriate model tasks.
  opt_cols[all_opt_cols] <- TRUE
  opt_cols
}

# Pair each modeling task's rows with the values required of it, dropping the
# modeling tasks that require nothing. `full` is supplied on the pre-v4 path
# only, so the list is two elements long on the v4 path and three on the pre-v4
# one. `purrr::pmap()` matches them to `check_modeling_task_values_required()`
# by name.
combine_mt_inputs <- function(tbl, req, full = NULL) {
  keep_mt <- purrr::map_lgl(req, ~ nrow(.x) > 0L)
  c(
    list(tbl = tbl[keep_mt], req = req[keep_mt]),
    if (!is.null(full)) list(full = full[keep_mt])
  )
}

# ---------------------------------------------------------------------------
# Pre-v4 only.
#
# This path evaluates all of a modeling task's output types in one pass, so
# `req` spans every one of them rather than being a single Cartesian product.
# Only the grid records which `output_type_id` is valid with which
# `output_type`, and these functions need that pairing.
#
# Note that taking one output type at a time, as the v4 path does, is not a
# like-for-like substitution: an output type the config does not mark required
# yields an empty `req` when taken alone and is then never checked. It was
# tried, and it stopped reporting the `mean` and `median` rows of the
# `testhubs/samples` test and all 168 rows of the #123 case.
#
# Everything below can be deleted once a minimum schema version of v4 is agreed
# (#375), along with `join_tbl_to_model_task()`, which nothing else calls.
# ---------------------------------------------------------------------------

missing_required_via_grid <- function(
  tbl,
  config_tasks,
  round_id,
  derived_task_ids
) {
  req <- expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    output_types = NULL,
    required_vals_only = TRUE,
    force_output_types = FALSE,
    all_character = TRUE,
    bind_model_tasks = FALSE,
    derived_task_ids = derived_task_ids
  )

  full <- expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    output_types = NULL,
    required_vals_only = FALSE,
    all_character = TRUE,
    as_arrow_table = FALSE,
    bind_model_tasks = FALSE,
    derived_task_ids = derived_task_ids
  )

  tbl <- join_tbl_to_model_task(full, tbl, subset_to_tbl_cols = TRUE)

  purrr::pmap(
    combine_mt_inputs(tbl, req, full),
    check_modeling_task_values_required,
    derived_task_ids = derived_task_ids
  ) |>
    purrr::list_rbind()
}

# Narrow `req` to the required values that apply to the optional values in `x`,
# keeping only the rows the grid pairs with those optional values.
narrow_expected_req_by_grid <- function(req, x, opt_colnms, full) {
  applicaple_full <- dplyr::inner_join(
    full,
    unique(x[, opt_colnms]),
    by = opt_colnms
  )
  dplyr::inner_join(
    req,
    applicaple_full[, names(req)],
    by = names(req)
  ) |>
    unique()
}

# Get a character vector of output types that are required in the applicable
# model task.
get_required_output_types <- function(x, mask, full, req) {
  cols <- get_opt_cols(mask)
  join_colnames <- names(cols)[cols]

  applicaple_full <- dplyr::inner_join(
    full,
    unique(x[, join_colnames]),
    by = join_colnames
  )

  join_colnames <- names(cols)[!cols]
  dplyr::inner_join(
    unique(applicaple_full[, join_colnames]),
    req,
    by = join_colnames
  )[[hubUtils::std_colnames["output_type"]]] |>
    unique()
}

# If an output type is optional, ignore so that output type IDs associated with it
# are not errorneously flagged as missing.
ignore_optional_output_type <- function(opt_vals, x, mask, full, req) {
  output_tid_col <- hubUtils::std_colnames["output_type"]
  if (!output_tid_col %in% names(opt_vals)) {
    return(opt_vals)
  }
  req_output_types <- get_required_output_types(x, mask, full, req)
  if (!opt_vals[[output_tid_col]] %in% req_output_types) {
    opt_vals[hubUtils::std_colnames[
      c("output_type", "output_type_id")
    ]] <- NULL
  }
  opt_vals
}

is_zero_tbl <- function(tbl) {
  isTRUE(ncol(tbl) == 0L)
}
