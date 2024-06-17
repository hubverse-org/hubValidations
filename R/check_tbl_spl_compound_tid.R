#' Check model output data tbl samples contain consistent task ID
#' combinations for a given compound idx.
#' @param tbl a tibble/data.frame of the contents of the file being validated. Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @export
check_tbl_spl_compound_tid <- function(tbl, round_id, file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  if (isFALSE(has_spls_tbl(tbl)) || isFALSE(hubUtils::is_v3_config(config_tasks))) {
    return(skip_v3_spl_check(file_path))
  }

  hash_tbl <- spl_hash_tbl(tbl, round_id, config_tasks)
  # TODO: Currently, samples must strictly match the compound task ID set expectations
  # and cannot handle coarser-grained compound task ID sets.
  n_tbl <- hash_tbl[hash_tbl$n_compound_idx > 1L, ]

  check <- nrow(n_tbl) == 0L

  if (check) {
    details <- NULL
    errors <- NULL
  } else {
    errors <- comptid_mismatch(
      n_tbl, tbl, config_tasks, round_id
    )
    output_type_ids <- purrr::map(errors, ~ .x$output_type_id) %>% # nolint: object_usage_linter
      purrr::flatten_chr() %>% unique() %>% sort()

    details <- cli::format_inline(
      "Sample{?s} {.val {output_type_ids}} d{?oes/o} not contain ",
      "unique compound task ID combinations. ",
      "See {.var errors} attribute for details."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Each sample",
    msg_attribute = "single, unique compound task ID set value combination.",
    msg_verbs = c("contains", "does not contain"),
    details = details,
    errors = errors
  )
}

comptid_mismatch <- function(n_tbl, tbl, config_tasks, round_id) {
  tbl <- tbl[tbl$output_type == "sample", ]
  purrr::map(
    seq_along(n_tbl$output_type_id),
    ~ {
      x <- n_tbl[.x, ]
      compound_taskids <- get_round_compound_task_ids(config_tasks, round_id)[[x$mt_id]]
      spl <- tbl[tbl$output_type_id == x$output_type_id, compound_taskids] %>%
        unique()

      mismatches <- spl[, purrr::map_lgl(spl, ~ length(unique(.x)) > 1L)] %>%
        as.list() %>%
        purrr::map(unique)

      list(
        output_type_id = x$output_type_id,
        mismatches = mismatches
      )
    }
  )
}
