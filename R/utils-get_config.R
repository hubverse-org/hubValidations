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
  derived_tasks_ids_round <- config_tasks[["rounds"]][[round_idx]]$derived_task_ids
  if (!is.null(derived_tasks_ids_round)) {
    return(derived_tasks_ids_round)
  }
  derived_task_ids_hub
}
