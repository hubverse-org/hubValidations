#' Detect the compound_taskid_set for a tbl for each modeling task in a given round.
#'
#' @param tbl a tibble/data.frame of the contents of the file being validated.
#' Column types must **all be character**.
#' @param config_tasks a list representantion of the `tasks.json` config file.
#' @param round_id Character string. The round ID.
#' @param compact Logical. If TRUE, the output will be compacted to remove NULL elements.
#' @param error Logical. If TRUE, an error will be thrown if the compound task ID set is not valid.
#' If FALSE and an error is detected, the detected compound task ID set will be
#' returned with error attributes attached.
#' @inheritParams expand_model_out_grid
#'
#' @return A list of vectors of compound task IDs detected in the tbl, one for each
#' modeling task in the round. If `compact` is TRUE, modeling tasks returning NULL
#' elements will be removed.
#' @export
#' @examples
#' hub_path <- system.file("testhubs/samples", package = "hubValidations")
#' file_path <- "flu-base/2022-10-22-flu-base.csv"
#' round_id <- "2022-10-22"
#' tbl <- read_model_out_file(
#'   file_path = file_path,
#'   hub_path = hub_path,
#'   coerce_types = "chr"
#' )
#' config_tasks <- hubUtils::read_config(hub_path, "tasks")
#' get_tbl_compound_taskid_set(tbl, config_tasks, round_id)
#' get_tbl_compound_taskid_set(tbl, config_tasks, round_id,
#'   compact = FALSE
#' )
#'
get_tbl_compound_taskid_set <- function(tbl, config_tasks, round_id,
                                        compact = TRUE, error = TRUE,
                                        derived_task_ids = get_config_derived_task_ids(
                                          config_tasks, round_id
                                        )) {
  if (!inherits(tbl, "tbl_df")) {
    tbl <- dplyr::as_tibble(tbl)
  }
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }
  tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]
  out_tid <- hubUtils::std_colnames["output_type_id"]

  mt_compound_taskids <- get_round_compound_task_ids(
    config_tasks,
    round_id
  )

  mt_tbls <- purrr::map(
    .x = expand_model_out_grid(
      config_tasks = config_tasks,
      round_id = round_id,
      all_character = TRUE,
      include_sample_ids = FALSE,
      bind_model_tasks = FALSE,
      output_types = "sample",
      derived_task_ids = derived_task_ids
    ),
    function(.x) {
      if (nrow(.x) == 0L) {
        return(NULL)
      }
      dplyr::inner_join(tbl, .x[, names(.x) != out_tid],
        by = setdiff(names(tbl), out_tid)
      )
    }
  )

  call <- rlang::current_env()
  tbl_compound_taskids <- purrr::map2(
    mt_tbls, mt_compound_taskids, function(.x, .y) {
      get_mt_compound_taskid_set(.x, .y, config_tasks,
        error = error, call = call
      )
    }
  ) %>%
    purrr::set_names(seq_along(.))

  if (compact) {
    tbl_compound_taskids <- purrr::compact(tbl_compound_taskids)
  }

  tbl_compound_taskids
}

# Detect the compound_taskid_set for a tbl for a single modeling task.
get_mt_compound_taskid_set <- function(tbl, config_comp_tids, config_tasks,
                                       error = TRUE, call = NULL) {
  if (any(is.null(tbl), is.null(config_comp_tids))) {
    return(NULL)
  }

  if (nrow(tbl) == 0L) {
    return(NULL)
  }
  if (is.null(call)) call <- rlang::current_env()
  out_tid <- hubUtils::std_colnames["output_type_id"]
  task_ids <- hubUtils::get_task_id_names(config_tasks)

  # Count number of unique values per sample (output_type_id) for each task ID column and
  # return TRUE if 1 which would indicate a task ID can be considered a compound_taskid
  spl_uniq <- tbl[, c(task_ids, out_tid)] |>
    dplyr::group_by(.data[[out_tid]]) |>
    dplyr::summarise(
      dplyr::across(
        dplyr::everything(),
        function(.x) {
          dplyr::n_distinct(.x) == 1L
        }
      )
    )

  # Count number of unique values for each task ID column across tbl and
  # return TRUE if greater than 1.
  # The aim of this check is to distinguish between false positives, resulting
  # from task ids that can only take a single value or where only 1 value
  # is required or all are optional and only one has been provided, so here we also check
  # whether the value is consistent across other samples. If a single unique value
  # is consistent across all samples for a task id, it cannot be considered a
  # compound_taskid and therefore FALSE will be returned. Note that this check
  # only applies to task ids that are not members of the compound_taskids set.
  # compound_taskids set vars will always be set to TRUE in this check.
  tbl_non_uniq <- tbl[, task_ids] |>
    purrr::map(~ dplyr::n_distinct(.x) > 1L) |>
    tibble::as_tibble()
  tbl_non_uniq[, config_comp_tids] <- TRUE

  # Create a sample (output_type_id) vs compound_taskid membership boolean matrix.
  # For a task id to be considered a compound_taskid, a unique value must be TRUE
  # at the sample level and we need to ensure it's not a false positive.
  # Here we combine the two checks.
  is_compound_taskid <- apply(spl_uniq[, task_ids], 1,
    function(x) x & tbl_non_uniq[, task_ids],
    simplify = FALSE
  ) |> purrr::reduce(rbind)

  output_type_ids <- spl_uniq[["output_type_id"]]

  tbl_comp_tids <- true_to_names_vector(is_compound_taskid)

  if (length(tbl_comp_tids) > 1L) {
    error_msg <- "More than 1 unique {.var compound_taskid_set} detected."
    if (error) {
      error_bullets <- purrr::map_chr(
        tbl_comp_tids,
        .f = function(.x) {
          paste0("{.val ", .x, "}") |>
            paste(collapse = ", ") |>
            stats::setNames("*") |>
            rlang::format_error_bullets()
        }
      )
      cli::cli_abort(c("x" = error_msg, error_bullets), call = call)
    }
    # Attach error attributes
    attributes(tbl_comp_tids) <- list(
      errors = get_comp_tid_sample_ids(is_compound_taskid, output_type_ids),
      msg = cli::format_inline(error_msg, " See `errors` attribute for details.")
    )
    return(tbl_comp_tids)
  }

  tbl_comp_tids <- unlist(tbl_comp_tids)

  if (!all(tbl_comp_tids %in% config_comp_tids)) {
    invalid_tbl_comp_tids <- setdiff(tbl_comp_tids, config_comp_tids)

    error_vec <- c(
      "x" = "Finer {.var compound_taskid_set} than allowed detected.",
      "!" = "{.val {invalid_tbl_comp_tids}} identified as compound task ID{?s} in file but not allowed in config.",
      "i" = "Compound task IDs should be one of {.val {config_comp_tids}}."
    )

    if (error) {
      cli::cli_abort(error_vec, call = call)
    }

    # Attach error attributes
    errors <- get_comp_tid_sample_ids(is_compound_taskid, output_type_ids) |>
      purrr::map(function(.x) {
        if (any(.x$tbl_comp_tids %in% invalid_tbl_comp_tids)) {
          c(list(
            config_comp_tids = config_comp_tids,
            invalid_tbl_comp_tids = invalid_tbl_comp_tids
          ), .x)
        }
      }) |>
      purrr::compact()

    attributes(tbl_comp_tids) <- list(
      errors = errors,
      msg = cli::format_inline(paste(error_vec, collapse = " "))
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
  v <- apply(x, 1,
    function(x) names(x)[x],
    simplify = FALSE
  )
  v
}

# Get list of vectors of output type IDs of samples conforming to each compound task ID
# set detected from a sample compound task id membership matrix.
#  Should be used at the modeling task level.
get_comp_tid_sample_ids <- function(is_compound_taskid, output_type_ids) {
  is_compound_taskid <- tibble::as_tibble(is_compound_taskid) |> dplyr::group_by_all()

  purrr::map2(
    .x = dplyr::group_map(is_compound_taskid, ~ list(
      output_type_ids = output_type_ids[as.integer(rownames(.x))]
    )),
    .y = true_to_names_vector(dplyr::group_keys(is_compound_taskid)),
    ~ c(list(tbl_comp_tids = .y), .x)
  )
}
