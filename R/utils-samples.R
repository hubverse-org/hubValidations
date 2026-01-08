## --- Hash Table Utils --------------------------------------------------------
#' Creates a tibble of sample properties for each sample idx to be enable validation
#' of various sample expectations, e.g. the consistency of compound task ID values and
#' non-compound task IDs values in each sample.
#'
#' Performed separately across each modeling task (to allow for differences in
#' compound task id sets across modeling tasks). Only valid task id combinations
#' are considered.
#'
#' @param tbl a model output data table.
#' @param round_id character string. The round ID.
#' @param config_tasks a list represention of the `tasks.json` configuration file.
#' @param compound_taskids a list of character vectors containing names of task IDs,
#' one for each modeling task in the round, that make up the compound task ID set.
#' If `NULL` is provided for a given modeling task, a compound task ID set of
#' all task IDs is used.
#' @param derived_task_ids a character vector of derived task IDs. Defaults to
#' derived task IDs set in the config.
#'
#' @returns a sample hash tibble with one row per sample idx and columns containing:
#' - the compound index associated with each sample
#' - the number of compound indices in each sample
#' - the sample idx
#' - a hash of the values of non_compound_taskids in each sample
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
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }

  # Create an expanded grid of valid values for the sample output type for each
  # model task. The function returns a list of expanded grids, one for each model task.
  # The output_type_id contains the compound_idx determined by the compound_taskid_set.
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

  # Iterate over each modeling task expanded grid.
  # First rename the output_type_id column in the expanded grid to compound_idx
  # to retain information about expected task ID value groupings according to the
  # compound_taskid_set.
  # Then separate tbl into model tasks by joining it to each processed model task
  # expanded grid.
  mt_tbls <- purrr::map(
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

  # Convert a `NULL` compound task ID set (which indicates all task IDs contribute
  # to the compound_idx) to a list of compound_taskid_sets, one for each modeling task,
  # that can be iterated over.
  if (is.null(compound_taskid_set)) {
    mt_compound_taskids <- get_round_compound_task_ids(
      config_tasks,
      round_id
    )
  } else {
    mt_compound_taskids <- compound_taskid_set
  }

  purrr::map2(
    mt_tbls,
    mt_compound_taskids,
    ~ get_mt_spl_hash_tbl(
      tbl = .x,
      compound_taskids = .y,
      round_task_ids = hubUtils::get_round_task_id_names(
        config_tasks,
        round_id
      )
    )
  ) |>
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
  output_type_id_params <- purrr::pluck(
    x,
    "output_type",
    "sample",
    "output_type_id_params"
  )
  if (is.null(output_type_id_params)) {
    return(NULL)
  }
  if (is.null(output_type_id_params$compound_taskid_set)) {
    return(hubUtils::get_round_task_id_names(config_tasks, round_id))
  }
  output_type_id_params$compound_taskid_set
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

# Check whether a list of expanded grids has a sample output type in any of it's
# model tasks. Returns a list with a logical value for each model task.
has_spls_mt_grid <- function(grid_l) {
  purrr::map_lgl(grid_l, ~ has_spls_tbl(.x))
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
  if (
    !is.null(compound_taskid_set) && length(compound_taskid_set) != length(x)
  ) {
    cli::cli_abort(
      c(
        "x" = "The length of {.var compound_taskid_set}
      ({.val {length(compound_taskid_set)}})
      must match the number of modeling tasks ({.val {length(x)}})
        in the round."
      ),
      call = rlang::caller_call()
    )
  }

  spl_idx_0 <- 0L
  for (i in seq_along(x)) {
    # Check that the modeling task config has a v3 sample configuration
    config_has_v3_spl <- purrr::pluck(
      round_config[["model_tasks"]][[i]],
      "output_type",
      "sample",
      "output_type_id_params"
    ) |>
      is.null() |>
      isFALSE()

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
    if (isFALSE(all(comp_tids %in% names(config$task_ids)))) {
      cli::cli_abort(
        c(
          "x" = "{.val {setdiff(comp_tids, names(config$task_ids))}} {?is/are}
          not valid task ID{?s}.",
          "i" = "The {.var compound_taskid_set} must be a subset of
          {.val {names(config$task_ids)}}."
        ),
        call = call
      )
    }
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
  spl <- dplyr::left_join(spl_unique, spl, by = comp_tids)

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
