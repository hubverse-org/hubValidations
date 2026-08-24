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

## --- Hash Table Utils --------------------------------------------------------
#' Build the sample hash table, one row per sample
#'
#' The sample metadata captured in this table is used by the subsequent sample
#' check functions to validate various sample characteristics.
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
#'
#' @returns A tibble with one row per sample and the columns:
#' - `compound_idx`: which combination of compound task ID values the sample was
#'   drawn for, taken as the commonest across its rows
#' - `n_compound_idx`: how many such combinations its rows carry, which is 1 for
#'   a well formed sample
#' - `output_type_id`: the sample's own identifier
#' - `hash_non_comp_tid`: a hash of its non compound task ID values, so two
#'   samples can be compared for covering the same ones
#' - `mt_id`: which modeling task the sample belongs to
#' @noRd
spl_hash_tbl <- function(
  tbl,
  round_id,
  config_tasks,
  compound_taskid_set = NULL,
  derived_task_ids = get_config_derived_task_ids(
    config_tasks,
    round_id
  )
) {
  tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]
  # `derived_taskids_to_na()` replaces a derived task ID's config values with
  # `NA` as the config is read. So when a derived task ID is in the compound
  # task ID set, the index worked out below can only find its value if the
  # column holds `NA` too.
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }

  # A `NULL` argument means: use the set each modeling task's config declares.
  # Fetch those, so that either way there is one set per modeling task to
  # iterate over below.
  if (is.null(compound_taskid_set)) {
    mt_compound_taskids <- get_round_compound_task_ids(
      config_tasks,
      round_id
    )
  } else {
    mt_compound_taskids <- compound_taskid_set
  }

  call <- rlang::caller_env()
  # Split tbl across modeling tasks, then give each row a compound index: a
  # number identifying which combination of compound task ID values that row
  # carries. The checks below use it to test that every row of a sample carries
  # the same combination.
  mt_row_idx <- assign_spl_tbl_rows(
    tbl,
    config_tasks = config_tasks,
    round_id = round_id,
    derived_task_ids = derived_task_ids,
    call = call
  )
  mt_numbering <- get_mt_compound_idx_numbering(
    config_tasks = config_tasks,
    round_id = round_id,
    compound_taskid_set = mt_compound_taskids,
    derived_task_ids = derived_task_ids,
    call = call
  )
  round_task_ids <- hubUtils::get_round_task_id_names(config_tasks, round_id)

  # Each modeling task's rows are subset and summarised inside the loop, so
  # memory holds `tbl` plus one modeling task's subset at a time, never a second
  # copy of the whole table.
  purrr::pmap(
    list(mt_row_idx, mt_numbering, mt_compound_taskids),
    function(row_idx, numbering, compound_taskids) {
      if (is.null(row_idx) || is.null(numbering) || length(row_idx) == 0L) {
        return(NULL)
      }
      mt_tbl <- tbl[row_idx, ]
      mt_tbl[["compound_idx"]] <- get_compound_idx(mt_tbl, numbering)
      get_mt_spl_hash_tbl(
        tbl = mt_tbl,
        compound_taskids = compound_taskids,
        round_task_ids = round_task_ids
      )
    }
  ) |>
    purrr::set_names(seq_along(mt_row_idx)) |>
    purrr::compact() |>
    # add an mt_id column to each tbl that indicates the modeling task group
    purrr::imap(~ dplyr::mutate(.x, mt_id = as.integer(.y))) |>
    purrr::list_rbind()
}

#' Create a spl hash table for samples in a single modeling task group.
#'
#' @param tbl a model output data table.
#' @param compound_taskids a character vector containing names of task IDs,
#' for the given modeling task in the round, that make up the compound task ID set.
#' If `NULL` is provided, a compound task ID set of all task IDs is used.
#' @param round_task_ids a character vector containing names of all task IDs for
#' a given modeling task in the round.
#'
#' @returns a sample hash tibble with one row per sample idx and columns containing:
#' - the compound index associated with each sample
#' - the number of compound indices in each sample
#' - the sample idx
#' - a hash of the values of non_compound_taskids in each sample
#' @noRd
get_mt_spl_hash_tbl <- function(tbl, compound_taskids, round_task_ids) {
  if (is.null(tbl)) {
    return(NULL)
  }

  non_compound_taskids <- setdiff(
    round_task_ids,
    compound_taskids
  )

  tbl <- tbl |>
    dplyr::group_by(
      .data$output_type_id
    ) |>
    # arrange by non_compound_taskids to ensure consistent ordering of values
    # when creating hashes of non_compound_taskid values.
    dplyr::arrange(
      dplyr::pick(dplyr::all_of(non_compound_taskids)),
      .by_group = TRUE
    )

  # split tbl by sample idx (contained in the output_type_id column)
  split(tbl, f = tbl$output_type_id) |>
    purrr::map(
      ~ sample_properties_tbl(.x, non_compound_taskids)
    ) |>
    purrr::list_rbind()
}

sample_properties_tbl <- function(x, non_compound_taskids) {
  # Create tibble of sample properties for each sample idx to be used to
  # validate various sample expectations.
  tibble::tibble(
    # get the value of the most common compound_idx in the sample. Used to
    # determine which compound_idx the sample belongs to. Using this approach to
    # ensure errors in sample indexing do not affect attempt to assign a
    # sample to a compound_idx.
    compound_idx = names(sort(table(x$compound_idx), decreasing = TRUE))[1L],
    # Number of compound_idx values in the sample. Used to detect misallocation
    # of sample ids.
    n_compound_idx = length(unique(x$compound_idx)),
    # capture value of sample idx.
    output_type_id = unique(x$output_type_id),
    # Create hash of values of non_compound_taskids to check for consistency
    # across sample.
    hash_non_comp_tid = rlang::hash(x[, non_compound_taskids])
  )
}

# Get output type IDs (`sample_idx`s`) associated with a given hash from the
# sample hash table
get_hash_out_type_ids <- function(
  hash_tbl,
  hash,
  hash_type = "hash_non_comp_tid",
  n = NULL
) {
  has_hash <- hash_tbl[[hash_type]] %in% hash
  out <- hash_tbl$output_type_id[has_hash]

  if (is.null(n)) {
    out
  } else {
    utils::head(out, n)
  }
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
