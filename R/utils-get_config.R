#' Get hub configuration fields from a `<config>` class object
#'
#' @inheritParams expand_model_out_grid
#'
#' @return * `get_config_derived_task_ids`: character vector of hub or round level derived
#' task ID names. If `round_id` is `NULL` or the round does not have a round level
#' `derived_tasks_ids` setting, returns the hub level `derived_tasks_ids` setting.
#' @export
#' @describeIn get_config_derived_task_ids Get the hub or round level `derived_tasks_ids`
#' @examples
#' hub_path <- system.file("testhubs/v4/flusight", package = "hubUtils")
#' config_tasks <- read_config(hub_path)
#' get_config_derived_task_ids(config_tasks)
#' get_config_derived_task_ids(config_tasks, round_id = "2023-05-08")
get_config_derived_task_ids <- function(config_tasks, round_id = NULL) {
  derived_task_ids_hub <- config_tasks$derived_task_ids
  if (is.null(round_id)) {
    return(derived_task_ids_hub)
  }
  round_idx <- hubUtils::get_round_idx(config_tasks, round_id)
  derived_tasks_ids_round <- config_tasks[["rounds"]][[
    round_idx
  ]]$derived_task_ids
  if (!is.null(derived_tasks_ids_round)) {
    return(derived_tasks_ids_round)
  }
  derived_task_ids_hub
}

#' Read the values each modeling task allows in each column
#'
#' Reads a round's config into one list per modeling task, each holding the
#' values that modeling task allows in each of its columns:
#'
#' ```
#' [[1]]
#'   $task_ids
#'     $target   "wk flu hosp rate category"
#'     $horizon  0 1 2 3
#'     $location "US" "01" "02" ...
#'   $output_type_ids
#'     $pmf      "low" "moderate" "high" ...
#' ```
#'
#' So a row belongs to that modeling task when its `target` is that one string,
#' its `horizon` is one of those four numbers, and so on. That is what matching
#' needs: within a modeling task the valid combinations are the Cartesian
#' product of these lists, so testing a row against them answers the same
#' question as matching it against the expanded product, without building the
#' product.
#'
#' Three things about configs make this more than a lookup. A task ID a modeling
#' task does not use is listed as `null`, or left out; which `output_type_id`
#' values are valid depends on the output type, so they are keyed by it rather
#' than pooled; and `round_id` has to be pinned to the round being read when it
#' comes from a variable. `extract_round_property_values()` handles those,
#' shared with [expand_model_out_grid()] so the two cannot drift apart.
#'
#' @inheritParams expand_model_out_grid
#'
#' @returns A list with one element per modeling task in the round, each a list
#' of `task_ids` and `output_type_ids` as above. Values come back as the config
#' holds them, numbers as numbers. Nothing needs coercing here because they are
#' only ever compared against a column of submitted data with `%in%`, which
#' converts the config side to match the data, never the other way round.
#' @noRd
get_config_mt_value_sets <- function(
  config_tasks,
  round_id,
  output_types = NULL,
  derived_task_ids = get_config_derived_task_ids(
    config_tasks,
    round_id
  ),
  call = rlang::caller_env()
) {
  output_types <- validate_output_types(
    output_types,
    config_tasks,
    round_id,
    call = call
  )
  derived_task_ids <- validate_derived_task_ids(
    derived_task_ids,
    config_tasks,
    round_id,
    call = call
  )
  property_values <- extract_round_property_values(
    config_tasks,
    round_id = round_id,
    output_types = output_types,
    derived_task_ids = derived_task_ids
  )

  round_task_ids <- hubUtils::get_round_task_id_names(config_tasks, round_id)

  purrr::map2(
    purrr::map(property_values[["task_ids"]], purrr::compact),
    property_values[["output_type"]],
    \(task_ids, output_type) {
      # A modeling task that does not use a task ID lists it as null, or
      # leaves it out altogether. A peak target has no `horizon`, for
      # instance, and its rows carry `NA` in that column, so `NA` is the only
      # value the modeling task accepts there. `null_taskids_to_na()` has
      # already handled the ones listed as null; this handles the ones left
      # out, which would otherwise go untested and let the modeling task
      # accept any value at all.
      omitted <- setdiff(round_task_ids, names(task_ids))
      task_ids[omitted] <- list(NA)

      list(task_ids = task_ids, output_type_ids = output_type)
    }
  )
}
