#' Check that individual sample output_type_ids do not span multiple model tasks
#'
#' @param tbl a tibble/data.frame of the contents of the file being validated.
#' Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @inheritParams expand_model_out_grid
#' @param derived_task_ids Character vector of derived task ID names (task IDs whose
#' values depend on other task IDs) to ignore. Columns for such task ids will
#' contain `NA`s. Defaults to extracting derived task IDs from hub `task.json`. See
#' [get_hub_derived_task_ids()] for more details.
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
  tbl,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
) {
  config_tasks <- read_config(hub_path, "tasks")

  if (
    isFALSE(has_spls_tbl(tbl)) || isFALSE(hubUtils::is_v3_config(config_tasks))
  ) {
    return(skip_v3_spl_check(file_path))
  }

  out_tid <- hubUtils::std_colnames["output_type_id"]
  spl_tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]
  if (!is.null(derived_task_ids)) {
    spl_tbl[, derived_task_ids] <- NA_character_
  }

  mt_grids <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    all_character = TRUE,
    include_sample_ids = FALSE,
    bind_model_tasks = FALSE,
    output_types = "sample",
    derived_task_ids = derived_task_ids
  )

  # If fewer than 2 model tasks have samples, no overlap is possible
  n_spl_mts <- sum(purrr::map_int(mt_grids, nrow) > 0L)
  if (n_spl_mts < 2L) {
    check <- TRUE
    details <- NULL
    errors <- NULL
  } else {
    join_by <- setdiff(names(spl_tbl), out_tid)
    mt_otids <- mt_grids |>
      purrr::set_names(seq_along(mt_grids)) |>
      purrr::map(\(.x) {
        if (nrow(.x) == 0L) {
          return(NULL)
        }
        # semi_join returns rows from spl_tbl where a match exists in each
        # model task grid, without duplicating rows or returning model task
        # grid columns. More performant than inner_join as we only need
        # the output_type_ids.
        matched <- dplyr::semi_join(spl_tbl, .x, by = join_by)
        unique(matched[[out_tid]])
      })

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

      display_otids <- cli::cli_vec(dup_otids, style = list(vec_trunc = 10)) # nolint: object_usage_linter
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
