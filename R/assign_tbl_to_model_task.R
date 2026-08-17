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
#' for none. A derived task ID's value follows from the other task IDs. Those
#' are matched on, so a derived one cannot send a row to a different modeling
#' task. These columns are skipped, and returned unchanged.
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
#' What is sorted on is each value's position in the config, not the value
#' itself, so a column whose values do not sort into a useful order on their own
#' still comes back in the order the config gives them.
#'
#' In the config a task ID's values are split into `required` and `optional`.
#' `extract_round_property_values()` collapses the two into a single order when
#' it extracts them, `required` values first, then `optional` ones, and that is
#' the order sorted on. See `order_by_config()`.
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

  # Every task ID the round defines is matched on, whether or not a given
  # modeling task uses it, so all of them have to be present, along with the two
  # output type columns.
  match_cols <- c(
    hubUtils::get_round_task_id_names(config_tasks, round_id),
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
  # A derived task ID's value follows from the other task IDs. Those are matched
  # on, so a derived one cannot send a row anywhere different. Skipping it saves
  # a pass over the data.
  match_task_ids <- setdiff(names(mt[["task_ids"]]), derived_task_ids)

  output_types <- names(mt[["output_type_ids"]])
  # A modeling task offering none of the requested output types has nothing to
  # match against and so gets no rows at all.
  if (length(output_types) == 0L) {
    return(NULL)
  }
  output_type_col <- tbl_chr[[hubUtils::std_colnames[["output_type"]]]]
  output_type_id_col <- tbl_chr[[hubUtils::std_colnames[["output_type_id"]]]]

  # Find where each row's `output_type_id` sits among the ones the config allows
  # for its `output_type`. Each output type has its own set, which is why this
  # loops over them rather than doing one lookup. A row whose `output_type_id`
  # is not in the set gets `NA`, and those are the rows this modeling task does
  # not accept. `order_by_config` sorts on these positions later.
  output_type_id_pos <- rep(NA_integer_, nrow(tbl_chr))
  for (output_type in output_types) {
    output_type_rows <- which(output_type_col == output_type)
    output_type_id_pos[output_type_rows] <- match(
      output_type_id_col[output_type_rows],
      mt[["output_type_ids"]][[output_type]]
    )
  }

  # Narrow to the rows the modeling task accepts, one task ID column at a time.
  # Both sides are already character, so `%in%` is a plain comparison. `NA`
  # matches `NA`, as it did in the join this replaces. That is what handles a
  # task ID the modeling task does not use: it allows `NA` and nothing else,
  # the rows hold `NA` there, so the comparison is `TRUE` and `keep` is left
  # alone.
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

# Order rows by where each of their values sits among the ones the config
# allows: output type first, so rows of one output type are together, then
# output type ID, so they ascend within each, then the task IDs to break ties.
#
# What is sorted on is each value's position, not the value itself, because
# output type IDs do not always have a useful order of their own. `pmf`
# categories are the example: sorting `"low"`, `"moderate"`, `"high"`
# alphabetically would put them in the wrong order, while their positions in
# the config are already right.
# For a task ID, the positions run through its `required` values first and then
# its `optional` ones, the order `extract_round_property_values()` collapses the
# two into. Sorting is stable, so rows sharing a position keep the order they
# were submitted in.
#
# This lives here rather than in the caller because assigning a row already
# works out where its values sit in the config. A caller doing its own sorting
# would have to read the config a second time to recover positions this function
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
  # matching. A derived value follows from the task IDs already being sorted on,
  # so it cannot separate two rows those leave tied.
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
  # `do.call()` hands the keys to `order()` as separate arguments, which is how
  # `order()` takes tie-breakers: the first decides, and each one after it only
  # separates rows the ones before left equal.
  rows[do.call(order, c(keys, list(method = "radix")))]
}
