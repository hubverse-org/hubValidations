#' Check model output data tbl sample compound task id sets for each modeling task
#' match or are coarser than the expected set defined in the config.
#'
#' This check detects the compound task ID sets of samples, implied by the `output_type_id`
#' and task ID values, and checks them for compliance with
#' the `compound_taskid_set` defined for each round modeling task in the `tasks.json` config.
#' Samples in a modeling task may have different compound task ID sets, as long
#' as each matches or is coarser than the configured set. See the Compound
#' modeling tasks section.
#' @inheritParams check_tbl_spl_mt_unique
#' @inheritParams check_tbl_values
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @details If the check fails, the output of the check includes an `errors` element,
#' a list of items, one for each modeling task failing validation.
#' The structure depends on the reason the check failed.
#'
#' If the check failed because task IDs the hub does not accept as compound task IDs
#' were identified as such (i.e. samples describe "finer" compound modeling tasks)
#' for a given model task, the `errors` object will be a list with one element
#' for each finer compound task ID set detected, with the following structure:
#' - `config_comp_tids`: the `compound_taskid_set` the modeling task config expects.
#' - `invalid_tbl_comp_tids`: the names of invalid compound task IDs.
#' - `tbl_comp_tids`: the finer compound task ID set detected in the tbl.
#' - `output_type_ids`: The output type IDs of the samples with that compound
#' task ID set.
#'
#' The name of each element is the index identifying the config modeling task the sample is associated with `mt_id`.
#' See [hubverse documentation on samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @section Compound modeling tasks:
#' Samples are validated against the configured `compound_taskid_set` only.
#' Each combination of configured compound task ID values is one compound
#' modeling task, identified in check output by its `compound_idx`. A sample
#' that matches the configured set covers one compound modeling task. A
#' coarser sample covers several. The sample checks split a coarser sample
#' into one part per compound modeling task, and validate and count each part
#' as a sample of that compound modeling task. A finer sample covers only part
#' of a compound modeling task, so it fails.
#'
#' For example, take a configured `compound_taskid_set` of `reference_date`
#' and `location`. Each compound modeling task is then one location for one
#' reference date, and a sample that matches the configured set is a
#' trajectory across horizons for one location.
#' - A sample with a compound task ID set of `reference_date` only is coarser.
#'   It is joint across locations as well as horizons. If it covers locations
#'   `A1` and `A2`, it is validated as one sample for `A1` and one for `A2`.
#' - A sample with a compound task ID set of `reference_date`, `location` and
#'   `horizon` is finer. It covers one horizon of a trajectory, and fails.
#'
#' The other sample checks refer to this example.
#' @export
check_tbl_spl_compound_taskid_set <- function(
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

  compound_taskid_set <- get_tbl_compound_taskid_set(
    tbl_chr,
    config_tasks,
    round_id,
    compact = FALSE,
    error = FALSE,
    derived_task_ids = derived_task_ids
  )

  check <- purrr::map_lgl(
    compound_taskid_set,
    \(.x) is.null(attr(.x, "errors"))
  ) |>
    all()

  coarser_info <- list()
  if (check) {
    config_comp_tids <- get_round_compound_task_ids(config_tasks, round_id)
    coarser_info <- detect_coarser_compound_taskid_set(
      compound_taskid_set,
      config_comp_tids
    )
  }
  any_coarser <- length(coarser_info) > 0L

  msg_attribute <- if (!check || any_coarser) {
    paste(
      "to compound task ID sets that match or are coarser than the",
      "configured {.var compound_taskid_set}."
    )
  } else {
    "to the configured {.var compound_taskid_set}."
  }
  details <- if (any_coarser) {
    compile_coarser_details(coarser_info)
  } else {
    compile_msg(compound_taskid_set)
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "All samples in a model task",
    msg_attribute = msg_attribute,
    msg_verbs = c("conform", "do not conform"),
    details = details,
    errors = compile_errors(compound_taskid_set),
    error = TRUE,
    warnings = coarser_compound_taskid_set_warnings(coarser_info),
    compound_taskid_set = if (check) {
      compound_taskid_set
    } else {
      NA
    }
  )
}

compile_errors <- function(x) {
  out <- purrr::map(x, \(.x) attr(.x, "errors")) |>
    purrr::compact()
  if (length(out) == 0L) {
    return(NULL)
  }
  out
}

compile_msg <- function(x) {
  purrr::map(x, \(.x) attr(.x, "msg")) |>
    purrr::compact() |>
    purrr::imap_chr(\(.x, .y) paste0("mt ", .y, ": ", .x)) |>
    paste(collapse = ". ")
}
