#' Check model output data tbl samples contain single unique values for each
#' compound task ID within individual samples
#'
#' @param tbl a tibble/data.frame of the contents of the file being validated. Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @param compound_taskid_set a list of `compound_taskid_set`s (characters vector of compound task IDs),
#' one for each modeling task. Used to override the compound task ID set in the config file,
#' for example, when validating coarser samples.
#' @details Output of the check includes an `errors` element, a list of items,
#' one for each sample failing validation, with the following structure:
#' - `mt_id`: Index identifying the config modeling task the sample is associated with.
#' - `output_type_id`: The output type ID of the sample that does not contain a
#' single, unique value for each compound task ID.
#' - `values`: The unique values of each compound task ID.
#' See [hubverse documentation on samples](https://hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @export
check_tbl_spl_compound_tid <- function(tbl, round_id, file_path, hub_path,
                                       compound_taskid_set = NULL) {
  if (!is.null(compound_taskid_set) && isTRUE(is.na(compound_taskid_set))) {
    cli::cli_abort("Valid {.var compound_taskid_set} must be provided.")
  }
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  if (is.null(compound_taskid_set)) {
    compound_taskid_set <- get_round_compound_task_ids(
      config_tasks,
      round_id
    )
  }

  if (isFALSE(has_spls_tbl(tbl)) || isFALSE(hubUtils::is_v3_config(config_tasks))) {
    return(skip_v3_spl_check(file_path))
  }

  hash_tbl <- spl_hash_tbl(tbl, round_id, config_tasks, compound_taskid_set)
  # TODO: Currently, samples must strictly match the compound task ID set expectations
  # and cannot handle coarser-grained compound task ID sets.
  n_tbl <- hash_tbl[hash_tbl$n_compound_idx > 1L, ]

  check <- nrow(n_tbl) == 0L

  if (check) {
    details <- NULL
    errors <- NULL
  } else {
    errors <- comptid_mismatch(
      n_tbl, tbl, config_tasks, round_id, compound_taskid_set
    )
    output_type_ids <- purrr::map(errors, ~ .x$output_type_id) %>% # nolint: object_usage_linter
      purrr::flatten_chr() %>%
      unique() %>%
      sort()

    details <- cli::format_inline(
      "Sample{?s} {.val {output_type_ids}} d{?oes/o} not contain ",
      "unique compound task ID combinations. ",
      "See {.var errors} attribute for details."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Each sample compound task ID",
    msg_attribute = "single, unique value.",
    msg_verbs = c("contains", "does not contain"),
    details = details,
    errors = errors,
    error = TRUE
  )
}

comptid_mismatch <- function(n_tbl, tbl, config_tasks, round_id, compound_taskid_set) {
  tbl <- tbl[tbl$output_type == "sample", ]
  purrr::map(
    seq_along(n_tbl$output_type_id),
    ~ {
      x <- n_tbl[.x, ]
      compound_taskids <- compound_taskid_set[[x$mt_id]]
      spl <- tbl[tbl$output_type_id == x$output_type_id, compound_taskids] %>%
        unique()

      values <- spl[, purrr::map_lgl(spl, ~ length(unique(.x)) > 1L)] %>%
        as.list() %>%
        purrr::map(unique)

      list(
        mt_id = x$mt_id,
        output_type_id = x$output_type_id,
        values = values
      )
    }
  )
}
