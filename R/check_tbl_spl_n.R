#' Check model output data tbl samples contain the appropriate number of samples
#' for a given compound idx.
#' @param tbl a tibble/data.frame of the contents of the file being validated. Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @export
check_tbl_spl_n <- function(tbl, round_id, file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  if (isFALSE(has_spls_tbl(tbl)) || isFALSE(hubUtils::is_v3_config(config_tasks))) {
    return(skip_v3_spl_check(file_path))
  }

  hash_tbl <- spl_hash_tbl(tbl, round_id, config_tasks)
  n_ranges <- get_round_spl_n_ranges(config_tasks, round_id)

  n_tbl <- dplyr::group_by(hash_tbl, .data$compound_idx) %>%
    dplyr::summarise(
      n = dplyr::n_distinct(.data$output_type_id),
      mt_id = unique(.data$mt_id)
    ) %>%
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
  cat_msg <- function(compound_idx, n, n_min, n_max, less, more) {
    type <- c("less", "more")[c(less, more)]
    switch(type,
      less = paste0(
        "File contains less ({.val ", n,
        "}) than the minimum required number of samples per task ",
        "({.val ", n_min, "})  for compound idx {.val ", compound_idx, "}"
      ),
      more = paste0(
        "File contains more ({.val ", n,
        "}) than the maximum allowed number of samples per task ",
        "({.val ", n_max, "})  for compound idx {.val ", compound_idx, "}"
      )
    ) %>% cli::format_inline()
  }

  n_tbl %>%
    dplyr::select(-dplyr::all_of(c("mt_id", "out_range"))) %>%
    purrr::pmap_chr(cat_msg) %>%
    c("See {.var errors} attribute for details.") %>%
    paste(collapse = ". ")
}
