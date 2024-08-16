#' Check model output data tbl samples contain the appropriate number of samples
#' for a given compound idx.
#' @param tbl a tibble/data.frame of the contents of the file being validated. Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @inheritParams check_tbl_spl_compound_tid
#' @details Output of the check includes an `errors` element, a list of items,
#' one for each compound_idx failing validation, with the following structure:
#' - `compound_idx`: the compound idx that failed validation of number of samples.
#' - `n`: the number of samples counted for the compound idx.
#' - `min_samples_per_task`: the minimum number of samples required for the compound idx.
#' - `max_samples_per_task`: the maximum number of samples required for the compound idx.
#' - `compound_idx_tbl`: a tibble of the expected structure for samples belonging to
#' the compound idx.
#' See [hubverse documentation on samples](https://hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @export
check_tbl_spl_n <- function(tbl, round_id, file_path, hub_path,
                            compound_taskid_set = NULL,
                            derived_task_ids = NULL) {
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

  hash_tbl <- spl_hash_tbl(tbl, round_id, config_tasks, compound_taskid_set,
    derived_task_ids = derived_task_ids
  )
  n_ranges <- get_round_spl_n_ranges(config_tasks, round_id)

  n_tbl <- dplyr::group_by(hash_tbl, .data$compound_idx) %>%
    dplyr::summarise(
      n = dplyr::n_distinct(.data$output_type_id),
      mt_id = unique(.data$mt_id)
    )

  # First check that all compound_idx have the same number of samples
  # If not, return check failure.
  check <- dplyr::n_distinct(n_tbl$n) == 1L
  if (isFALSE(check)) {
    return(
      capture_check_cnd(
        check = check,
        file_path = file_path,
        msg_subject = "Number of samples per compound idx ",
        msg_attribute = NULL,
        msg_verbs = c("consistent.", "not consistent."),
        details = cli::format_inline(
          "Sample numbers supplied per compound idx vary between
          {.val {unique(n_tbl$n)}}.
          See {.var errors} attribute for details."
        ),
        errors = n_tbl
      )
    )
  }

  # Next check that all compound_idx have a number of samples within the
  # range required by the sample config.
  n_tbl <- n_tbl %>%
    dplyr::left_join(n_ranges, by = "mt_id") %>%
    dplyr::mutate(
      less = .data$n < .data$n_min,
      more = .data$n > .data$n_max,
      out_range = .data$less | .data$more
    ) %>%
    dplyr::filter(.data$out_range)

  check <- nrow(n_tbl) == 0L

  if (check) {
    details <- NULL
    errors <- NULL
  } else {
    errors <- n_mismatch_errors(
      n_tbl, hash_tbl, tbl
    )
    details <- n_mismatch_details(n_tbl)
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Required samples per compound idx task",
    msg_attribute = NULL,
    msg_verbs = c("present.", "not present."),
    details = details,
    errors = errors
  )
}

get_round_spl_n_ranges <- function(config_tasks, round_id) {
  round_mt <- hubUtils::get_round_model_tasks(config_tasks, round_id)
  purrr::imap(
    round_mt,
    ~ {
      output_type_id_params <- purrr::pluck(
        .x,
        "output_type",
        "sample",
        "output_type_id_params"
      )

      if (is.null(output_type_id_params)) {
        return(NULL)
      } else {
        tibble::tibble(
          mt_id = .y,
          n_min = output_type_id_params$min_samples_per_task,
          n_max = output_type_id_params$max_samples_per_task
        )
      }
    }
  ) %>%
    purrr::list_rbind()
}

n_mismatch_errors <- function(n_tbl, hash_tbl, tbl) {
  tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]
  purrr::map(
    purrr::set_names(n_tbl$compound_idx),
    ~ {
      spl_d <- hash_tbl$output_type_id[hash_tbl$compound_idx == .x][1L]
      compound_idx_tbl <- tbl[
        tbl$output_type_id == spl_d,
        setdiff(names(tbl), c("output_type_id", "value", "output_type"))
      ]
      row <- n_tbl[n_tbl$compound_idx == .x, ] %>% as.vector()
      list(
        compound_idx = .x,
        n = row$n,
        min_samples_per_task = row$n_min,
        max_samples_per_task = row$n_max,
        compound_idx_tbl = compound_idx_tbl
      )
    }
  )
}


n_mismatch_details <- function(n_tbl) {
  cat_msg <- function(compound_idx, type) { # nolint: object_usage_linter
    switch(type,
      less = paste0(
        "File contains less than the minimum required number of samples per task ",
        "for compound idx{?s} {.val {compound_idx}}"
      ),
      more = paste0(
        "File contains more than the maximum required number of samples per task ",
        "for compound idx{?s} {.val {compound_idx}}"
      )
    ) %>% cli::format_inline()
  }

  purrr::map(
    c("less", "more"),
    ~ {
      compound_idx <- n_tbl[n_tbl[[.x]], "compound_idx", drop = TRUE]
      if (length(compound_idx) == 0L) {
        return(NULL)
      } else {
        cat_msg(compound_idx, .x)
      }
    }
  ) %>%
    purrr::compact() %>%
    c("See {.var errors} attribute for details.") %>%
    paste(collapse = ". ")
}
