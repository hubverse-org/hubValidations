#' Check model output data tbl samples contain the appropriate number of samples
#' for a given compound idx.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @inheritParams check_tbl_spl_compound_tid
#' @details A sample coarser than the configured `compound_taskid_set` covers
#' several compound modeling tasks, and counts as one sample for each. See the
#' Compound modeling tasks section of [check_tbl_spl_compound_taskid_set()].
#'
#' Output of the check includes an `errors` element, a list of items,
#' one for each compound_idx failing validation, with the following structure:
#' - `compound_idx`: the compound idx that failed validation of number of samples.
#' - `n`: the number of samples counted for the compound idx.
#' - `min_samples_per_task`: the minimum number of samples required for the compound idx.
#' - `max_samples_per_task`: the maximum number of samples required for the compound idx.
#' - `compound_idx_tbl`: a tibble of the rows one sample holds within the
#' compound idx.
#' See [hubverse documentation on samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @export
check_tbl_spl_n <- function(
  tbl_chr,
  round_id,
  file_path,
  hub_path,
  compound_taskid_set = NULL,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
) {
  assert_tbl_chr(tbl_chr)
  if (!is.null(compound_taskid_set) && isTRUE(is.na(compound_taskid_set))) {
    cli::cli_abort("Valid {.var compound_taskid_set} must be provided.")
  }
  config_tasks <- read_config(hub_path, "tasks")

  if (
    isFALSE(has_spls_tbl(tbl_chr)) ||
      isFALSE(hubUtils::is_v3_config(config_tasks))
  ) {
    return(skip_v3_spl_check(file_path))
  }

  spl_idx <- spl_idx_tbl(
    tbl_chr,
    round_id,
    config_tasks,
    compound_taskid_set,
    derived_task_ids = derived_task_ids
  )
  n_ranges <- get_round_spl_n_ranges(config_tasks, round_id)

  # A coarser sample covers several compound idxs and counts towards each.
  # Slices are distinct, so counting a compound idx's slices counts its samples.
  n_tbl <- spl_slice_tbl(spl_idx$rows) |>
    dplyr::count(.data$mt_id, .data$compound_idx) |>
    dplyr::select("compound_idx", "n", "mt_id")

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
  n_tbl <- n_tbl |>
    dplyr::left_join(n_ranges, by = "mt_id") |>
    dplyr::mutate(
      less = .data$n < .data$n_min,
      more = .data$n > .data$n_max,
      out_range = .data$less | .data$more
    ) |>
    dplyr::filter(.data$out_range)

  check <- nrow(n_tbl) == 0L

  if (check) {
    details <- NULL
    errors <- NULL
  } else {
    errors <- n_mismatch_errors(n_tbl, spl_idx$rows, tbl_chr)
    details <- n_mismatch_details(n_tbl, spl_idx, tbl_chr)
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
      output_type_id_params <- get_mt_sample_params(.x)

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
  ) |>
    purrr::list_rbind()
}

n_mismatch_errors <- function(n_tbl, idx_rows, tbl_chr) {
  rows_by_idx <- split(seq_len(nrow(idx_rows)), idx_rows$compound_idx)
  purrr::map(
    purrr::set_names(n_tbl$compound_idx),
    function(idx) {
      # The rows one sample holds within this compound idx. A coarser sample
      # holds rows in other compound idxs too, which are left out.
      rows <- rows_by_idx[[idx]]
      spl_d <- idx_rows$output_type_id[rows[1L]]
      rows <- rows[idx_rows$output_type_id[rows] == spl_d]
      compound_idx_tbl <- tbl_chr[
        idx_rows$row_idx[rows],
        setdiff(names(tbl_chr), c("output_type_id", "value", "output_type"))
      ]
      row <- n_tbl[n_tbl$compound_idx == idx, ] |> as.vector()
      list(
        compound_idx = idx,
        n = row$n,
        min_samples_per_task = row$n_min,
        max_samples_per_task = row$n_max,
        compound_idx_tbl = compound_idx_tbl
      )
    }
  )
}


n_mismatch_details <- function(n_tbl, spl_idx, tbl_chr) {
  # nolint start: object_usage_linter
  cat_msg <- function(units, type) {
    switch(
      type,
      less = paste0(
        "File contains less than the minimum required number of samples per task ",
        "for compound task ID values {units}"
      ),
      more = paste0(
        "File contains more than the maximum required number of samples per task ",
        "for compound task ID values {units}"
      )
    ) |>
      cli::format_inline()
  }
  # nolint end

  purrr::map(
    c("less", "more"),
    ~ {
      compound_idx <- n_tbl[n_tbl[[.x]], "compound_idx", drop = TRUE]
      if (length(compound_idx) == 0L) {
        return(NULL)
      } else {
        cat_msg(compound_idx_labels(compound_idx, spl_idx, tbl_chr), .x)
      }
    }
  ) |>
    purrr::compact() |>
    c("See {.var errors} attribute for details.") |>
    paste(collapse = ". ")
}
