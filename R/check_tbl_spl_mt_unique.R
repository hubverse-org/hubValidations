#' Check that individual sample output_type_ids do not span multiple model tasks
#'
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @inheritParams check_tbl_values
#' @param derived_task_ids Character vector of derived task ID names (task IDs whose
#' values depend on other task IDs) to ignore during validation. Defaults to
#' extracting derived task IDs from hub `task.json`. See
#' [get_hub_derived_task_ids()] for more details.
#' @param spl_idx for internal use. `validate_model_data()` indexes the sample
#' rows of `tbl_chr` once and passes the index to each sample check. `NULL`,
#' the default, builds the index from `tbl_chr`.
#' @details
#' Different model tasks can have different sample configurations
#' (`compound_taskid_set`, `min/max_samples_per_task`, etc.), so samples should
#' be entirely independent across model tasks. This check verifies that no
#' sample `output_type_id` appears in more than one model task.
#'
#' Output of the check includes an `errors` element, a list with the following
#' structure:
#' - `mt_ids`: Integer vector of model task indices the overlapping samples span.
#' - `output_type_ids`: Character vector of sample `output_type_id`s that appear
#'   in multiple model tasks.
#' @export
check_tbl_spl_mt_unique <- function(
  tbl_chr,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id),
  spl_idx = NULL
) {
  assert_tbl_chr(tbl_chr)
  config_tasks <- read_config(hub_path, "tasks")

  if (
    isFALSE(has_spls_tbl(tbl_chr)) ||
      isFALSE(hubUtils::is_v3_config(config_tasks))
  ) {
    return(skip_v3_spl_check(file_path))
  }

  spl_idx <- spl_idx %||%
    spl_idx_tbl(
      tbl_chr,
      round_id,
      config_tasks,
      derived_task_ids = derived_task_ids
    )

  # If fewer than 2 model tasks have samples, no overlap is possible
  n_mt <- length(spl_idx$comp_tids)
  if (sum(tabulate(spl_idx$rows$mt_id, nbins = n_mt) > 0L) < 2L) {
    check <- TRUE
    details <- NULL
    errors <- NULL
  } else {
    mt_otids <- split_by_mt(spl_idx$rows$output_type_id, spl_idx) |>
      purrr::map(unique)

    otid_counts <- table(unlist(mt_otids, use.names = FALSE))
    dup_otids <- names(otid_counts[otid_counts > 1L])

    check <- length(dup_otids) == 0L

    if (check) {
      details <- NULL
      errors <- NULL
    } else {
      affected_mts <- sort(as.integer(names(mt_otids)[
        purrr::map_lgl(mt_otids, ~ any(.x %in% dup_otids))
      ]))
      errors <- list(
        mt_ids = affected_mts,
        output_type_ids = dup_otids
      )

      display_otids <- escape_braces(dup_otids) |> # nolint: object_usage_linter
        cli::cli_vec(style = list(vec_trunc = 10))
      details <- cli::format_inline(
        "{.val {length(dup_otids)}} sample {.var output_type_id}{?s} ",
        "{?is/are} associated with multiple modeling tasks: ",
        "{.val {display_otids}}. ",
        "Different model tasks can have different sample configurations so ",
        "sample IDs must be unique to a single model task. ",
        "Use {.fn submission_tmpl} to generate a template with correct sample ",
        "ID structure. ",
        "See {.var errors} attribute for details."
      )
    }
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Sample `output_type_id`s",
    msg_attribute = "a single, unique modeling task.",
    msg_verbs = c(
      "are each associated with",
      "span multiple modeling tasks, not"
    ),
    details = details,
    errors = errors,
    error = TRUE
  )
}
