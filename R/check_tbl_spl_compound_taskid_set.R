#' Check model output data tbl sample compound task id sets for each modeling task
#' match or are coarser than the expected set defined in the config.
#'
#' This check detects the compound task ID sets of samples, implied by the `output_type_id`
#' and task ID values, and checks them for internal consistency and compliacance with
#' the `compound_taskid_set` defined for each round modeling task in the `tasks.json` config.
#' @param tbl a tibble/data.frame of the contents of the file being validated.
#' Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @param derived_task_ids Character vector of derived task ID names (task IDs whose
#' values depend on other task IDs) to ignore. Columns for such task ids will
#' contain `NA`s. Defaults to extracting derived task IDs from hub `task.json`. See
#' [get_derived_task_ids()] for more details.
#' @inheritParams expand_model_out_grid
#' @details If the check fails, the output of the check includes an `errors` element,
#' a list of items, one for each modeling task failing validation.
#' The structure depends on the reason the check failed.
#'
#' If the check failed because more that a single unique `compound_taskid_set` was found
#' for a given model task, the `errors` object will be a list with one element for each
#' `compound_taskid_set` detected and will have the following structure:
#' - `tbl_comp_tids`: a compound task id set detected in the the tbl.
#' - `output_type_ids`: The output type ID of the sample that does not contain a
#' single, unique value for each compound task ID.
#'
#' If the check failed because task IDs which is not allowed in the config, were identified
#' as compound task ID (i.e. samples describe "finer" compound modeling tasks)
#' for a given model task, the `errors` object will be a list with the structure
#' described above as well as the additional following elements:
#' - `config_comp_tids`: the allowed `compound_taskid_set` defined in the modeling
#' task config.
#' - `invalid_tbl_comp_tids`: the names of invalid compound task IDs.
#'
#' The name of each element is the index identifying the config modeling task the sample is associated with `mt_id`.
#' See [hubverse documentation on samples](https://hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @export
check_tbl_spl_compound_taskid_set <- function(
    tbl, round_id, file_path, hub_path,
    derived_task_ids = get_derived_task_ids(hub_path)) {
  config_tasks <- read_config(hub_path, "tasks")

  if (isFALSE(has_spls_tbl(tbl)) || isFALSE(hubUtils::is_v3_config(config_tasks))) {
    return(skip_v3_spl_check(file_path))
  }

  compound_taskid_set <- get_tbl_compound_taskid_set(
    tbl, config_tasks, round_id,
    compact = FALSE, error = FALSE,
    derived_task_ids = derived_task_ids
  )

  check <- purrr::map_lgl(
    compound_taskid_set,
    ~ is.null(attr(.x, "errors"))
  ) |> all()

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "All samples in a model task",
    msg_attribute = "to single, unique compound task ID set that matches or is
    coarser than the configured {.var compound_taksid_set}.",
    msg_verbs = c("conform", "do not conform"),
    details = compile_msg(compound_taskid_set),
    errors = compile_errors(compound_taskid_set),
    error = TRUE,
    compound_taskid_set = if (check) {
      compound_taskid_set
    } else {
      NA
    }
  )
}

compile_errors <- function(x) {
  out <- purrr::map(x, ~ attr(.x, "errors")) |>
    purrr::compact()
  if (length(out) == 0L) {
    return(NULL)
  }
  out
}

compile_msg <- function(x) {
  purrr::map(x, ~ attr(.x, "msg")) |>
    purrr::compact() |>
    purrr::imap_chr(~ paste0("mt ", .y, ": ", .x)) |>
    paste(collapse = ". ")
}
