#' Assign each row of model output data to the modeling task it belongs to
#'
#' Tests each row's values against the values each modeling task allows, one
#' column at a time. A row belongs to a modeling task when every column
#' matches. Rows that match no modeling task are left out.
#'
#' This is what [match_tbl_to_model_task()] used to do by expanding the grid of
#' every valid value combination and joining the data to it. Testing each column
#' instead costs one pass over the data per column and does not depend on how
#' many combinations the config allows.
#'
#' @inheritParams expand_model_out_grid
#' @param tbl_chr a tibble/data.frame of the contents of the file being
#' validated. Column types must **all be character**: the config's values are
#' converted to character when they are extracted, and are compared against
#' this table without further conversion. Every task ID column the round defines
#' must be present.
#' @param derived_task_ids Character vector of derived task ID names, or `NULL`
#' for none. A derived task ID's value follows from the values of other task
#' IDs. A derived task ID cannot therefore further distinguish a row beyond the
#' values of the task IDs it is derived from. Derived task ID columns are
#' skipped, and returned unchanged.
#' @param output_types Character vector of output type names, or `NULL`, the
#' default, for every output type the round defines. This subsets the data as
#' well as matching it: rows of any other output type are ignored, and a
#' modeling task that does not offer any of the named output types gets `NULL`.
#' Callers usually name a single output type, because the checks validate one at
#' a time.
#' @param subset_to_tbl_cols Logical. Which columns to return. `TRUE`, the
#' default, gives the columns of `tbl_chr`, in their own order, without `value`.
#' `FALSE` gives the columns the modeling task itself defines: its task IDs in
#' config order, then `output_type` and `output_type_id`, with `value` last when
#' `tbl_chr` has one.
#' @param order_by_config Logical. How to order each modeling task's rows.
#' `FALSE`, the default, leaves them in the order they were submitted in. `TRUE`
#' sorts them into the order the config lists their values in: on `output_type`
#' first, so rows of one output type sit together, then on `output_type_id`, so
#' they ascend within each, then on the task IDs to break ties.
#'
#' What is sorted on is each task IDs value's position in the config, not the
#' value itself.
#'
#' In the config a task ID's values are split into `required` and `optional`.
#' `extract_round_property_values()` collapses the two into a single order when
#' it extracts them, `required` values first, then `optional` ones, and that is
#' the order sorted on.
#'
#' @returns A list with one element per modeling task in the round, each
#' containing the rows of `tbl_chr` assigned to that modeling task, in submitted
#' order unless `order_by_config` is `TRUE`. A modeling task that offers none of
#' the requested output types gets `NULL`.
#' @noRd
assign_tbl_to_model_task <- function(
  tbl_chr,
  config_tasks,
  round_id,
  output_types = NULL,
  derived_task_ids = get_config_derived_task_ids(
    config_tasks,
    round_id
  ),
  subset_to_tbl_cols = TRUE,
  order_by_config = FALSE
) {
  call <- rlang::caller_env()
  value_sets <- get_config_mt_value_sets(
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = output_types,
    derived_task_ids = derived_task_ids,
    call = call
  )
  check_match_cols(tbl_chr, config_tasks, round_id, call = call)

  purrr::map(
    value_sets,
    \(mt) {
      row_idx <- which_mt_rows(tbl_chr, mt, derived_task_ids, order_by_config)
      if (is.null(row_idx)) {
        return(NULL)
      }
      subset_mt_tbl(tbl_chr, mt, row_idx, subset_to_tbl_cols)
    }
  )
}

# Check that `tbl_chr` has every column the matching step reads. Every task ID
# the round defines is matched on, whether or not a given modeling task uses it,
# so all of them have to be present, along with the two output type columns.
check_match_cols <- function(tbl_chr, config_tasks, round_id, call) {
  match_cols <- c(
    hubUtils::get_round_task_id_names(config_tasks, round_id),
    unname(hubUtils::std_colnames[c("output_type", "output_type_id")])
  )
  missing_cols <- setdiff(match_cols, names(tbl_chr))
  if (length(missing_cols) > 0L) {
    cli::cli_abort(
      # `tbl`, not `tbl_chr`, because the error is attributed to the exported
      # function the user called, where the argument is named `tbl`.
      "Column{?s} {.val {missing_cols}} must be present in {.arg tbl}.",
      call = call
    )
  }
  invisible(NULL)
}

#' Find the rows of `tbl_chr` that match a single modeling task
#'
#' Compares each row's value in every task ID and output type column against
#' the values the modeling task allows. Returns the indexes of the rows where
#' every column matches.
#'
#' @param tbl_chr An all character tibble/data.frame of the file being
#' validated. Every task ID the round defines must be present, along with
#' `output_type` and `output_type_id`.
#' @param mt One modeling task's value sets, a single element of
#' `get_config_mt_value_sets()`. A list of `task_ids`, holding the values each
#' task ID allows, and `output_type_ids`, holding the values `output_type_id`
#' allows for each output type. All character.
#' @param derived_task_ids Character vector of derived task ID names, or `NULL`
#' for none. These columns are not matched on.
#' @param order_by_config Logical. `FALSE`, the default, returns the row
#' indexes in submitted order. `TRUE` returns them in the order the config
#' lists their values in.
#'
#' @returns An integer vector of row indexes into `tbl_chr`, or `NULL`.
#'
#' Note that the two empty returns below mean different things:
#' - `integer(0)`: the modeling task offers one or more of the requested output
#'   types but no row matched it/them. `subset_mt_tbl()` turns this into a
#'   tibble of zero rows.
#' - `NULL`: the modeling task offers none of the requested output types, so
#'   there was nothing to match against. The caller returns `NULL` for that
#'   modeling task.
#' @noRd
which_mt_rows <- function(
  tbl_chr,
  mt,
  derived_task_ids,
  order_by_config = FALSE
) {
  # A derived task ID's value follows from the values of other task IDs. A
  # derived task ID cannot therefore further distinguish a row beyond the values
  # of the task IDs it is derived from. Skipping it saves a pass over the data.
  match_task_ids <- setdiff(names(mt[["task_ids"]]), derived_task_ids)

  # None of the requested output types, so there is nothing to match against.
  if (length(mt[["output_type_ids"]]) == 0L) {
    return(NULL)
  }
  output_type_id_pos <- match_output_type_ids(tbl_chr, mt)
  keep <- !is.na(output_type_id_pos)

  keep <- narrow_by_task_id_values(
    tbl_chr,
    mt,
    match_task_ids,
    keep = keep
  )
  row_idx <- which(keep)
  if (order_by_config) {
    row_idx <- order_by_config(
      row_idx,
      tbl_chr,
      mt,
      match_task_ids,
      output_type_id_pos
    )
  }
  row_idx
}

#' Find the sample rows of `spl_tbl` that match a single modeling task
#'
#' Compares each row's value in every task ID column against the values the
#' modeling task allows. Returns the indexes of the rows where every column
#' matches.
#'
#' Samples skip the `output_type_id` comparison that `which_mt_rows()`
#' performs. A sample's `output_type_id` is an identifier the submitter chose,
#' so the config lists no valid ids to compare it with, and the caller has
#' already reduced `spl_tbl` to sample rows. That comparison could therefore
#' never reject a row, so every row starts eligible and only the task ID
#' columns are compared.
#'
#' @param spl_tbl An all character tibble/data.frame holding the sample rows of
#' a submission, without the `value` column. Every task ID the round defines
#' must be present.
#' @param mt One modeling task's value sets, a single element of
#' `get_config_mt_value_sets()`. A list of `task_ids`, holding the values each
#' task ID allows, and `output_type_ids`, holding the values `output_type_id`
#' allows for each output type. All character.
#' @param derived_task_ids Character vector of derived task ID names, or `NULL`
#' for none. These columns are not matched on.
#'
#' @returns An integer vector of row indexes into `spl_tbl`, or `NULL`.
#'
#' Note that the two empty returns below mean different things:
#' - `integer(0)`: the modeling task offers the sample output type but no row
#'   matched it.
#' - `NULL`: the modeling task does not offer the sample output type, so there
#'   was nothing to match against.
#' @noRd
which_mt_spl_rows <- function(spl_tbl, mt, derived_task_ids) {
  if (is.null(mt[["output_type_ids"]][["sample"]])) {
    return(NULL)
  }
  match_task_ids <- setdiff(names(mt[["task_ids"]]), derived_task_ids)
  keep <- narrow_by_task_id_values(
    spl_tbl,
    mt,
    match_task_ids,
    keep = rep(TRUE, nrow(spl_tbl))
  )
  which(keep)
}

#' Find the position of each row's `output_type_id` in the config's list
#'
#' Matches each row's `output_type_id` against the values the config allows for
#' that row's `output_type`. Returns its position in that list, which is the
#' order the config lists the values in.
#'
#' Each output type has its own set, which is why this loops over them rather
#' than doing one lookup.
#'
#' @param tbl_chr An all character tibble/data.frame of the file being
#' validated. `output_type` and `output_type_id` must be present.
#' @param mt One modeling task's value sets, a single element of
#' `get_config_mt_value_sets()`.
#'
#' @returns An integer vector with one element per row of `tbl_chr`. A row
#' whose `output_type_id` is not one the modeling task allows gets `NA`, and
#' those are the rows that do not match it.
#'
#' Positions rather than a logical vector, because `order_by_config()` sorts on
#' them.
#' @noRd
match_output_type_ids <- function(tbl_chr, mt) {
  output_type_col <- tbl_chr[[hubUtils::std_colnames[["output_type"]]]]
  output_type_id_col <- tbl_chr[[hubUtils::std_colnames[["output_type_id"]]]]

  pos <- rep(NA_integer_, nrow(tbl_chr))
  for (output_type in names(mt[["output_type_ids"]])) {
    output_type_row_idx <- which(output_type_col == output_type)
    pos[output_type_row_idx] <- match(
      output_type_id_col[output_type_row_idx],
      mt[["output_type_ids"]][[output_type]]
    )
  }
  pos
}

#' Narrow a set of candidate rows to those a modeling task's task IDs allow
#'
#' Tests one task ID column at a time and drops any row whose value in that
#' column is not one the modeling task allows. Both sides are already
#' character, so `%in%` is a plain comparison.
#'
#' Note that a modeling task that does not use a task ID either lists it as
#' null in the config or leaves it out, and config processing turns the
#' expected value of both situations into `NA`. Correctly submitted model
#' output carries `NA` in that column too. `%in%` matches `NA` to `NA`, unlike
#' `==`, so those rows match.
#'
#' @param tbl_chr An all character tibble/data.frame of the file being
#' validated.
#' @param mt One modeling task's value sets, a single element of
#' `get_config_mt_value_sets()`.
#' @param match_task_ids Character vector naming the task ID columns to test.
#' The caller has already removed any derived task IDs.
#' @param keep Logical vector with one element per row of `tbl_chr`, marking
#' the rows still in the running when this stage starts. It carries the result
#' of the stage before it: `which_mt_rows()` passes the rows that survived the
#' `output_type_id` comparison, and `which_mt_spl_rows()` passes all `TRUE`,
#' because samples skip that comparison.
#'
#' @returns `keep`, with `FALSE` for every row a task ID column ruled out.
#' @noRd
narrow_by_task_id_values <- function(tbl_chr, mt, match_task_ids, keep) {
  for (task_id in match_task_ids) {
    keep <- keep & tbl_chr[[task_id]] %in% mt[["task_ids"]][[task_id]]
  }
  keep
}

# Subset `tbl_chr` to a modeling task's rows, with the columns the caller
# asked for.
subset_mt_tbl <- function(tbl_chr, mt, row_idx, subset_to_tbl_cols) {
  if (subset_to_tbl_cols) {
    cols <- setdiff(names(tbl_chr), "value")
  } else {
    cols <- c(
      names(mt[["task_ids"]]),
      unname(hubUtils::std_colnames[c("output_type", "output_type_id")]),
      intersect("value", names(tbl_chr))
    )
  }
  # A no-op when `tbl_chr` is a tibble, which is what reading a submission
  # gives. For a plain data.frame it keeps the documented `tbl_df` return, and
  # drops the row names that subsetting by position would otherwise carry over.
  tibble::as_tibble(tbl_chr[row_idx, cols, drop = FALSE])
}

# Order rows by the position each of their values holds in the config's list:
# output type first, so rows of one output type are together, then output type
# ID, so they ascend within each output type, then the task IDs to break ties.
#
# What is sorted on is each value's position, not the value itself, because
# output type IDs do not always have a useful order of their own. `pmf`
# categories are the example: sorting `"low"`, `"moderate"`, `"high"`
# alphabetically would put them in the wrong order, while their positions in
# the config are already right.
#
# A task ID's positions run through its `required` values first, then its
# `optional` ones. Sorting is stable, so rows sharing a position keep the order
# they were submitted in.
order_by_config <- function(
  row_idx,
  tbl_chr,
  mt,
  match_task_ids,
  output_type_id_pos
) {
  output_type_col <- tbl_chr[[hubUtils::std_colnames[["output_type"]]]]
  task_ids <- mt[["task_ids"]]
  # `output_type_id_pos` already exists, because matching needed it. The task ID
  # positions are only needed for sorting, so they are worked out here, and only
  # for the rows being sorted. Derived task IDs are left out as they are for
  # matching: a derived value cannot separate two rows that are tied on the task
  # IDs it is derived from.
  keys <- c(
    list(
      match(output_type_col[row_idx], names(mt[["output_type_ids"]])),
      output_type_id_pos[row_idx]
    ),
    purrr::map(
      match_task_ids,
      \(task_id) match(tbl_chr[[task_id]][row_idx], task_ids[[task_id]])
    )
  )
  # `do.call()` hands the keys to `order()` as separate arguments, which is how
  # `order()` takes tie-breakers: the first decides, and each one after it only
  # separates rows that earlier keys left equal.
  row_idx[do.call(order, c(keys, list(method = "radix")))]
}
