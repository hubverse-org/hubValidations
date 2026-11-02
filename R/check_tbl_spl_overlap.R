#' Check model output data tbl samples that share a compound modeling task
#' cover the same compound modeling tasks
#'
#' A sample coarser than the configured `compound_taskid_set` covers several
#' compound modeling tasks. This check fails samples that partly overlap, that
#' is, share some compound modeling tasks but not all. The terms are explained
#' in the Compound modeling tasks section of
#' [check_tbl_spl_compound_taskid_set()].
#'
#' In the example there, with a configured `compound_taskid_set` of
#' `reference_date` and `location`, samples joint across locations `A1` and
#' `A2` can sit alongside samples for location `B` alone. A sample joint across
#' `A1` and `A2` alongside a sample joint across `A2` and `B` partly overlaps,
#' and fails.
#'
#' `validate_model_data()` skips this check when `allow_overlapping_samples`
#' is `TRUE`. The other sample checks then split each sample by location as
#' usual. In the example, the `A2` rows of the two samples count as two
#' samples for `A2`, while `A1` and `B` have one each. `min_samples_per_task`
#' and `max_samples_per_task` apply to these counts, and [check_tbl_spl_n()]
#' fails a file in which locations have different numbers of samples.
#' @inheritParams check_tbl_spl_mt_unique
#' @inheritParams check_tbl_values
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @details If the check fails, the output of the check includes an `errors`
#' element, a list with one element for each modeling task failing validation,
#' named by the index of the modeling task in the config. Each element has the
#' following structure:
#' - `output_type_ids`: The output type IDs of the samples involved.
#' - `slices`: a tibble with one row for each sample and compound modeling task
#' it covers, giving the sample's `output_type_id`, the `compound_idx` and the
#' compound task ID values of the compound modeling task.
#'
#' See [hubverse documentation on samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @export
check_tbl_spl_overlap <- function(
  tbl_chr,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
) {
  assert_tbl_chr(tbl_chr)
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
    derived_task_ids = derived_task_ids
  )
  errors <- overlapping_spl_errors(
    overlapping_spl_slices(spl_slice_tbl(spl_idx$rows)),
    spl_idx$comp_tids,
    tbl_chr
  )
  check <- is.null(errors)

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Samples that share a combination of compound task ID values",
    msg_attribute = "the same combinations.",
    msg_verbs = c("all cover", "do not all cover"),
    details = if (!check) compile_overlap_details(errors),
    errors = errors,
    error = TRUE
  )
}

# One element per modeling task with overlapping samples, named by its index.
# Not every overlapping sample is reported. In the example of `spl_idx_tbl()`,
# one row of a sample given the wrong location makes that sample cover two
# locations. It then overlaps every sample at both locations. So at each
# compound idx, only samples whose compound idxs differ from those most
# samples there cover are reported, which names the one faulty sample. Where
# no set of compound idxs is the most common, all of them are reported.
overlapping_spl_errors <- function(overlap_slices, mt_comp_tids, tbl_chr) {
  if (nrow(overlap_slices) == 0L) {
    return(NULL)
  }
  coverage <- dplyr::summarise(
    overlap_slices,
    coverage = paste(sort(.data$compound_idx), collapse = ","),
    .by = c("mt_id", "output_type_id")
  )
  outliers <- dplyr::left_join(
    overlap_slices,
    coverage,
    by = c("mt_id", "output_type_id")
  ) |>
    dplyr::add_count(.data$mt_id, .data$compound_idx, .data$coverage) |>
    dplyr::mutate(
      common = .data$n == max(.data$n) &
        dplyr::n_distinct(.data$coverage[.data$n == max(.data$n)]) == 1L,
      .by = c("mt_id", "compound_idx")
    ) |>
    dplyr::filter(!.data$common) |>
    dplyr::distinct(.data$mt_id, .data$output_type_id)

  overlap_slices <- dplyr::semi_join(
    overlap_slices,
    outliers,
    by = c("mt_id", "output_type_id")
  )
  split(overlap_slices, overlap_slices$mt_id) |>
    purrr::map(function(.x) {
      list(
        output_type_ids = unique(.x$output_type_id),
        slices = spl_slice_values(.x, mt_comp_tids[[.x$mt_id[1L]]], tbl_chr)
      )
    })
}

compile_overlap_details <- function(overlap_errors) {
  purrr::imap_chr(overlap_errors, function(.x, .y) {
    mt_id <- .y # nolint: object_usage_linter
    spl_ids <- .x$output_type_ids # nolint: object_usage_linter
    cli::format_inline(
      "mt {mt_id}: {cli::qty(spl_ids)}sample{?s} {.val {spl_ids}} ",
      "share{?s/} compound task ID values with samples that cover different ",
      "ones."
    )
  }) |>
    paste(collapse = " ") |>
    paste("See `errors` attribute for details.")
}
