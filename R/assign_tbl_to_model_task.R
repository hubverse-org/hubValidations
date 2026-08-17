#' Assign each row of model output data to the modeling task it belongs to
#'
#' Tests each row's values against the values each modeling task allows, one
#' column at a time. A row belongs to a modeling task when every column agrees.
#' Rows that no modeling task accepts are left out, as are rows carrying a value
#' the config does not list.
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
#' this table as it stands. Every task ID column the round defines must be
#' present.
#' @param derived_task_ids Character vector of derived task ID names, or `NULL`
#' for none. A derived task ID's value is worked out from other task IDs, and
#' those are matched on, so it adds nothing to deciding where a row belongs.
#' These columns are not matched on and come back holding whatever they held.
#' @param output_types Character vector of output type names to consider, or
#' `NULL` for every output type the round defines. Checks validate one output
#' type at a time, so this is usually a single name: a modeling task offering
#' several will only be asked about that one, and rows of any other output type
#' match nothing. A modeling task offering none of the requested output types
#' gets `NULL`.
#' @param subset_to_tbl_cols Logical. Which columns to return. `TRUE` gives the
#' columns of `tbl_chr`, in their own order, without `value`. `FALSE` gives the
#' columns the modeling task itself defines: its task IDs in config order, then
#' `output_type` and `output_type_id`, with `value` last when `tbl_chr` has one.
#' @param order_by_config Logical. Whether to sort each modeling task's rows by
#' where each value sits in the config's list for its column, rather than
#' leaving them in the order they were submitted in. Sorted on `output_type`, so
#' rows of one output type sit together, then `output_type_id` so they ascend
#' within each, then the task IDs to break ties. Positions are compared, not the
#' values themselves, so a column whose values do not sort meaningfully still
#' comes back in the order the config gives them. See `order_by_config()`.
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
  value_sets <- get_config_mt_value_sets(
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = output_types,
    derived_task_ids = derived_task_ids,
    call = rlang::caller_env()
  )

  # `get_config_mt_value_sets()` gives every modeling task an entry for every
  # task ID in the round, so the first one already lists them all. Those, plus
  # the two output type columns, are the columns `tbl_chr` must have to be
  # matched.
  match_cols <- c(
    names(value_sets[[1L]][["task_ids"]]),
    unname(hubUtils::std_colnames[c("output_type", "output_type_id")])
  )
  missing_cols <- setdiff(match_cols, names(tbl_chr))
  if (length(missing_cols) > 0L) {
    cli::cli_abort(
      # Named for the caller's argument, since the error is attributed to the
      # caller and this function is not the one anybody invoked.
      "Column{?s} {.val {missing_cols}} must be present in {.arg tbl}.",
      call = rlang::caller_env()
    )
  }

  purrr::map(
    value_sets,
    \(mt) {
      assign_mt_rows(
        tbl_chr,
        mt,
        derived_task_ids,
        subset_to_tbl_cols,
        order_by_config
      )
    }
  )
}

# Assign rows to a single modeling task, in submitted order unless
# `order_by_config`.
assign_mt_rows <- function(
  tbl_chr,
  mt,
  derived_task_ids,
  subset_to_tbl_cols,
  order_by_config
) {
  # A derived task ID's value is worked out from other task IDs, and those are
  # matched on, so it can only agree with them about where a row belongs. It is
  # left out, which saves a pass over the data each.
  match_task_ids <- setdiff(names(mt[["task_ids"]]), derived_task_ids)

  output_types <- names(mt[["output_type_ids"]])
  # A modeling task offering none of the requested output types has nothing to
  # match against and so gets no rows at all.
  if (length(output_types) == 0L) {
    return(NULL)
  }
  output_type_col <- tbl_chr[[hubUtils::std_colnames[["output_type"]]]]
  output_type_id_col <- tbl_chr[[hubUtils::std_colnames[["output_type_id"]]]]

  # Collect the positions of `output_type_id`s in relation to the order
  # specified in the config for each output type. Each output type has its own
  # order, which is why this is a loop rather than one lookup. The `NA`s left
  # behind drop rows this modeling task does not accept, and the positions are
  # what `order_by_config` sorts on.
  output_type_id_pos <- rep(NA_integer_, nrow(tbl_chr))
  for (output_type in output_types) {
    output_type_rows <- which(output_type_col == output_type)
    output_type_id_pos[output_type_rows] <- match(
      output_type_id_col[output_type_rows],
      mt[["output_type_ids"]][[output_type]]
    )
  }

  # Narrow to the rows the modeling task accepts, one task ID column at a time.
  # Both sides are already character, so `%in%` is a plain comparison. It also
  # matches `NA` to `NA`, as the join it replaces did, which is how a task ID
  # the modeling task does not use is matched.
  keep <- !is.na(output_type_id_pos)
  for (task_id in match_task_ids) {
    keep <- keep & tbl_chr[[task_id]] %in% mt[["task_ids"]][[task_id]]
  }
  rows <- which(keep)
  if (order_by_config) {
    rows <- order_by_config(
      rows,
      tbl_chr,
      mt,
      match_task_ids,
      output_type_id_pos
    )
  }

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
  tibble::as_tibble(tbl_chr[rows, cols, drop = FALSE])
}

# Order rows by where each of their values sits in the config's lists: output
# type first, so rows of one output type are together, then output type ID, so
# they ascend within each, then the task IDs to break ties. Positions are
# compared rather than the values themselves, because output type IDs do not
# always sort meaningfully. Sorting is stable, so rows sharing a position keep
# the order they were submitted in.
#
# Belongs here rather than in the caller because working out where each value
# sits in the config is already part of assigning a row. A caller sorting for
# itself would have to read the config again to recover positions this function
# is handed for free.
order_by_config <- function(
  rows,
  tbl_chr,
  mt,
  match_task_ids,
  output_type_id_pos
) {
  output_type_col <- tbl_chr[[hubUtils::std_colnames[["output_type"]]]]
  task_ids <- mt[["task_ids"]]
  # Only `output_type_id_pos` is worked out already, because matching needed it.
  # The rest are wanted for ordering alone, so they are worked out here and only
  # for the rows being ordered. Derived task IDs are left out, as they are for
  # matching: every row holds `NA` there, so they cannot separate any two rows.
  keys <- c(
    list(
      match(output_type_col[rows], names(mt[["output_type_ids"]])),
      output_type_id_pos[rows]
    ),
    purrr::map(
      match_task_ids,
      \(task_id) match(tbl_chr[[task_id]][rows], task_ids[[task_id]])
    )
  )
  rows[do.call(order, c(keys, list(method = "radix")))]
}
