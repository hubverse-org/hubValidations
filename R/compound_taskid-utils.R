#' Detect the compound_taskid_set for a tbl for each modeling task in a given round.
#'
#' @param config_tasks a list representantion of the `tasks.json` config file.
#' @param round_id Character string. The round ID.
#' @param compact Logical. If TRUE, the output will be compacted to remove NULL elements.
#' @param error Logical. If TRUE, an error will be thrown if the compound task ID set is not valid.
#' If FALSE and an error is detected, the detected compound task ID set will be
#' returned with error attributes attached.
#' @inheritParams expand_model_out_grid
#' @inheritParams check_tbl_spl_mt_unique
#' @inheritParams check_tbl_values
#'
#' @return A list of vectors of compound task IDs detected in the tbl, one for each
#' modeling task in the round. If `compact` is TRUE, modeling tasks returning NULL
#' elements will be removed.
#'
#' Samples in a modeling task can have different compound task ID sets. The
#' vector then holds every task ID detected as compound for any of its samples,
#' and the `sets` attribute lists each set with the output type IDs of its
#' samples. See the Compound modeling tasks section of
#' [check_tbl_spl_compound_taskid_set()] for an example.
#' @export
#' @examples
#' hub_path <- system.file("testhubs/samples", package = "hubValidations")
#' file_path <- "flu-base/2022-10-22-flu-base.csv"
#' round_id <- "2022-10-22"
#' tbl_chr <- read_model_out_file(
#'   file_path = file_path,
#'   hub_path = hub_path,
#'   coerce_types = "chr"
#' )
#' config_tasks <- read_config(hub_path, "tasks")
#' get_tbl_compound_taskid_set(tbl_chr, config_tasks, round_id)
#' get_tbl_compound_taskid_set(tbl_chr, config_tasks, round_id,
#'   compact = FALSE
#' )
#'
get_tbl_compound_taskid_set <- function(
  tbl_chr,
  config_tasks,
  round_id,
  compact = TRUE,
  error = TRUE,
  derived_task_ids = get_config_derived_task_ids(
    config_tasks,
    round_id
  ),
  spl_idx = NULL
) {
  assert_tbl_chr(tbl_chr)
  spl_idx <- spl_idx %||%
    spl_idx_tbl(
      tbl_chr,
      round_id,
      config_tasks,
      derived_task_ids = derived_task_ids
    )

  mt_compound_taskids <- get_round_compound_task_ids(
    config_tasks,
    round_id
  )
  task_ids <- hubUtils::get_round_task_id_names(config_tasks, round_id)

  call <- rlang::current_env()
  # Each modeling task declares its own compound task ID set, so the sample
  # index is split into modeling tasks first.
  mt_rows <- split_by_mt(seq_len(nrow(spl_idx$rows)), spl_idx) |>
    unname()
  tbl_compound_taskids <- purrr::map2(
    mt_rows,
    mt_compound_taskids,
    function(rows, compound_taskids) {
      if (is.null(compound_taskids) || length(rows) == 0L) {
        return(NULL)
      }
      membership <- spl_comp_tid_membership(
        spl_idx$rows[rows, c("output_type_id", "row_idx")],
        tbl_chr,
        compound_taskids,
        task_ids,
        derived_task_ids
      )
      get_mt_compound_taskid_set(
        membership$is_compound_taskid,
        membership$output_type_ids,
        compound_taskids,
        error = error,
        call = call
      )
    }
  )
  tbl_compound_taskids <- purrr::set_names(
    tbl_compound_taskids,
    seq_along(tbl_compound_taskids)
  )

  if (compact) {
    # Only modeling tasks without samples are dropped. An empty detected set
    # is an answer rather than an absence, so it stays, which
    # `purrr::compact()` would not do because it drops anything of length zero.
    tbl_compound_taskids <- purrr::discard(tbl_compound_taskids, is.null)
  }

  tbl_compound_taskids
}

#' Find which task IDs each sample of a modeling task is compound across
#'
#' A task ID is compound for a sample when the sample holds a single value of
#' it. A task ID that holds a single value across the whole modeling task says
#' nothing about how samples were drawn, so it is compound only if the config
#' lists it as compound. A derived task ID is compound exactly when the config
#' lists it, since its values follow from the other task IDs.
#'
#' @param idx_rows the `output_type_id` and `row_idx` columns of the `rows` of
#'   `spl_idx_tbl()`, for one modeling task.
#' @param tbl_chr the table the index was built from.
#' @param config_comp_tids the modeling task's configured compound task IDs.
#' @param task_ids the round's task ID names.
#' @param derived_task_ids a character vector of derived task IDs.
#' @returns A list with:
#' - `is_compound_taskid`: a tibble with one logical column per task ID and
#'   one row per sample.
#' - `output_type_ids`: the samples' output type IDs, in the order of the rows
#'   of `is_compound_taskid`.
#' @noRd
spl_comp_tid_membership <- function(
  idx_rows,
  tbl_chr,
  config_comp_tids,
  task_ids,
  derived_task_ids
) {
  # Samples are numbered in C-locale order, which is the order the `sets`
  # attribute lists their output type IDs in.
  first <- which(!duplicated(idx_rows$output_type_id))
  first <- first[order(
    idx_rows$output_type_id[first],
    method = "radix",
    na.last = TRUE
  )]
  output_type_ids <- idx_rows$output_type_id[first]
  spl <- match(idx_rows$output_type_id, output_type_ids)

  is_compound_taskid <- purrr::map(
    purrr::set_names(task_ids),
    function(task_id) {
      if (task_id %in% derived_task_ids) {
        return(rep(task_id %in% config_comp_tids, length(output_type_ids)))
      }
      values <- tbl_chr[[task_id]][idx_rows$row_idx]
      first_values <- values[first]
      single_value <- tabulate(
        spl[differs_from(values, first_values[spl])],
        nbins = length(output_type_ids)
      ) ==
        0L
      if (task_id %in% config_comp_tids) {
        return(single_value)
      }
      # A task ID varies across the modeling task when some sample holds more
      # than one value of it, or when samples hold different single values.
      varies <- !all(single_value) ||
        any(differs_from(first_values, first_values[1L]))
      single_value & varies
    }
  ) |>
    tibble::as_tibble()

  list(
    is_compound_taskid = is_compound_taskid,
    output_type_ids = output_type_ids
  )
}

# Element-wise `x != y`, with `NA` treated as a value like any other. `y` is
# either as long as `x` or a single value.
differs_from <- function(x, y) {
  differs <- x != y
  na <- which(is.na(differs))
  if (length(na) > 0L) {
    y_na <- if (length(y) == 1L) is.na(y) else is.na(y[na])
    differs[na] <- is.na(x[na]) != y_na
  }
  differs
}

#' Collect the compound task ID sets detected for a modeling task's samples
#'
#' @param is_compound_taskid a sample by task ID logical table, as returned by
#'   `spl_comp_tid_membership()`.
#' @param output_type_ids the samples' output type IDs, in the order of the
#'   rows of `is_compound_taskid`.
#' @param config_comp_tids the modeling task's configured compound task IDs.
#' @inheritParams get_tbl_compound_taskid_set
#' @param call the environment errors are reported from.
#' @returns A character vector of every task ID detected as compound for any
#'   sample, with the `sets` attribute when samples have different sets, and
#'   the `errors` and `msg` attributes when a set is finer than configured.
#' @noRd
get_mt_compound_taskid_set <- function(
  is_compound_taskid,
  output_type_ids,
  config_comp_tids,
  error = TRUE,
  call = rlang::caller_env()
) {
  task_ids <- names(is_compound_taskid)
  # Samples in one modeling task can have different compound task ID sets, as
  # in the example in the docs of `check_tbl_spl_compound_taskid_set()`. Each
  # set is valid if it matches or is coarser than the configured set, that is,
  # if it is a subset. So the union of the sets is a subset of the configured
  # set exactly when every set is.
  spl_sets <- get_comp_tid_sample_ids(is_compound_taskid, output_type_ids)
  tbl_comp_tids <- intersect(
    task_ids,
    unlist(purrr::map(spl_sets, "tbl_comp_tids"))
  )
  if (length(spl_sets) > 1L) {
    attr(tbl_comp_tids, "sets") <- spl_sets
  }

  if (!all(tbl_comp_tids %in% config_comp_tids)) {
    invalid_tbl_comp_tids <- setdiff(tbl_comp_tids, config_comp_tids)

    expected_msg <- if (length(config_comp_tids) == 0L) {
      "The hub expects no compound task IDs and response dependence across all
      task IDs."
    } else {
      "Compound task IDs should be one of {.val {config_comp_tids}}."
    }

    error_vec <- c(
      "x" = "Detected a finer {.var compound_taskid_set} than the hub accepts.",
      "!" = "{.val {invalid_tbl_comp_tids}} identified as compound task ID{?s} in file but not accepted by the hub.",
      "i" = expected_msg
    )

    if (error) {
      cli::cli_abort(error_vec, call = call)
    }

    # Attach error attributes
    errors <- spl_sets |>
      purrr::map(function(.x) {
        if (any(.x$tbl_comp_tids %in% invalid_tbl_comp_tids)) {
          c(
            list(
              config_comp_tids = config_comp_tids,
              invalid_tbl_comp_tids = setdiff(
                .x$tbl_comp_tids,
                config_comp_tids
              )
            ),
            .x
          )
        }
      }) |>
      purrr::compact()

    attr(tbl_comp_tids, "errors") <- errors
    attr(tbl_comp_tids, "msg") <- cli::format_inline(
      paste(error_vec, collapse = " ")
    )
  }
  tbl_comp_tids
}

# Helper functions ----
# Extract the names of the columns that are TRUE in each row
true_to_names_vector <- function(x, cols = NULL, unique = TRUE) {
  if (!is.null(cols)) {
    x <- x[, cols, drop = FALSE]
  }
  if (unique) {
    x <- unique(x)
  }
  v <- apply(x, 1, function(x) names(x)[x], simplify = FALSE)
  v
}

# Get list of vectors of output type IDs of samples conforming to each compound task ID
# set detected from a sample compound task id membership matrix, in the order
# the sets first appear. Should be used at the modeling task level.
get_comp_tid_sample_ids <- function(is_compound_taskid, output_type_ids) {
  is_compound_taskid <- tibble::as_tibble(is_compound_taskid)
  set_key <- do.call(paste, unname(as.list(is_compound_taskid)))
  first <- !duplicated(set_key)
  set_key <- factor(set_key, levels = set_key[first])

  purrr::map2(
    .x = true_to_names_vector(is_compound_taskid[first, ], unique = FALSE),
    .y = unname(split(output_type_ids, set_key)),
    ~ list(tbl_comp_tids = .x, output_type_ids = .y)
  )
}

#' Detect groups of samples whose detected compound_taskid_set is coarser than
#' configured.
#' @param detected List of detected compound_taskid_set vectors (one per model
#'   task), as returned by `get_tbl_compound_taskid_set()`.
#' @param configured List of configured compound_taskid_set vectors (one per
#'   model task).
#' @returns List of info entries (one per coarser set of samples) with fields
#'   `mt_idx`, `detected`, `configured` and `output_type_ids`.
#'   `output_type_ids` is `NULL` when all samples in the modeling task share
#'   the set. Empty list if no samples are coarser.
#' @noRd
detect_coarser_compound_taskid_set <- function(detected, configured) {
  purrr::pmap(
    list(det = detected, conf = configured, mt_idx = seq_along(detected)),
    function(det, conf, mt_idx) {
      if (is.null(det) || is.null(conf)) {
        return(NULL)
      }
      spl_sets <- attr(det, "sets") %||%
        list(list(tbl_comp_tids = det, output_type_ids = NULL))
      purrr::map(spl_sets, function(spl_set) {
        set <- spl_set$tbl_comp_tids
        if (length(set) < length(conf) || !all(conf %in% set)) {
          list(
            mt_idx = mt_idx,
            detected = set,
            configured = conf,
            output_type_ids = spl_set$output_type_ids
          )
        }
      })
    }
  ) |>
    purrr::list_flatten() |>
    purrr::compact()
}

#' Build a brief `validation_warning` flagging which modeling tasks have
#' coarser-than-configured compound_taskid_sets. Warning points to check
#' `details` and `compound_taskid_set` fields rather than duplicating them, so
#' it remains concise when surfaced in aggregated warning summaries.
#' @param coarser_info Output of `detect_coarser_compound_taskid_set()`.
#' @returns A list of length 1 containing a `validation_warning`, or `NULL`
#'   if no coarser modeling tasks.
#' @noRd
coarser_compound_taskid_set_warnings <- function(coarser_info) {
  if (length(coarser_info) == 0L) {
    return(NULL)
  }
  mt_idx <- unique(purrr::map_int(coarser_info, "mt_idx")) # nolint: object_usage_linter
  n_mts <- length(mt_idx) # nolint: object_usage_linter
  msg <- cli::format_inline(
    "Coarser-than-configured {.var compound_taskid_set} detected for ",
    "{cli::qty(n_mts)}modeling task{?s} {.val {mt_idx}}. ",
    "See check {.field message} for specifics."
  )
  list(capture_validation_warning(msg = msg))
}

#' Compile a brief per-modeling-task details string for the check message
#' when coarser compound_taskid_sets are detected.
#' @param coarser_info Output of `detect_coarser_compound_taskid_set()`.
#' @returns A single character string, or `NULL` if no coarser info.
#' @noRd
compile_coarser_details <- function(coarser_info) {
  if (length(coarser_info) == 0L) {
    return(NULL)
  }
  purrr::map_chr(coarser_info, function(info) {
    mt_idx <- info$mt_idx # nolint: object_usage_linter
    det_label <- if (length(info$detected) == 0L) "none" else info$detected # nolint: object_usage_linter
    conf <- info$configured # nolint: object_usage_linter
    spl_ids <- escape_braces(info$output_type_ids) # nolint: object_usage_linter
    cli::format_inline(
      "mt {mt_idx}: detected ({.val {det_label}}) is coarser than ",
      "configured ({.val {conf}})",
      if (length(spl_ids) > 0L) {
        " for {cli::qty(spl_ids)}sample{?s} {.val {spl_ids}}"
      },
      "."
    )
  }) |>
    paste(collapse = " ")
}
