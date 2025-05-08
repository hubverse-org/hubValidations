#' Get Unique Target Task ID
#'
#' Retrieves the unique target task ID by extracting all target metadata
#' and extracting the names of their `target_keys`. For valid config files
#' these should be the same across all rounds and model tasks.
#'
#' @param config_tasks a list representation of the `tasks.json` config file.
#'
#' @return A character vector of unique target task ID names. Post v5.0.0
#' this should be a single task ID name.
#' @export
get_target_task_id <- function(config_tasks) {
  safe_names <- function(x) names(x) %||% ""
  out <- get_target_metadata(config_tasks) |>
    purrr::map_chr(\(.x) safe_names(.x[["target_keys"]])) |>
    unique()
  if (identical(out, "")) NULL else out
}

#' Get Target Metadata for all rounds
#'
#' Iterates over rounds in a configuration object and retrieves target
#' metadata by calling `get_round_target_metadata()`.
#' Flattens the output by default.
#'
#' @param config_tasks a list representation of the `tasks.json` config file.
#' @param flatten Logical; if `TRUE`, combines all rounds' metadata into
#'   a single list. If `FALSE`, returns a list nested by round.
#'
#' @return A list of target metadata. The structure is flat if
#'   `flatten = TRUE`, or nested by round if `flatten = FALSE`.
#' @noRd
get_target_metadata <- function(config_tasks, flatten = TRUE) {
  out <- config_tasks[["rounds"]] |>
    purrr::map(
      ~ get_round_target_metadata(.x[["model_tasks"]], flatten = flatten)
    )

  if (flatten) {
    purrr::list_flatten(out)
  }
}

#' Get Target Metadata for a Single Round
#'
#' Extracts the `target_metadata` element from each model task in the provided
#' group. Flattens the list of metadata entries by default.
#'
#' @param model_task_grp A list of model task definitions, each containing
#'   a `target_metadata` component.
#' @param flatten Logical; if `TRUE`, combines all entries into
#'   a single list. If `FALSE`, returns the list grouped by task.
#'
#' @return A list of target metadata entries, flat or nested by model task.
#' @noRd
get_round_target_metadata <- function(model_task_grp, flatten = TRUE) {
  out <- purrr::map(
    model_task_grp,
    ~ .x[["target_metadata"]]
  )

  if (flatten) {
    purrr::list_flatten(out)
  } else {
    out
  }
}
