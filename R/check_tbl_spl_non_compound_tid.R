#' Check model output data tbl samples contain single unique combination of
#' non-compound task ID values across all samples
#' @inherit check_tbl_colnames params
#' @inheritParams check_tbl_spl_compound_tid
#' @inherit check_tbl_colnames return
#' @details A sample coarser than the configured `compound_taskid_set` covers
#' several compound modeling tasks. Its rows in each one are compared
#' separately. See the Compound modeling tasks section of
#' [check_tbl_spl_compound_taskid_set()].
#'
#' Output of the check includes an `errors` element, a list of items,
#' one for each modeling task containing samples failing validation,
#' with the following structure:
#' - `mt_id`: Index identifying the config modeling task the samples are associated with.
#' - `output_type_ids`: The output type IDs of samples that do not match the most frequent
#' non-compound task ID value combination across all
#' samples in the modeling task.
#' - `slices`: a tibble with one row for each sample and compound modeling task
#' in which the sample does not match, giving the sample's `output_type_id`,
#' the `compound_idx` and the compound task ID values of the compound modeling
#' task.
#' - `frequent`: The most frequent non-compound task ID value combination
#' across all samples in the modeling task to which all samples were compared.
#' See [hubverse documentation on samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @export
check_tbl_spl_non_compound_tid <- function(
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
    derived_task_ids = derived_task_ids,
    non_comp_key = TRUE
  )

  # Check that no output_type_id spans multiple model tasks. This should be
  # caught upstream by check_tbl_spl_mt_unique, but we handle it defensively
  # here to produce an informative error instead of a cryptic dplyr crash.
  otid_mt <- dplyr::distinct(spl_idx$rows, .data$output_type_id, .data$mt_id)
  dup_otids <- otid_mt$output_type_id[duplicated(otid_mt$output_type_id)]
  if (length(dup_otids) > 0L) {
    cli::cli_abort(
      c(
        "x" = "Sample {.var output_type_id}s span multiple modeling tasks.",
        "i" = "Use {.fn submission_tmpl} to generate a template with
        correct sample ID structure."
      )
    )
  }

  mismatched <- mismatched_non_comp_slices(spl_idx$rows)

  check <- nrow(mismatched$slices) == 0L

  if (check) {
    details <- NULL
    errors <- NULL
  } else {
    errors <- non_comptid_mismatch_errors(mismatched, spl_idx, tbl_chr)
    output_type_ids <- purrr::map(errors, ~ .x$output_type_ids) |> # nolint: object_usage_linter
      unlist(use.names = FALSE)
    mismatched_idx <- unique(mismatched$slices$compound_idx)
    units <- compound_idx_labels(mismatched_idx, spl_idx, tbl_chr) # nolint: object_usage_linter

    details <- paste(
      cli::format_inline(
        "Sample{?s} {.val {output_type_ids}} d{?oes/o} not match the most ",
        "frequent non compound task ID combination for {?its/their} modeling ",
        "task"
      ),
      cli::format_inline(
        "for compound task ID values {units}. ",
        "See {.var errors} attribute for details."
      )
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

non_comptid_mismatch_errors <- function(mismatched, spl_idx, tbl_chr) {
  purrr::map(
    unique(mismatched$slices$mt_id),
    function(mt_id) {
      slices <- mismatched$slices[mismatched$slices$mt_id == mt_id, ]
      ref_rows <- mismatched$reference$row_idx[
        mismatched$reference$mt_id == mt_id
      ]

      list(
        mt_id = mt_id,
        output_type_ids = unique(slices$output_type_id),
        slices = spl_slice_values(slices, spl_idx$comp_tids[[mt_id]], tbl_chr),
        frequent = tbl_chr[ref_rows, spl_idx$non_comp_tids[[mt_id]]]
      )
    }
  )
}
