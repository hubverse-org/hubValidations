## --- Sample assignment -------------------------------------------------------
#' Assign sample rows to the modeling tasks they belong to
#'
#' @param spl_tbl a character tibble holding the sample rows of a submission,
#' without the `value` column.
#' @inheritParams expand_model_out_grid
#' @returns A list with one element per modeling task in the round, each an
#' integer vector of row indexes into `spl_tbl`. `NULL` for a modeling task
#' that does not offer samples.
#' @noRd
assign_spl_tbl_rows <- function(
  spl_tbl,
  config_tasks,
  round_id,
  derived_task_ids,
  call = rlang::caller_env()
) {
  value_sets <- get_config_mt_value_sets(
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = "sample",
    derived_task_ids = derived_task_ids,
    call = call
  )
  check_match_cols(spl_tbl, config_tasks, round_id, call = call)

  purrr::map(
    value_sets,
    \(mt) which_mt_rows(spl_tbl, mt, derived_task_ids)
  )
}

## --- Sample index utils ------------------------------------------------------
#' Build the sample index, one row per submitted sample row
#'
#' The sample checks validate samples against the compound modeling tasks the
#' config defines. Each combination of configured compound task ID values is
#' one compound modeling task, identified by its compound idx. A sample that
#' matches the configured `compound_taskid_set` covers one compound idx. A
#' coarser sample covers several. A slice is the part of a sample that covers
#' one compound idx.
#'
#' For example, take a configured `compound_taskid_set` of `reference_date`
#' and `location`. Each compound idx is then one location for one reference
#' date. A sample with a compound task ID set of `reference_date` only, joint
#' across locations `A1` and `A2`, has two slices: its `A1` rows and its `A2`
#' rows. Other functions in this file refer to this example.
#'
#' Modeling tasks are handled separately, since each can declare its own
#' `compound_taskid_set`. Rows carrying values the config does not allow are
#' left out.
#'
#' @param tbl a model output data table.
#' @param round_id character string. The round ID.
#' @param config_tasks a list representation of the `tasks.json` configuration
#' file.
#' @param compound_taskid_set a list of character vectors of task ID names, one
#' for each modeling task in the round, overriding the sets the config declares.
#' `NULL` uses the config's own. `NULL` for one modeling task means every one of
#' its task IDs is compound.
#' @param derived_task_ids a character vector of derived task IDs. Defaults to
#' derived task IDs set in the config.
#' @param non_comp_key Logical. Whether to add the `non_comp_key` column. In
#' the example above, take a modeling task whose other task IDs are `horizon`
#' and `target`. Each row
#' holds one combination of `horizon` and `target` values, such as horizon `1`
#' with target `"x"`. `non_comp_key` gives each distinct combination an
#' integer, the same for every row holding it.
#'
#' `check_tbl_spl_non_compound_tid()` requires every slice in a modeling task
#' to hold the same combinations. If one slice holds horizons `1` to `4` for
#' target `"x"`, every other slice must hold those four combinations too. With
#' one integer per row, the check compares slices by counting keys instead of
#' comparing several columns of values. Only that check needs the column.
#'
#' @returns A list with:
#' - `rows`: a tibble with one row per sample row and the columns `mt_id`
#'   (which modeling task the row belongs to), `output_type_id` (the sample
#'   the row belongs to), `compound_idx` (which compound modeling task the row
#'   belongs to), `row_idx` (the row's index in `tbl`) and, when requested,
#'   `non_comp_key` (see the `non_comp_key` argument).
#' - `comp_tids`: a list with one element per modeling task in the round. Each
#'   element is a character vector of the names of the modeling task's compound
#'   task IDs, in config order and without derived task IDs. It is `NULL` for a
#'   modeling task without samples.
#' - `non_comp_tids`: a list in the same shape, holding the names of the other
#'   task IDs of each modeling task.
#' @importFrom rlang %||%
#' @noRd
spl_idx_tbl <- function(
  tbl,
  round_id,
  config_tasks,
  compound_taskid_set = NULL,
  derived_task_ids = get_config_derived_task_ids(
    config_tasks,
    round_id
  ),
  non_comp_key = FALSE
) {
  spl_rows <- which(tbl$output_type == "sample")
  tbl <- tbl[spl_rows, names(tbl) != "value"]
  # `derived_taskids_to_na()` replaces a derived task ID's config values with
  # `NA` as the config is read. So when a derived task ID is in the compound
  # task ID set, the index worked out below can only find its value if the
  # column holds `NA` too.
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }

  # A `NULL` argument means: use the set each modeling task's config declares.
  mt_compound_taskids <- compound_taskid_set %||%
    get_round_compound_task_ids(config_tasks, round_id)

  call <- rlang::caller_env()
  mt_row_idx <- assign_spl_tbl_rows(
    tbl,
    config_tasks = config_tasks,
    round_id = round_id,
    derived_task_ids = derived_task_ids,
    call = call
  )
  # The numbering also holds each modeling task's compound task ID names. A
  # `NULL` set, which means every task ID is compound, is replaced there by
  # the names themselves.
  mt_numbering <- get_mt_compound_idx_numbering(
    config_tasks = config_tasks,
    round_id = round_id,
    compound_taskid_set = mt_compound_taskids,
    derived_task_ids = derived_task_ids,
    call = call
  )
  round_task_ids <- hubUtils::get_round_task_id_names(config_tasks, round_id)

  # Derived task IDs are left out. A derived task ID can hold several values
  # within one compound idx, so a message naming the compound idx by its
  # values would show an arbitrary one.
  mt_comp_tids <- purrr::map(
    mt_numbering,
    \(.x) if (!is.null(.x)) setdiff(names(.x$comp_tid_values), derived_task_ids)
  )
  mt_non_comp_tids <- purrr::map(
    mt_numbering,
    \(.x) if (!is.null(.x)) setdiff(round_task_ids, names(.x$comp_tid_values))
  )

  # Sample rows holding values the config does not allow are left out, so
  # `rows` can be empty. Callers use its columns either way, so an empty
  # `rows` is built from this zero-row template of the columns and types.
  ptype <- tibble::tibble(
    mt_id = integer(),
    output_type_id = character(),
    compound_idx = character(),
    row_idx = integer()
  )
  if (non_comp_key) {
    ptype$non_comp_key <- integer()
  }

  rows <- purrr::pmap(
    list(mt_row_idx, mt_numbering, mt_non_comp_tids, seq_along(mt_row_idx)),
    function(row_idx, numbering, non_comp_tids, mt_id) {
      if (is.null(row_idx) || is.null(numbering) || length(row_idx) == 0L) {
        return(NULL)
      }
      mt_tbl <- tbl[row_idx, ]
      mt_rows <- tibble::tibble(
        mt_id = mt_id,
        output_type_id = mt_tbl$output_type_id,
        compound_idx = get_compound_idx(mt_tbl, numbering),
        row_idx = spl_rows[row_idx]
      )
      if (non_comp_key) {
        mt_rows$non_comp_key <- get_group_indices(mt_tbl[non_comp_tids])
      }
      mt_rows
    }
  ) |>
    purrr::list_rbind(ptype = ptype)

  list(rows = rows, comp_tids = mt_comp_tids, non_comp_tids = mt_non_comp_tids)
}

# One row per slice (see `spl_idx_tbl()`). The `row_idx` kept is that of one
# of the slice's rows, from which its compound task ID values can be read.
spl_slice_tbl <- function(idx_rows) {
  dplyr::distinct(
    idx_rows,
    dplyr::across(dplyr::all_of(c("mt_id", "output_type_id", "compound_idx"))),
    .keep_all = TRUE
  )
}

#' Find samples that share compound idxs without covering the same ones
#'
#' Samples that cover one compound idx must all cover the same compound idxs.
#' The samples of a modeling task then fall into groups, and each group covers
#' compound idxs no other group covers. In the example of `spl_idx_tbl()`, a
#' sample joint across locations `A1` and `A2` can sit beside samples for
#' location `B`, but not beside a sample joint across `A2` and `B`.
#'
#' Each compound idx is labelled with the first sample covering it. The rule
#' holds exactly when every sample carries a single label and every sample with
#' a label covers every compound idx with that label. Both are counts, so the
#' test needs no comparison of one sample's compound idxs against another's.
#'
#' @param slice_tbl output of `spl_slice_tbl()`.
#' @returns The rows of `slice_tbl` belonging to samples that break the rule,
#'   or that cover a compound idx such a sample covers.
#' @noRd
overlapping_spl_slices <- function(slice_tbl) {
  if (nrow(slice_tbl) == 0L) {
    return(slice_tbl)
  }
  spl <- get_group_indices(slice_tbl[c("mt_id", "output_type_id")])
  idx <- get_group_indices(slice_tbl[c("mt_id", "compound_idx")])

  ord <- order(idx, spl)
  first <- ord[!duplicated(idx[ord])]
  idx_label <- integer(max(idx))
  idx_label[idx[first]] <- spl[first]
  label <- idx_label[idx]

  n_spl <- max(spl)
  # Each distinct sample and label pair, as one number. Both are at most the
  # number of rows, so the product stays well within exact double range.
  spl_label <- !duplicated(spl * (n_spl + 1) + label)
  n_labels <- tabulate(spl[spl_label], nbins = n_spl)
  label_n_spl <- tabulate(label[spl_label], nbins = n_spl)
  label_n_idx <- tabulate(idx_label, nbins = n_spl)
  label_n_slices <- tabulate(label, nbins = n_spl)
  complete <- label_n_slices == label_n_spl * label_n_idx

  bad_spl <- unique(spl[n_labels[spl] > 1L | !complete[label]])
  # A sample covering only compound idxs that a rule-breaking sample also
  # covers can carry a single, complete label. It is involved all the same.
  bad_idx <- unique(idx[spl %in% bad_spl])
  slice_tbl[spl %in% unique(spl[idx %in% bad_idx]), ]
}

#' Find slices whose non compound task ID values differ from most slices
#'
#' Every slice in a modeling task should hold the same combinations of non
#' compound task ID values, as the `non_comp_key` argument of `spl_idx_tbl()`
#' describes. The reference is the set of combinations covered
#' by the most slices in the modeling task. A slice covering any other set does
#' not match. Where two sets are covered by equally many slices, the one whose
#' first slice comes first in sorted order is the reference.
#'
#' @param idx_rows the `rows` of `spl_idx_tbl()`, built with
#'   `non_comp_key = TRUE`.
#' @returns A list with:
#' - `slices`: the mismatched slices, with columns `mt_id`, `output_type_id`,
#'   `compound_idx` and `row_idx`, the index in `tbl` of one of the slice's
#'   rows.
#' - `reference`: for each modeling task with mismatched slices, the reference
#'   combinations, with columns `mt_id` and `row_idx`, the index in `tbl` of a
#'   row holding the combination.
#' @noRd
mismatched_non_comp_slices <- function(idx_rows) {
  slice_cols <- c("mt_id", "output_type_id", "compound_idx")
  no_mismatch <- list(
    slices = idx_rows[0L, c(slice_cols, "row_idx")],
    reference = idx_rows[0L, c("mt_id", "row_idx")]
  )
  if (nrow(idx_rows) == 0L) {
    return(no_mismatch)
  }
  # Each distinct slice and combination pair, as one number. Both are at most
  # the number of rows, so the product stays well within exact double range.
  slice <- get_group_indices(idx_rows[slice_cols])
  n_key <- max(idx_rows$non_comp_key)
  keep <- !duplicated(slice * (n_key + 1) + idx_rows$non_comp_key)
  pairs <- idx_rows[keep, ]
  slice <- slice[keep]

  # Every combination present in every slice means every slice matches. This
  # is a count per combination, so a file that passes never builds the sets
  # below. `non_comp_key` numbers combinations within a modeling task, so the
  # count is per modeling task and combination.
  mt_n_slices <- tabulate(pairs$mt_id[!duplicated(slice)])
  mt_key <- (pairs$mt_id - 1) * n_key + pairs$non_comp_key
  key_n <- tabulate(mt_key)
  present <- which(key_n > 0L)
  key_mt <- (present - 1) %/% n_key + 1
  if (all(key_n[present] == mt_n_slices[key_mt])) {
    return(no_mismatch)
  }

  # `slice` numbers the slices from 1 with none missing, so splitting by it
  # returns the slices' sets in that order.
  slice_set <- vapply(
    split(pairs$non_comp_key, slice),
    \(key) paste(sort(key), collapse = ","),
    character(1)
  )
  first_row <- match(seq_along(slice_set), slice)
  set_tbl <- tibble::tibble(
    mt_id = pairs$mt_id[first_row],
    slice = seq_along(slice_set),
    set = slice_set
  )
  reference_set <- dplyr::add_count(set_tbl, .data$mt_id, .data$set) |>
    dplyr::arrange(.data$mt_id, dplyr::desc(.data$n), .data$slice) |>
    dplyr::distinct(.data$mt_id, .keep_all = TRUE)

  ref_slice <- reference_set$slice[match(set_tbl$mt_id, reference_set$mt_id)]
  bad_slice <- set_tbl$slice[set_tbl$set != slice_set[ref_slice]]
  bad <- pairs[first_row[bad_slice], c(slice_cols, "row_idx")]
  reference <- pairs[
    slice %in% reference_set$slice & pairs$mt_id %in% bad$mt_id,
    c("mt_id", "row_idx")
  ]
  list(slices = bad, reference = reference)
}

# Slices with the compound task ID values of their compound idx, read from the
# row each slice keeps.
spl_slice_values <- function(slices, comp_tids, tbl) {
  dplyr::bind_cols(
    slices[, c("output_type_id", "compound_idx")],
    tbl[slices$row_idx, comp_tids]
  )
}

#' Name compound idxs by the compound task ID values they stand for
#'
#' A compound idx is a position in the config's combinations of compound task ID
#' values, which a submitter cannot read off their file. Messages name each one
#' by its values instead.
#'
#' @param compound_idx character vector of compound idxs.
#' @param spl_idx output of `spl_idx_tbl()`.
#' @param tbl the table `spl_idx` was built from.
#' @returns A character vector, one label per compound idx, such as
#'   `"(reference_date: 2022-10-22, location: US)"`.
#' @noRd
compound_idx_labels <- function(compound_idx, spl_idx, tbl) {
  first <- match(compound_idx, spl_idx$rows$compound_idx)
  purrr::map2_chr(
    spl_idx$rows$row_idx[first],
    spl_idx$rows$mt_id[first],
    function(row_idx, mt_id) {
      comp_tids <- spl_idx$comp_tids[[mt_id]]
      if (length(comp_tids) == 0L) {
        return(paste0("(modeling task ", mt_id, ")"))
      }
      values <- unlist(tbl[row_idx, comp_tids], use.names = FALSE)
      # Messages pass through `cli::format_inline()` again when the check
      # condition is built, so braces in values must be escaped.
      values <- gsub("([{}])", "\\1\\1", values)
      paste0("(", paste0(comp_tids, ": ", values, collapse = ", "), ")")
    }
  )
}

#' Get the compound task ID set for each modeling task in a round.
#'
#' @param config_tasks a list represention of the `tasks.json` configuration file.
#' @param round_id character string. The round ID.
#'
#' @returns a list of character vectors containing names of task IDs comprising the
#' compound task ID set, one for each model task.
#'
#' @noRd
get_round_compound_task_ids <- function(config_tasks, round_id) {
  round_mt <- hubUtils::get_round_model_tasks(config_tasks, round_id)
  purrr::map(
    round_mt,
    ~ get_model_task_compound_taskid_set(.x, config_tasks, round_id)
  )
}

get_model_task_compound_taskid_set <- function(x, config_tasks, round_id) {
  output_type_id_params <- get_mt_sample_params(x)
  if (is.null(output_type_id_params)) {
    return(NULL)
  }
  if (is.null(output_type_id_params$compound_taskid_set)) {
    return(hubUtils::get_round_task_id_names(config_tasks, round_id))
  }
  # A `compound_taskid_set` of `[]` reads back as an empty list rather than an empty
  # character vector, which no longer works as a column index.
  as.character(output_type_id_params$compound_taskid_set)
}

## --- v3 sample check utils ---------------------------------------------------
# Check whether a model ouput table has a sample output type. Returns a logical
# value.
has_spls_tbl <- function(tbl) {
  "sample" %in% tbl$output_type
}

# Check whether an R respresentation of model task configuration has a sample
# output type. Returns a logical value.
has_spls_mt <- function(mt) {
  "sample" %in% names(mt$output_type)
}

# Check whether a round configuration has a sample output type in any of it's
# model tasks. Returns a list with a logical value for each model task.
has_spls_round <- function(config_tasks, round_id) {
  hubUtils::get_round_model_tasks(config_tasks, round_id) |>
    purrr::map_lgl(~ has_spls_mt(.x))
}

# The sample settings a model task configuration carries, or `NULL` when it has
# none. A v3 sample output type always has them, so this doubles as the test for
# whether a model task samples at all.
get_mt_sample_params <- function(mt) {
  purrr::pluck(mt, "output_type", "sample", "output_type_id_params")
}

# A `compound_taskid_set` has one entry per modeling task, so a list of any
# other length cannot be lined up with the round. `NULL` asks for the sets the
# config declares and so has nothing to line up.
check_compound_taskid_set_length <- function(
  compound_taskid_set,
  n_model_tasks,
  call = rlang::caller_env()
) {
  if (
    is.null(compound_taskid_set) ||
      length(compound_taskid_set) == n_model_tasks
  ) {
    return(invisible(NULL))
  }
  cli::cli_abort(
    c(
      "x" = "{.var compound_taskid_set} must have one element for each modeling
      task in the round.",
      "i" = "The round has {.val {n_model_tasks}} modeling tasks but
      {.var compound_taskid_set} has {.val {length(compound_taskid_set)}}."
    ),
    call = call
  )
}

# Every name in a modeling task's `compound_taskid_set` has to be a task ID that
# modeling task defines, or the set asks for a grouping the modeling task cannot
# have. Dropping the name instead would group by whatever is left, which reads
# as an answer rather than as the mistake it is.
check_compound_taskid_set_names <- function(
  comp_tids,
  task_id_names,
  call = rlang::caller_env()
) {
  if (all(comp_tids %in% task_id_names)) {
    return(invisible(NULL))
  }
  invalid <- setdiff(comp_tids, task_id_names) # nolint: object_usage_linter
  cli::cli_abort(
    c(
      "x" = "{.val {invalid}} {?is/are} not valid task ID{?s}.",
      "i" = "The {.var compound_taskid_set} must be a subset of
      {.val {task_id_names}}."
    ),
    call = call
  )
}

# Check whether to skip a check designed to validate v3 samples and above and
# return a check_info class object if so.
skip_v3_spl_check <- function(file_path, call = rlang::caller_call()) {
  capture_check_info(
    file_path = file_path,
    msg = "No v3 samples found in model output data to check. Skipping {.code {call}} check.",
    call = call
  )
}

#### --- sample idx utilities --------------------------------------------------

#' Get what each modeling task needs to number its compound task ID combinations
#'
#' Read from the config once. For each modeling task extract or determine:
#' - the values its compound task IDs allow
#' - the index its own numbering starts from
#' - whether its sample IDs are character.
#' Associated function `get_compound_idx()` uses this info to determine the
#' compound idx of each row.
#'
#' For rounds with multiple mpdeling tasks, numbering continues on on from one
#' modeling task to the next, so no two modeling tasks in a round share an
#' index.
#'
#' Up to and including 2.1.1 these indices were read off an expanded value
#' grid. Determining coumpound_idxs from the config directly gives the same
#' numbering at much lower cost.
#'
#' @inheritParams expand_model_out_grid
#' @param compound_taskid_set a list of character vectors of task ID names, one
#' for each modeling task in the round, that make up the compound task ID set.
#' `NULL` for a modeling task means every one of its task IDs is compound.
#'
#' @returns A list with one element per modeling task in the round, each holding
#' the values each of its compound task IDs allow, the index its own numbering
#' starts from, and whether the config asks for character sample IDs.
#' `NULL` for a modeling task without a v3 sample configuration.
#' @noRd
get_mt_compound_idx_numbering <- function(
  config_tasks,
  round_id,
  compound_taskid_set,
  derived_task_ids,
  call = rlang::caller_env()
) {
  value_sets <- get_config_mt_value_sets(
    config_tasks = config_tasks,
    round_id = round_id,
    output_types = "sample",
    derived_task_ids = derived_task_ids,
    call = call
  )
  check_compound_taskid_set_length(
    compound_taskid_set,
    n_model_tasks = length(value_sets),
    call = call
  )
  round_mts <- hubUtils::get_round_model_tasks(config_tasks, round_id)

  numbering <- vector("list", length(value_sets))
  start_idx <- 0
  for (i in seq_along(value_sets)) {
    spl_params <- get_mt_sample_params(round_mts[[i]])
    if (is.null(spl_params)) {
      next
    }
    task_id_values <- value_sets[[i]][["task_ids"]]
    # A `NULL` set means every task ID is compound, which is how
    # `add_mt_sample_idx()` reads it too. `get_tbl_compound_taskid_set()`
    # returns `NULL` for a modeling task with no submitted samples.
    comp_tids <- compound_taskid_set[[i]]
    if (is.null(comp_tids)) {
      comp_tids <- names(task_id_values)
    } else {
      check_compound_taskid_set_names(
        comp_tids,
        names(round_mts[[i]][["task_ids"]]),
        call = call
      )
      # The config may list `compound_taskid_set` in any order, since the order
      # carries no meaning there. Put the names back into the order the config
      # lists the task IDs in, which is the order required to calculate
      # compound idxs from their values in relation to the config. See
      # get_compound_idx for more details
      comp_tids <- intersect(names(task_id_values), comp_tids)
    }
    comp_tid_values <- task_id_values[comp_tids]

    numbering[[i]] <- list(
      comp_tid_values = comp_tid_values,
      start_idx = start_idx,
      character_ids = identical(spl_params[["type"]], "character")
    )
    # The next modeling task starts past every combination this one allows,
    # which is how many values each of its compound task IDs takes, multiplied
    # together. With no compound task IDs that comes to 1, one index covering
    # the whole modeling task.
    start_idx <- start_idx + prod(lengths(comp_tid_values))
  }
  numbering
}

#' Give each row the compound index of the combination it carries
#'
#' A modeling task's `compound_taskid_set` names the task IDs that hold one
#' value throughout a sample. Each combination of their values is a separate
#' compound modeling task, and the compound index states which one a row belongs
#' to.
#'
#' Take a modeling task whose config lists three task IDs, in this order and
#' with these values:
#'
#' ```
#'   location  US, 01
#'   target    cases, deaths
#'   horizon   1, 2, 3
#' ```
#'
#' with `compound_taskid_set` `target` and `location`. A sample is then a
#' trajectory across `horizon`, and `submission_tmpl()` writes this, grouped by
#' the sample ID it hands out:
#'
#' ```
#'   location  target  horizon   compound index
#'         US   cases        1                1
#'         US   cases        2                1
#'         US   cases        3                1
#'         01   cases        1                2
#'         01   cases        2                2
#'         01   cases        3                2
#'         US  deaths        1                3
#'         US  deaths        2                3
#'         US  deaths        3                3
#'         01  deaths        1                4
#'         01  deaths        2                4
#'         01  deaths        3                4
#' ```
#'
#' The index counts through the compound task IDs in the order the config lists
#' them, not the order the set names them, and `expand.grid()` varies the
#' earlier ones faster. So `location` runs through both of its values before
#' `target` moves on by one: a step in `location` is worth 1 and a step in
#' `target` is worth 2, the number of `location` values before it.
#'
#' This function works the index out from those positions rather than building
#' the grid. For a row with `location` "01" and `target` "deaths", each the 2nd
#' value the config lists:
#'
#' ```
#' 1 + (2 - 1) * 1 + (2 - 1) * 2 = 4
#' ```
#'
#' `stride` is the multiplier, the number of values in the compound columns
#' before this one multiplied together. `start_idx` shifts the whole block past
#' the modeling tasks numbered before this one.
#' `get_mt_compound_idx_numbering()` works both of those out.
#'
#' @param mt_tbl the rows one modeling task was given, as character.
#' @param numbering that modeling task's entry from
#' `get_mt_compound_idx_numbering()`.
#' @returns A character vector with one compound index per row of `mt_tbl`, in
#' the form the checks report and `submission_tmpl()` writes.
#' @noRd
get_compound_idx <- function(mt_tbl, numbering) {
  idx <- rep(1, nrow(mt_tbl))
  stride <- 1
  for (task_id in names(numbering[["comp_tid_values"]])) {
    task_id_values <- numbering[["comp_tid_values"]][[task_id]]
    # The position of this row's value in the config's list of values for this
    # task ID. Both sides are already character, as they are when rows are
    # matched to modeling tasks, so this is a plain comparison.
    pos <- match(mt_tbl[[task_id]], task_id_values)
    idx <- idx + (pos - 1L) * stride
    stride <- stride * length(task_id_values)
  }
  idx <- idx + numbering[["start_idx"]]

  format_compound_idx(idx, numbering[["character_ids"]])
}

# The character form of a compound index, as the checks report it and
# `submission_tmpl()` writes it. `format()` rather than `as.character()`, which
# would render a large index in scientific notation, and `trim = TRUE` because
# `format()` otherwise pads to a common width. Only the distinct indices are
# formatted, since rows far outnumber them.
format_compound_idx <- function(idx, character_ids) {
  distinct_idx <- unique(idx)
  labels <- format(distinct_idx, scientific = FALSE, trim = TRUE)
  if (character_ids) {
    labels <- sprintf("s%s", labels)
  }
  labels[match(idx, distinct_idx)]
}

#' Adds example sample ids to the output type id column which are unique across
#' multiple modeling task groups. Only apply to v3 and above sample output type
#' configurations.
#'
#' @param x a list of output type data frames of expanded grid values for each
#' modeling task in a round.
#' @param round_config a list representation of round config.
#' @param config_tid character string. The name of the output type ID column in a
#' model out table. Used for back compatibility with older schema versions.
#' @param compound_taskid_set List of character vectors containing names of task IDs,
#' one for each modeling task in the round, that make up the compound task ID set.
#' If `NULL` is provided for a given modeling task, a compound task ID set of
#' all task IDs is used.
#' @returns A list of output type data frames with sample IDs added to the output
#' type ID column.
#' @noRd
add_sample_idx <- function(
  x,
  round_config,
  config_tid,
  compound_taskid_set = NULL
) {
  # Worked out here rather than passed as a default, so that it names the caller
  # of this function rather than this function's own frame.
  caller <- rlang::caller_call()
  check_compound_taskid_set_length(
    compound_taskid_set,
    n_model_tasks = length(x),
    call = caller
  )

  spl_idx_0 <- 0L
  for (i in seq_along(x)) {
    # Check that the modeling task config has a v3 sample configuration
    config_has_v3_spl <- !is.null(
      get_mt_sample_params(round_config[["model_tasks"]][[i]])
    )

    # Check that x (the output df) has a sample output type (e.g. samples could be
    # missing where only required values are requested but samples are optional)
    x_has_spl <- "sample" %in% x[[i]][["output_type"]]
    if (all(config_has_v3_spl, x_has_spl)) {
      x[[i]] <- add_mt_sample_idx(
        x = x[[i]],
        config = round_config[["model_tasks"]][[i]],
        start_idx = spl_idx_0,
        config_tid,
        comp_tids = compound_taskid_set[[i]]
      )
      spl_idx_0 <- spl_idx_0 + get_sample_n(x[[i]], config_tid)
    }
  }
  x
}

#' Add sample index to output type expanded grid data frame of a single modeling
#' task according the the compound task ID set. Only apply to v3 and above sample
#' output type configurations.
#'
#' Numbers sample IDs by expanding the grid. Only `submission_tmpl()` needs this
#' now, and it has to build the grid anyway, since generating every valid
#' combination is what a template is. `get_compound_idx()` reaches the same
#' numbering without a grid, and is what the sample checks use. Changes to
#' either function need syncing with the other.
#'
#' @param x an output type data frame of expanded grid values for a single
#' modeling task.
#' @param config a list representation of the `tasks.json` configuration file.
#' @param start_idx integer. The starting index for the sample IDs. Used to ensure
#' that sample IDs are unique across multiple modeling task groups in a round
#' when adding sample IDs to the output type ID column.
#' @param config_tid character string. The name of the output type ID column in a
#' model out table. Used for back compatibility with older schema versions.
#' @param comp_tids character vector. Names of task IDs that make up the compound
#' task ID set. Uses for determining the allocation of rows to a sample ID.
#' If `NULL` (default), all task
#' IDs are used as compound task IDs.
#' @param call the calling function. Used for error messaging.
#'
#' @returns A data frame with sample IDs added to the output type ID column.
#' @noRd
add_mt_sample_idx <- function(
  x,
  config,
  start_idx = 0L,
  config_tid,
  comp_tids = NULL,
  call = rlang::caller_call(2)
) {
  x_names <- names(x)
  task_ids <- setdiff(names(x), hubUtils::std_colnames)

  # subset to sample output type rows and only task ID columns
  spl <- x[
    x[["output_type"]] == "sample",
    task_ids
  ]

  if (is.null(comp_tids)) {
    # If the comp_tids are still NULL, then we assume that all compound task IDs
    # are being set as compound task ids.
    comp_tids <- task_ids
  } else {
    check_compound_taskid_set_names(
      comp_tids,
      names(config[["task_ids"]]),
      call = call
    )
  }

  type <- purrr::pluck(
    config,
    "output_type",
    "sample",
    "output_type_id_params",
    "type"
  )

  # Check whether some compound task IDs have only optional values
  # (i.e. the columns are missing in spl) and warn.
  # Only do so though if a specific compound task ID set is provided in the config.
  opt_comp_tids <- setdiff(comp_tids, names(spl))
  if (length(opt_comp_tids) > 0) {
    cli::cli_warn(
      "The compound task ID{?s} {.field {opt_comp_tids}} ha{?s/ve} all optional values.
      Representation of compound sample modeling tasks is not fully specified."
    )
  }
  # subset to compound task IDs that are present in spl
  comp_tids <- intersect(comp_tids, names(spl))

  # Create a unique sample ID for each unique combinations of values of compound
  # task ID set columns and join to the subset of sample output type rows.
  spl_unique <- unique(spl[, comp_tids, drop = FALSE])
  spl_unique <- dplyr::mutate(
    spl_unique,
    output_type = "sample",
    output_type_id = seq_len(nrow(spl_unique)) + start_idx
  )
  spl <- if (length(comp_tids) == 0L) {
    # No compound task IDs means the whole modeling task is one sample, so every row
    # belongs to the single sample ID.
    dplyr::cross_join(spl_unique, spl)
  } else {
    dplyr::left_join(spl_unique, spl, by = comp_tids)
  }

  if (!is.null(type) && type == "character") {
    spl[[config_tid]] <- sprintf("s%s", spl[[config_tid]])
  }

  x[x[["output_type"]] != "sample", ] |>
    rbind(spl[, x_names, drop = FALSE])
}

# Get the number of unique samples in a model out table.
get_sample_n <- function(x, config_tid) {
  x[x[["output_type"]] == "sample", config_tid, drop = TRUE] |>
    unique() |>
    length()
}
