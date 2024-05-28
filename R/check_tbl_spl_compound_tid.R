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

  n_tbl <- dplyr::group_by(hash_tbl, .data$compound_idx) %>%
    dplyr::summarise(n = dplyr::n_distinct(.data$hash_comp_tid)) %>%
    dplyr::filter(.data$n > 1L)

  check <- nrow(n_tbl) == 0L

  if (check) {
    details <- NULL
    errors <- NULL
  } else {
    errors <- comptid_mismatch(
      n_tbl$compound_idx, hash_tbl, tbl
    )
    mismatches <- purrr::map_chr(errors, ~ .x$mismatches) # nolint: object_usage_linter
    details <- cli::format_inline(
      "Sample{?s} {.val {mismatches}} d{?oes/o} not match most prevalent ",
      "task ID combination for {?its/their} compound idx. ",
      "See {.var errors} attribute for details."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Task ID combinations across compound idx samples",
    msg_attribute = NULL,
    msg_verbs = c("consistent.", "not consistent."),
    details = details,
    errors = errors
  )
}

comptid_mismatch <- function(x, hash_tbl, tbl) {
  purrr::map(
    purrr::set_names(x),
    ~ {
      hash_n <- hash_tbl[
        hash_tbl$compound_idx == .x,
        "hash_comp_tid"
      ] %>%
        table() %>%
        sort(decreasing = TRUE) %>%
        names()

      mismatches <- get_hash_out_type_ids(
        hash_tbl,
        hash = hash_n[-1L],
        hash_type = "hash_comp_tid"
      )
      prevalent_hash <- get_hash_out_type_ids(hash_tbl,
        hash = hash_n[1L],
        hash_type = "hash_comp_tid",
        n = 1
      )
      prevalent <- tbl[
        tbl$output_type == "sample" & tbl$output_type_id == prevalent_hash,
        setdiff(names(tbl), c("output_type_id", "value", "output_type"))
      ]
      list(
        compound_idx = .x,
        prevalent_task_ids = prevalent,
        mismatches = mismatches
      )
    }
  )
}
