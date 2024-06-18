#' Check model output data tbl samples contain single unique combination of
#' non-compound task ID values across all samples
#' @param tbl a tibble/data.frame of the contents of the file being validated. Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @details Output of the check includes an `errors` element, a list of items,
#' one for each modeling task containing samples failing validation,
#' with the following structure:
#' - `mt_id`: Index identifying the config modeling task the samples are associated with.
#' - `output_type_ids`: The output type IDs of samples that do not match the most prevalent
#' non-compound task ID value combination across all
#' samples in the modeling task.
#' - `prevalent`: The most prevalent non-compound task ID value combination
#' across all samples in the modeling task to which all samples were compared.
#' See [hubverse documentation on samples](https://hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @export
check_tbl_spl_non_compound_tid <- function(tbl, round_id, file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  if (isFALSE(has_spls_tbl(tbl)) || isFALSE(hubUtils::is_v3_config(config_tasks))) {
    return(skip_v3_spl_check(file_path))
  }

  hash_tbl <- spl_hash_tbl(tbl, round_id, config_tasks)

  n_tbl <- dplyr::summarise(
    hash_tbl,
    n = dplyr::n_distinct(.data$hash_non_comp_tid),
    mt_id = unique(.data$mt_id)
  ) %>%
    dplyr::filter(.data$n > 1L)

  check <- nrow(n_tbl) == 0L

  if (check) {
    details <- NULL
    errors <- NULL
  } else {
    errors <- non_comptid_mismatch_errors(
      mt_ids = n_tbl$mt_id, hash_tbl, tbl,
      config_tasks, round_id
    )
    output_type_ids <- purrr::map(errors, ~ .x$output_type_ids) %>% # nolint: object_usage_linter
      unlist(use.names = FALSE)

    details <- cli::format_inline(
      "Sample{?s} {.val {output_type_ids}} d{?oes/o} not match most prevalent ",
      "non compound task ID combination for {?its/their} modeling task. ",
      "See {.var errors} attribute for details."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Task ID combinations of non compound task id values",
    msg_attribute = "across modeling task samples.",
    msg_verbs = c("consistent", "not consistent"),
    details = details,
    errors = errors,
    error = TRUE
  )
}

non_comptid_mismatch_errors <- function(mt_ids, hash_tbl, tbl,
                                        config_tasks, round_id) {
  tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]
  compound_taskids_l <- get_round_compound_task_ids(config_tasks, round_id)
  round_taskids <- hubUtils::get_round_task_id_names(
    config_tasks,
    round_id
  )

  purrr::map(
    mt_ids,
    function(.x, hash_tbl, tbl, compound_taskids_l) {
      mt_hashes <- hash_tbl$hash_non_comp_tid[hash_tbl$mt_id == .x] %>%
        table() %>%
        sort(decreasing = TRUE) %>%
        names()

      spl_id <- get_hash_out_type_ids(
        hash_tbl = hash_tbl,
        hash = utils::head(mt_hashes, 1L),
        n = 1L
      )
      mt_compound_taskids <- compound_taskids_l[[.x]]

      list(
        mt_id = .x,
        output_type_ids = get_hash_out_type_ids(hash_tbl, mt_hashes[-1L]),
        prevalent = tbl[
          tbl$output_type_id == spl_id,
          setdiff(round_taskids, mt_compound_taskids)
        ]
      )
    },
    hash_tbl = hash_tbl, tbl = tbl,
    compound_taskids_l = compound_taskids_l
  )
}
