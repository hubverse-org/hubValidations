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
  value_sets <- hubUtils::get_round_value_sets_config(
    config_tasks,
    round_id,
    required_vals_only = required_vals_only,
    force_output_types = force_output_types,
    output_types = output_types,
    derived_task_ids = derived_task_ids,
    call = rlang::current_env()
  )
  round_config <- get_round_config(config_tasks, round_id)
  round_id_var <- if (isTRUE(round_config[["round_id_from_variable"]])) {
    round_config[["round_id"]]
  }
  # Create a logical variable to control what is returned by expand_model_task_grid.
  # See function documentation for details.
  all_output_types <- is.null(output_types) # nolint: object_usage_linter

  # Expand output grid individually for each modeling task.
  grid <- purrr::map2(
    round_config[["model_tasks"]],
    value_sets,
    \(model_task, mt_value_sets) {
      grid_task_ids <- get_grid_task_id_names(
        model_task,
        round_id_var,
        required_vals_only = required_vals_only,
        derived_task_ids = derived_task_ids
      )
      expand_model_task_grid(
        task_id_values = flatten_values(
          mt_value_sets[["task_ids"]][grid_task_ids]
        ),
        output_type_values = flatten_values(
          mt_value_sets[["output_type_ids"]]
        ) |>
          purrr::compact(),
        all_output_types = all_output_types
      )
    }
  )

  if (include_sample_ids) {
    if (is.null(compound_taskid_set)) {
      compound_taskid_set <- get_round_compound_task_ids(config_tasks, round_id)
    }
    grid <- add_sample_idx(
      grid,
      round_config,
      hubUtils::get_config_tid(config_tasks = config_tasks),
      compound_taskid_set
    )
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

#' Task ID columns of a modeling task's grid
#'
#' [hubUtils::get_round_value_sets_config()] gives each modeling task every task
#' ID in the round. A task ID that other modeling tasks use but this one leaves
#' out of its config comes back as `NA`, as does one with no values to expand.
#' A modeling task's grid leaves out some of those columns, and this function
#' names the ones it keeps:
#'
#' - task IDs the modeling task lists in its config, in config order.
#' - With `required_vals_only = TRUE`, only those with required values, those
#'   listed as `null`, and the round ID task ID of a round that takes its round
#'   IDs from a task ID. Derived task IDs are left out.
#'
#' Note that when modeling task grids are bound, columns left out of one grid
#' but present in another are padded with `NA`.
#'
#' @param model_task A `model_task` object from a round configuration.
#' @param round_id_var The round ID task ID of a round that takes its round
#'   IDs from a task ID, otherwise `NULL`.
#' @inheritParams expand_model_out_grid
#'
#' @returns A character vector of task ID names.
#' @noRd
get_grid_task_id_names <- function(
  model_task,
  round_id_var,
  required_vals_only,
  derived_task_ids
) {
  task_ids <- model_task[["task_ids"]]
  if (!required_vals_only) {
    return(names(task_ids))
  }
  has_required <- purrr::map_lgl(
    task_ids,
    \(x) !is.null(x[["required"]]) || is.null(x[["optional"]])
  )
  keep <- has_required | names(task_ids) %in% round_id_var
  setdiff(names(task_ids)[keep], derived_task_ids)
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
