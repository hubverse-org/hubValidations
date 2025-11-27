#' Identify task identifier columns present in a data table.
#'
#' Extracts the set of task identifier columns (e.g., location, horizon) defined
#' in the hub's task configuration that are also present in the provided table.
#' This supports flexible validation across both oracle output target data
#' and model output tables.
#'
#' @param tbl A data frame (e.g., oracle target data or model output).
#' @param config_tasks A list of task configurations from the hub config.
#' @return A character vector of column names used to identify tasks.
#' @noRd
task_id_cols_to_validate <- function(tbl, config_tasks) {
  intersect(
    colnames(tbl),
    hubUtils::get_task_id_names(config_tasks)
  )
}

#' Get observation unit columns from target-data.json configuration.
#'
#' Extracts the observation unit from the target-data.json configuration using
#' `hubUtils::get_observable_unit()`. The `as_of` column is NEVER part of the
#' config's `observable_unit` (it's a versioning column), but may be added
#' based on `include_as_of` and `hubUtils::get_versioned()`.
#'
#' @param config_target_data Target-data.json config object.
#' @param target_type Target type: `"time-series"` or `"oracle-output"`.
#' @param include_as_of Logical indicating whether to include `as_of` in the
#'   observation unit. `as_of` is only added if this is `TRUE` AND the data
#'   is versioned (per `hubUtils::get_versioned()`).
#' @return A character vector of columns that define the observation unit.
#' @noRd
get_obs_unit_from_config <- function(
  config_target_data,
  target_type,
  include_as_of = FALSE
) {
  # Validate target_type
  target_type <- rlang::arg_match(
    target_type,
    values = c("time-series", "oracle-output")
  )

  # Get observable unit from config
  obs_unit <- hubUtils::get_observable_unit(config_target_data, target_type)

  # Determine if as_of should be added
  # as_of is NEVER part of the observable_unit in config (it's a versioning column)
  if (
    include_as_of && hubUtils::get_versioned(config_target_data, target_type)
  ) {
    obs_unit <- c(obs_unit, "as_of")
  }

  obs_unit
}

#' Get observation unit columns by inferring from table and task configuration.
#'
#' Infers the observation unit from the table by combining task identifier
#' columns from the hub config with `"as_of"` (if present in the table and
#' `include_as_of` is `TRUE`).
#' This approach is used for backward compatibility when target-data.json
#' configuration is not available.
#'
#' @param tbl A target data frame (oracle output or time-series target data).
#' @param config_tasks A list of task configurations from the hub config.
#' @param include_as_of Logical indicating whether to include `as_of` in the
#'   observation unit when present in the table. Defaults to `TRUE` for
#'   backward compatibility.
#' @return A character vector of columns that define the observation unit.
#' @noRd
get_obs_unit_from_tbl <- function(tbl, config_tasks, include_as_of = TRUE) {
  # Inference behavior: use task IDs that are present in the table
  obs_unit <- task_id_cols_to_validate(tbl, config_tasks)

  # Include as_of if present in the table and include_as_of is TRUE
  if (include_as_of && "as_of" %in% colnames(tbl)) {
    obs_unit <- c(obs_unit, "as_of")
  }

  obs_unit
}

#' Get target data observation unit columns.
#'
#' Determines the observation unit for target data, which defines the unique
#' combinations of columns that identify each independent observation.
#'
#' When `config_target_data` is provided, uses `get_obs_unit_from_config()`
#' to extract the observable unit from the target-data.json configuration.
#'
#' When `config_target_data` is `NULL`, uses `get_obs_unit_from_tbl()` to
#' infer the observation unit from task identifier columns and the presence
#' of `as_of` in the table.
#'
#' @param tbl A target data frame (oracle output or time-series target data).
#' @param config_tasks A list of task configurations from the hub config.
#' @param config_target_data Optional target-data.json config object. When `NULL`,
#'   falls back to inference behavior based on task IDs.
#' @param target_type Optional target type: `"time-series"` or `"oracle-output"`.
#'   Required when `config_target_data` is provided.
#' @param include_as_of Logical indicating whether to include `as_of` in the
#'   observation unit. When `config_target_data` is provided, `as_of` is only
#'   added if this is `TRUE` AND the data is versioned (per
#'   `hubUtils::get_versioned()`). When `config_target_data` is `NULL`, the
#'   parameter is passed to `get_obs_unit_from_tbl()` which includes `as_of`
#'   if present in the table AND this parameter is `TRUE`.
#' @return A character vector of columns that define the observation unit.
#' @noRd
get_obs_unit <- function(
  tbl,
  config_tasks,
  config_target_data = NULL,
  target_type = NULL,
  include_as_of = FALSE
) {
  if (!is.null(config_target_data)) {
    get_obs_unit_from_config(
      config_target_data,
      target_type,
      include_as_of
    )
  } else {
    get_obs_unit_from_tbl(tbl, config_tasks, include_as_of)
  }
}

#' Group target data by observation unit columns.
#'
#' Uses `get_obs_unit()` to determine grouping columns and returns the input
#' table grouped by those columns, suitable for downstream validation or
#' summarisation.
#'
#' @inheritParams get_obs_unit
#' @return A grouped tibble, grouped by observation unit.
#' @noRd
group_by_obs_unit <- function(
  tbl,
  config_tasks,
  config_target_data = NULL,
  target_type = NULL,
  include_as_of = FALSE
) {
  obs_unit <- get_obs_unit(
    tbl,
    config_tasks,
    config_target_data,
    target_type,
    include_as_of
  )
  group_by(tbl, across(all_of(obs_unit)))
}
