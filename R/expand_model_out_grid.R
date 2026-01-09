#' Create expanded grid of valid task ID and output type value combinations
#'
#' @param config_tasks a list version of the content's of a hub's `tasks.json`
#' config file, accessed through the `"config_tasks"` attribute of a `<hub_connection>`
#' object or function [hubUtils::read_config()].
#' @param round_id Character string. Round identifier. If the round is set to
#' `round_id_from_variable: true`, IDs are values of the task ID defined in the round's
#' `round_id` property of `config_tasks`.
#' Otherwise should match round's `round_id` value in config. Ignored if hub
#' contains only a single round.
#' @param required_vals_only Logical. Whether to return only combinations of
#' Task ID and related output type ID required values.
#' @param force_output_types Logical. Whether to force all output types to be required.
#' If `TRUE`, all output type ID values are treated as required regardless
#' of the value of the `is_required` property. Useful for creating grids of required
#' values for optional output types.
#' @param all_character Logical. Whether to return all character column.
#' @param bind_model_tasks Logical. Whether to bind expanded grids of
#' values from multiple modeling tasks into a single tibble/arrow table or
#' return a list.
#' @param include_sample_ids Logical. Whether to include sample identifiers in
#' the `output_type_id` column.
#' @param compound_taskid_set List of character vectors, one for each modeling task
#' in the round. Can be used to override the compound task ID set defined in the
#' config. If `NULL` is provided for a given modeling task, a compound task ID set of
#' all task IDs is used.
#' @param output_types Character vector of output type names to include.
#' Use to subset for grids for specific output types.
#' @param derived_task_ids Character vector of derived task ID names (task IDs whose
#' values depend on other task IDs) to ignore. Columns for such task ids will
#' contain `NA`s. Defaults to extracting derived task IDs from `config_tasks`. See
#' [get_config_derived_task_ids()] for more details.
#'
#' @return If `bind_model_tasks = TRUE` (default) a tibble or arrow table
#' containing all possible task ID and related output type ID
#' value combinations. If `bind_model_tasks = FALSE`, a list containing a
#' tibble or arrow table for each round modeling task.
#'
#' Columns are coerced to data types according to the hub schema,
#' unless `all_character = TRUE`. If `all_character = TRUE`, all columns are returned as
#' character which can be faster when large expanded grids are expected.
#' If `required_vals_only = TRUE`, values are limited to the combinations of required
#' values only.
#'
#' Note that if `required_vals_only = TRUE` and an optional output type is
#' requested through `output_types`, a zero row grid will be returned.
#' If all output types are requested however (i.e. when `output_types = NULL`) and
#' they are all optional, a grid of required task ID values only will be returned.
#' However, whenever `force_output_types = TRUE`, all output types are treated as
#' required.
#' @inheritParams hubData::coerce_to_hub_schema
#' @details
#' When a round is set to `round_id_from_variable: true`,
#' the value of the task ID from which round IDs are derived (i.e. the task ID
#' specified in `round_id` property of `config_tasks`) is set to the value of the
#' `round_id` argument in the returned output.
#'
#' When sample output types are included in the output and `include_sample_ids = TRUE`,
#' the `output_type_id` column contains example sample indexes which are useful
#' for identifying the compound task ID structure of multivariate sampling
#' distributions in particular, i.e. which combinations of task ID values
#' represent individual samples.
#' @export
#'
#' @examples
#' hub_con <- hubData::connect_hub(
#'   system.file("testhubs/flusight", package = "hubUtils")
#' )
#' config_tasks <- attr(hub_con, "config_tasks")
#' expand_model_out_grid(config_tasks, round_id = "2023-01-02")
#' expand_model_out_grid(
#'   config_tasks,
#'   round_id = "2023-01-02",
#'   required_vals_only = TRUE
#' )
#' # Specifying a round in a hub with multiple round configurations.
#' hub_con <- hubData::connect_hub(
#'   system.file("testhubs/simple", package = "hubUtils")
#' )
#' config_tasks <- attr(hub_con, "config_tasks")
#' expand_model_out_grid(config_tasks, round_id = "2022-10-01")
#' # Later round_id maps to round config that includes additional task ID 'age_group'.
#' expand_model_out_grid(config_tasks, round_id = "2022-10-29")
#' # Coerce all columns to character
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-10-29",
#'   all_character = TRUE
#' )
#' # Return arrow table
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-10-29",
#'   all_character = TRUE,
#'   as_arrow_table = TRUE
#' )
#' # Hub with sample output type
#' config_tasks <- read_config_file(system.file("config", "tasks.json",
#'   package = "hubValidations"
#' ))
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-12-26"
#' )
#' # Include sample IDS
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-12-26",
#'   include_sample_ids = TRUE
#' )
#' # Hub with sample output type and compound task ID structure
#' config_tasks <- read_config_file(
#'   system.file("config", "tasks-comp-tid.json", package = "hubValidations")
#' )
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-12-26",
#'   include_sample_ids = TRUE
#' )
#' # Override config compound task ID set
#' # Create coarser compound task ID set for the first modeling task which contains
#' # samples
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-12-26",
#'   include_sample_ids = TRUE,
#'   compound_taskid_set = list(
#'     c("forecast_date", "target"),
#'     NULL
#'   )
#' )
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-12-26",
#'   include_sample_ids = TRUE,
#'   compound_taskid_set = list(
#'     NULL,
#'     NULL
#'   )
#' )
#' # Subset output types
#' config_tasks <- read_config(
#'   system.file("testhubs", "samples", package = "hubValidations")
#' )
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-10-29",
#'   include_sample_ids = TRUE,
#'   bind_model_tasks = FALSE,
#'   output_types = c("sample", "pmf"),
#' )
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-10-29",
#'   include_sample_ids = TRUE,
#'   bind_model_tasks = TRUE,
#'   output_types = "sample",
#' )
#' # Ignore derived task IDs
#' expand_model_out_grid(config_tasks,
#'   round_id = "2022-10-29",
#'   include_sample_ids = TRUE,
#'   bind_model_tasks = FALSE,
#'   output_types = "sample",
#'   derived_task_ids = "target_end_date"
#' )
#' # Return only required values
#' hub_path <- system.file("testhubs", "v4", "simple", package = "hubUtils")
#' config_tasks <- read_config(hub_path)
#' # Return required output types and output_types_ids only
#' expand_model_out_grid(
#'   config_tasks = config_tasks,
#'   round_id = "2022-10-22",
#'   required_vals_only = TRUE
#' )
#' # Force all output types to be required
#' expand_model_out_grid(
#'   config_tasks = config_tasks,
#'   round_id = "2022-10-22",
#'   required_vals_only = TRUE,
#'   force_output_types = TRUE
#' )
#' # Sub-setting for an optional output type returns an empty data frame
#' expand_model_out_grid(
#'   config_tasks = config_tasks,
#'   round_id = "2022-10-22",
#'   output_types = "mean",
#'   required_vals_only = TRUE
#' )
#' # force_output_types on an optional output type forces all output_type_id values
#' # to be required
#' expand_model_out_grid(
#'   config_tasks = config_tasks,
#'   round_id = "2022-10-22",
#'   output_types = "mean",
#'   required_vals_only = TRUE,
#'   force_output_types = TRUE
#' )
#' # Ignore derived task IDs
#' hub_path <- system.file("testhubs", "v4", "flusight", package = "hubUtils")
#' config_tasks <- read_config(hub_path)
#' # Defaults to using derived_task_ids from config
#' expand_model_out_grid(config_tasks, round_id = "2023-05-08")
#' # Can be overridden by argument derived_task_ids
#' expand_model_out_grid(config_tasks,
#'   round_id = "2023-05-08",
#'   derived_task_ids = NULL
#' )
expand_model_out_grid <- function(
  config_tasks,
  round_id,
  required_vals_only = FALSE,
  force_output_types = FALSE,
  all_character = FALSE,
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  as_arrow_table = FALSE,
  bind_model_tasks = TRUE,
  include_sample_ids = FALSE,
  compound_taskid_set = NULL,
  output_types = NULL,
  derived_task_ids = get_config_derived_task_ids(
    config_tasks,
    round_id
  )
) {
  checkmate::assert_list(compound_taskid_set, null.ok = TRUE)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
  output_types <- validate_output_types(output_types, config_tasks, round_id)
  derived_task_ids <- validate_derived_task_ids(
    derived_task_ids,
    config_tasks,
    round_id
  )
  round_config <- get_round_config(config_tasks, round_id)
  # Create a logical variable to control what is returned by expand_model_task_grid.
  # See function documentation for details.
  all_output_types <- is.null(output_types) # nolint: object_usage_linter

  task_id_l <- purrr::map(
    round_config[["model_tasks"]],
    ~ .x[["task_ids"]] |>
      derived_taskids_to_na(derived_task_ids) |>
      null_taskids_to_na()
  ) |>
    # Fix round_id value to current round_id in round_id variable column
    fix_round_id(
      round_id = round_id,
      round_config = round_config,
      round_ids = hubUtils::get_round_ids(config_tasks)
    ) |>
    extract_property_values(required_vals_only = required_vals_only)

  # Get output type id property according to config schema version
  # TODO: remove back-compatibility with schema versions < v2.0.0 when support
  # retired
  config_tid <- hubUtils::get_config_tid(config_tasks = config_tasks)

  output_type_l <- subset_round_output_types(round_config, output_types) |>
    extract_round_output_type_ids(config_tid, force_output_types) |>
    extract_property_values(required_vals_only = required_vals_only) |>
    purrr::map(~ purrr::compact(.x))

  # Expand output grid individually for each modeling task.
  grid <- purrr::map2(
    task_id_l,
    output_type_l,
    ~ expand_model_task_grid(
      task_id_values = .x,
      output_type_values = .y,
      all_output_types = all_output_types
    )
  )

  if (include_sample_ids) {
    if (is.null(compound_taskid_set)) {
      compound_taskid_set <- get_round_compound_task_ids(config_tasks, round_id)
    }
    grid <- add_sample_idx(grid, round_config, config_tid, compound_taskid_set)
  }

  process_model_task_grids(
    grid,
    config_tasks,
    all_character = all_character,
    as_arrow_table = as_arrow_table,
    bind_model_tasks = bind_model_tasks,
    output_type_id_datatype = output_type_id_datatype
  )
}

# Subset output types according to `output_types` from all model_task objects in
# a round. If `output_types` is `NULL`, all output types for each model task are
# returned.
subset_round_output_types <- function(round_config, output_types) {
  purrr::map(
    round_config[["model_tasks"]],
    ~ subset_mt_output_types(.x, output_types)
  )
}

#' Subset model_task object output types according to `output_types`.
#'
#' @param model_task A model_task object from a round configuration.
#' @param output_types Character vector of output type names to subset. If
#' n`output_types` is `NULL`, all output types are returned.
#'
#' @returns A subset of `model_task` containing only the output types in
#'  `output_types`.
#' @noRd
subset_mt_output_types <- function(model_task, output_types) {
  out <- model_task[["output_type"]]
  if (is.null(output_types)) {
    out
  } else {
    mt_output_types <- output_types[output_types %in% names(out)]
    out[mt_output_types]
  }
}

#' Extracts/collapses individual task ID/output type ID values depending on
#' whether all or just required values are needed.
#'
#' @param x A `task_ids` object or list of `output_type_ids` from a `model_task`
#' object.
#' @param required_vals_only Logical. Whether to return only required values.
#'
#' @returns A named list containining vectors of task ID/output type ID values,
#' one for each element in `x`. If `required_vals_only = TRUE`, only required
#' values are returned. Otherwise, all values are collapsed into a single vector
#' and returned.
#' @noRd
extract_property_values <- function(x, required_vals_only = FALSE) {
  if (required_vals_only) {
    purrr::map(x, ~ .x |> purrr::map(~ .x[["required"]]))
  } else {
    purrr::modify_depth(x, .depth = 2, ~ unlist(.x, use.names = FALSE))
  }
}

#' Create a model task level expanded grid of valid values
#'
#' Function that expands modeling task level lists of task IDs and output type
#' values into a grid and combines them into a single tibble.
#' @param task_id_values A named list of vectors of task ID values for a single
#' model task, one element for each task ID.
#' @param output_type_values A named list of vectors of output type values for a
#' single model task, one element for each output type.
#' @param all_output_types Logical. Whether to return a grid of only task IDs if
#' no output type values are provided or a zero row grid. See details.
#'
#' @returns Returns a grid of only task IDs if no output type values are provided but
#' only if a specific output type subset is not requested. Otherwise return a
#' zero row grid.
#' @details
#' No output type values can either be the result of all optional output types
#' when required values only are requested or as a result of output type sub-setting.
#' When requesting required values only for an entire round (i.e. all output types),
#' we want required task ID values to be returned, even if all output types are
#' optional. However, it does not make sense to return required values for an
#' optional output type when a user is specifically requesting required values
#' for an output type. In that situation it's more appropriate to return a
#' zero row grid, which is what this function does. We use the value of
#' `all_output_types` to distinguish between these two scenarios.
#' @noRd
expand_model_task_grid <- function(
  task_id_values,
  output_type_values,
  all_output_types = TRUE
) {
  if (length(output_type_values) == 0 && all_output_types) {
    return(
      expand.grid(
        purrr::compact(task_id_values),
        stringsAsFactors = FALSE
      )
    )
  }

  # Iterate over each output type and create an expanded grid of valid task ID and
  # output type ID values for each output type by combining it with the same list
  # of task ID values.
  purrr::imap(
    output_type_values,
    # Combine the task ID values and each output type ID value into a single
    # list of vectors and expand the grid.
    ~ c(
      task_id_values,
      list(
        output_type = .y, # expand the output type name into the `output_type` column
        output_type_id = .x # expand the output type ID values into the
        # `output_type_id` column
      )
    ) |>
      purrr::compact() |>
      expand.grid(stringsAsFactors = FALSE)
  ) |>
    purrr::list_rbind()
}


#' Fix the `round_id` in a `round_id` task ID variable
#'
#' Given expanded grids are always constructed for a specific round, this function
#' fixes the value of a `round_id` task ID variable when `round_id_from_variable = TRUE`
#' in the round configuration to a single `round_id` value.
#' @param x A list representation of `model_task` objects, subset to contain only
#' `task_ids` objects.
#' @param round_id The round ID to set in the `round_id` variable column.
#' @param round_config The round configuration object.
#' @param round_ids A character vector of valid round IDs.
#'
#' @returns If `round_config$round_id_from_variable` is `TRUE`, the `required`
#' value of the task ID in `x` defined by the `round_config$round_id` property
#' is set to the single `round_id` value.
#' If `round_config$round_id_from_variable` is `FALSE`, `x` is returned unchanged.
#' @noRd
fix_round_id <- function(x, round_id, round_config, round_ids) {
  if (!round_config[["round_id_from_variable"]] || is.null(round_id)) {
    return(x)
  }
  round_id <- rlang::arg_match(round_id, values = round_ids)
  round_id_var <- round_config[["round_id"]]

  # Iterate over each `model_task` object and set the `required` value in the
  # `round_id` task ID variable to the single `round_id` value. Set optional
  # to `NULL` as a round_id value is always required.
  purrr::map(
    x,
    function(model_task) {
      purrr::modify_at(
        model_task,
        .at = round_id_var,
        .f = ~ list(
          required = round_id,
          optional = NULL
        )
      )
    }
  )
}

#' Process expanded grids of modeling task valid values before returning.
#'
#' Once expanded grids of valid values for each modeling task in a round have been
#' created, some post processing is required before returning the final grid in the
#' required format. This function performs the following tasks:
#' - add any missing columns as NA columns if required.
#  - apply any requested schema.
#  - convert to arrow tables if requested.
#  - bind multiple modeling task grids together if requested.
#' @param x A list of expanded grids of valid values for each modeling task in a round.
#' @param config_tasks A list version of the content's of a hub's `tasks.json`
#' @param all_character Logical. Whether to convert all columns to character.
#' Otherwise the hub schema is applied.
#' @param as_arrow_table Logical. Whether to return the output as an arrow table.
#' @param bind_model_tasks Logical. Whether to bind multiple modeling task grids
#' together into a single tibble/arrow table or return a list of model task grids
#' @param output_type_id_datatype Character vector of data type to apply to
#' the `output_type_id` column. See [hubData::coerce_to_hub_schema] for details.
#'
#' @returns If `bind_model_tasks = TRUE` (default) a processed single tibble or
#' arrow table, otherwise a list of processed tibbles or arrow tables.
#' @noRd
process_model_task_grids <- function(
  x,
  config_tasks,
  all_character,
  as_arrow_table = TRUE,
  bind_model_tasks = TRUE,
  output_type_id_datatype = output_type_id_datatype
) {
  if (bind_model_tasks) {
    # To bind multiple modeling task grids together, we need to ensure they contain
    # the same columns. Any missing columns are padded with NAs.
    all_cols <- purrr::map(x, ~ names(.x)) |>
      unlist() |>
      unique()

    schema_cols <- names(
      create_hub_schema(
        config_tasks,
        partitions = NULL,
        output_type_id_datatype = output_type_id_datatype
      )
    )
    all_cols <- schema_cols[schema_cols %in% all_cols]
    x <- purrr::map(x, ~ pad_missing_cols(.x, all_cols))
  }

  if (all_character) {
    x <- purrr::map(
      x,
      ~ hubData::coerce_to_character(
        .x,
        as_arrow_table = as_arrow_table
      )
    )
  } else {
    x <- purrr::map(
      x,
      ~ coerce_to_hub_schema(
        .x,
        config_tasks,
        as_arrow_table = as_arrow_table,
        output_type_id_datatype = output_type_id_datatype
      )
    )
  }
  if (bind_model_tasks) {
    do.call(rbind, x)
  } else {
    x
  }
}

#' Add missing columns to expanded model task grids
#'
#' Add new `NA` columns to `x` for any column name present in `all_cols` but
#' missing in `x`.
#' @param x expanded grid of valid values for a single modeling task.
#' @param all_cols Character vector of all columns that should be present in the
#' expanded grid.
#'
#' @returns The expanded grid with any missing columns added as `NA` columns.
#' @noRd
pad_missing_cols <- function(x, all_cols) {
  if (ncol(x) == 0L) {
    return(x)
  }
  if (inherits(x, "data.frame")) {
    x[, all_cols[!all_cols %in% names(x)]] <- NA
    return(x[, all_cols])
  }
  if (inherits(x, "ArrowTabular")) {
    missing_colnames <- setdiff(all_cols, names(x))
    if (length(missing_colnames) == 0L) {
      return(x)
    }

    missing_cols <- as.list(rep(NA, length(missing_colnames))) |>
      stats::setNames(missing_colnames) |>
      as.data.frame() |>
      arrow::arrow_table()

    return(cbind(x, missing_cols)[, all_cols])
  }
  x
}

#' Convert all null task IDs to standard format
#'
#' In situations where a task ID is not relevant to a model task, both elements will
#' be `NULL`. To convert to a standard format that with a valid value in the
#' expanded grid, we set the `required` value to `NA` and the `optional` value to
#' `NULL`.
#' @param model_task A `model_task` object.
#'
#' @returns A `model_task` object with all null task IDs converted to a standard
#' format.
#' @noRd
null_taskids_to_na <- function(model_task) {
  to_na <- purrr::map_lgl(
    model_task,
    ~ all(purrr::map_lgl(.x, is.null))
  )
  purrr::modify_if(
    model_task,
    .p = to_na,
    ~ list(
      required = NA,
      optional = NULL
    )
  )
}

#' Extract the `output_type_id` values for each `output_type` in each `model_task`
#' object in a round
#'
#' @param x List. An R representation all `model_task` objects for a single round,
#' one element for each model task. Each `model_task` must be subset to contain
#' only `output_type` properties (i.e. the output of `subset_round_output_types()`).
#' @param config_tid Character string. The name of the output_type_id column in the
#' config schema used for back-compatibility with schema versions < v2.0.0.
#' @param force_output_types Logical. Whether to force all `output_type_id`s to
#' be required.
#'
#' @returns list containing an element for each model task. Each model task elements
#'  is a named list, with one element per `output_type`. Each named `output_type`
#'  element contains the `output_type_id`s in a standardised format (i.e. having
#'  `required` and `optional` vectors of values.
#' @noRd
extract_round_output_type_ids <- function(
  x,
  config_tid,
  force_output_types = FALSE
) {
  purrr::map(
    x,
    ~ extract_model_task_output_type_ids(
      .x,
      config_tid,
      force_output_types
    )
  )
}

#' Extract and standardise the `output_type_id` values from a `model_task` object.
#'
#' The function extracts the `output_type_id` element from each output type in a
#' model task object. If the output type id values are already standardised, they
#' are returned as is. If not (e.g if they are post v4 output type IDs),
#' they are standardised to a std format that contains both a `required` and
#' `optional` element. See documentation of the `standardise_output_types_ids()`
#' function for more details.
#' @param x List. An R representation of the `output_types` property of a single
#' `model_task` (the output of `subset_mt_output_types()`).
#' @param config_tid Character string. The name of the output_type_id column in the
#' config schema used for back-compatibility with schema versions < v2.0.0.
#' @param force_output_types Logical. Whether to force all output types to be
#' required. Used for forcing consistent behaviour when creating pre v4 grids with
#' that of post v4 grids.
#'
#' @returns a named list of standardised `output_type_id` objects, one element
#' for each output type in a given the model task.
#' @noRd
extract_model_task_output_type_ids <- function(
  x,
  config_tid,
  force_output_types = FALSE
) {
  purrr::map(
    x,
    function(output_type) {
      is_required <- is_required_output_type(output_type) || force_output_types
      process_output_type_ids(
        output_type_ids = output_type[[config_tid]],
        force_output_types = force_output_types,
        is_required = is_required
      )
    }
  )
}

#' Process output_type_ids to ensure they are in a standard format.
#'
#' This function is used to convert post v4 output type IDs to the standard
#' (pre v4) format that contains both a `required` and `optional` element. This
#' in turn allows the use of existing infrastructure to process post v4 output
#' type IDs in the same way as pre v4 output type IDs and task IDs.
#' @param output_type_ids A list representation of an `output_type_id` object.
#' @param force_output_types Logical. Whether to force all output types to be
#' required. Used for forcing consistent behaviour when formatting pre v4 output
#' type IDs to conform to the post v4 expectation of all output type IDs being
#' required when an output type is requested.
#' @param is_required Logical. Whether the output type is required.
#'
#' @returns A standardised `output_type_id` object that has a `required` and
#' `optional` element.
#' @noRd
process_output_type_ids <- function(
  output_type_ids,
  force_output_types,
  is_required
) {
  is_std <- std_output_type_ids(output_type_ids)
  if (is_std && !force_output_types) {
    return(output_type_ids)
  }
  if (is_std && force_output_types) {
    return(as_required(output_type_ids))
  }
  standardise_output_types_ids(output_type_ids, is_required)
}
