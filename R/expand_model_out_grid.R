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
expand_model_out_grid <- function(config_tasks,
                                  round_id,
                                  required_vals_only = FALSE,
                                  force_output_types = FALSE,
                                  all_character = FALSE,
                                  output_type_id_datatype = c(
                                    "from_config", "auto", "character",
                                    "double", "integer",
                                    "logical", "Date"
                                  ),
                                  as_arrow_table = FALSE,
                                  bind_model_tasks = TRUE,
                                  include_sample_ids = FALSE,
                                  compound_taskid_set = NULL,
                                  output_types = NULL,
                                  derived_task_ids = get_config_derived_task_ids(
                                    config_tasks, round_id
                                  )) {
  checkmate::assert_list(compound_taskid_set, null.ok = TRUE)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
  output_types <- validate_output_types(output_types, config_tasks, round_id)
  derived_task_ids <- validate_derived_task_ids(
    derived_task_ids,
    config_tasks, round_id
  )
  round_config <- get_round_config(config_tasks, round_id)
  # Create a logical variable to control what is returned by expand_output_type_grid.
  # See not in fn for details.
  all_output_types <- is.null(output_types) # nolint: object_usage_linter

  task_id_l <- purrr::map(
    round_config[["model_tasks"]],
    ~ .x[["task_ids"]] %>%
      derived_taskids_to_na(derived_task_ids) %>%
      null_taskids_to_na()
  ) %>%
    # Fix round_id value to current round_id in round_id variable column
    fix_round_id(
      round_id = round_id,
      round_config = round_config,
      round_ids = hubUtils::get_round_ids(config_tasks)
    ) %>%
    process_grid_inputs(required_vals_only = required_vals_only)

  # Get output type id property according to config schema version
  # TODO: remove back-compatibility with schema versions < v2.0.0 when support
  # retired
  config_tid <- hubUtils::get_config_tid(config_tasks = config_tasks)

  output_type_l <- subset_round_output_types(round_config, output_types) %>%
    extract_round_output_type_ids(config_tid, force_output_types) %>%
    process_grid_inputs(required_vals_only = required_vals_only) %>%
    purrr::map(~ purrr::compact(.x))

  # Expand output grid individually for each modeling task and output type.
  grid <- purrr::map2(
    task_id_l, output_type_l,
    ~ expand_output_type_grid(
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

  process_mt_grid_outputs(
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

# Subset model_task object output types according to `output_types`.
# If `output_types` is `NULL`, all output types are returned.
subset_mt_output_types <- function(model_task, output_types) {
  out <- model_task[["output_type"]]
  if (is.null(output_types)) {
    out
  } else {
    mt_output_types <- output_types[output_types %in% names(out)]
    out[mt_output_types]
  }
}

# Extracts/collapses individual task ID values depending on whether all or just required
# values are needed.
process_grid_inputs <- function(x, required_vals_only = FALSE) {
  if (required_vals_only) {
    purrr::map(x, ~ .x %>% purrr::map(~ .x[["required"]]))
  } else {
    purrr::modify_depth(x, .depth = 2, ~ unlist(.x, use.names = FALSE))
  }
}

# Function that expands modeling task level lists of task IDs and output type
# values into a grid and combines them into a single tibble.
expand_output_type_grid <- function(task_id_values,
                                    output_type_values,
                                    all_output_types = TRUE) {
  # Return a grid of only task IDs if no output type values are provided but
  # only if a specific output type subset is not requested.
  # Otherwise return a zero row grid.
  # No output type values can either be the result of all optional output types
  # when required values only are requested or as a result of output type sub-setting.
  # When requesting required values only for an entire rounds (i.e. all output types),
  # we want required task ID values to be returned, even is all output types are
  # optional. However, it does not make sense to return required values for an
  # optional output type when a user is specifically requesting required values
  # for an output type. In that situation it's more appropriate to return a zero row grid.
  if (length(output_type_values) == 0 && all_output_types) {
    return(
      expand.grid(
        purrr::compact(task_id_values),
        stringsAsFactors = FALSE
      )
    )
  }

  purrr::imap(
    output_type_values,
    ~ c(task_id_values, list(
      output_type = .y,
      output_type_id = .x
    )) %>%
      purrr::compact() %>%
      expand.grid(stringsAsFactors = FALSE)
  ) %>%
    purrr::list_rbind()
}

# Given expanded grids are constructed for specific rounds, this functions fixes
# the round_id in the any round_id variable column (if round_id_from_variable = TRUE)
fix_round_id <- function(x, round_id, round_config, round_ids) {
  if (round_config[["round_id_from_variable"]] && !is.null(round_id)) {
    round_id <- rlang::arg_match(round_id,
      values = round_ids
    )
    round_id_var <- round_config[["round_id"]]
    purrr::map(
      x,
      function(.x) {
        purrr::imap(
          .x,
          function(.x, .y) {
            if (.y == round_id_var) {
              list(required = round_id, optional = NULL)
            } else {
              .x
            }
          }
        )
      }
    )
  } else {
    x
  }
}

# Function that processes lists of modeling tasks grids of output type values
# and task IDs by (depending on settings):
# - padding with NA columns.
# - applying the required schema and converting to arrow tables.
# - binding multiple modeling task grids together.
process_mt_grid_outputs <- function(x, config_tasks, all_character,
                                    as_arrow_table = TRUE,
                                    bind_model_tasks = TRUE,
                                    output_type_id_datatype = output_type_id_datatype) {
  if (bind_model_tasks) {
    # To bind multiple modeling task grids together, we need to ensure they contain
    # the same columns. Any missing columns are padded with NAs.
    all_cols <- purrr::map(x, ~ names(.x)) %>%
      unlist() %>%
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
      x, ~ hubData::coerce_to_character(
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
    return(do.call(rbind, x))
  } else {
    return(x)
  }
}

# Pad any columns in all_cols missing in x of with new NA columns
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

    missing_cols <- as.list(rep(NA, length(missing_colnames))) %>%
      stats::setNames(missing_colnames) %>%
      as.data.frame() %>%
      arrow::arrow_table()

    return(cbind(x, missing_cols)[, all_cols])
  }
  x
}

# Convert required value to NA in task IDs where both required and optional
#  are  as NA.
null_taskids_to_na <- function(model_task) {
  to_na <- purrr::map_lgl(
    model_task, ~ all(purrr::map_lgl(.x, is.null))
  )
  purrr::modify_if(model_task,
    .p = to_na,
    ~ list(
      required = NA,
      optional = NULL
    )
  )
}

# Set derived task_ids to all NULL values.
derived_taskids_to_na <- function(model_task, derived_task_ids) {
  if (!is.null(derived_task_ids)) {
    purrr::modify_at(
      model_task,
      .at = derived_task_ids,
      .f = ~ list(
        required = NULL,
        optional = NA
      )
    )
  } else {
    model_task
  }
}

# Extract the output_type_id values for each model_task object in a round.
# Input should be the output of subset_round_output_types.
# config_tid is the name of the output_type_id column in the config schema used
# for back-compatibility with schema versions < v2.0.0. Returns a list of
# `required` and `optional` or just `required` vectors of values as appropriate for
# each output type in each model task in the round.
extract_round_output_type_ids <- function(x, config_tid, force_output_types = FALSE) {
  purrr::map(x, ~ extract_mt_output_type_ids(.x, config_tid, force_output_types))
}
# Extract the output_type_id values from a model_task object.
# config_tid is the name of the output_type_id column in the config schema used
# for back-compatibility with schema versions < v2.0.0. Returns a list of
# `required` and `optional` or just `required` vectors of values as appropriate for
# each output type in the model task.
extract_mt_output_type_ids <- function(x, config_tid, force_output_types = FALSE) {
  purrr::map(
    x,
    function(.x) {
      output_type_ids <- .x[[config_tid]]
      is_std <- std_output_type_ids(output_type_ids)
      if (is_std && !force_output_types) {
        return(output_type_ids)
      }
      if (is_std && force_output_types) {
        return(as_required(output_type_ids))
      }
      is_required <- is_required_output_type(.x) || force_output_types
      standardise_output_types_ids(output_type_ids, is_required)
    }
  )
}



validate_derived_task_ids <- function(derived_task_ids, config_tasks, round_id) {
  checkmate::assert_character(derived_task_ids, null.ok = TRUE)
  if (is.null(derived_task_ids)) {
    return(NULL)
  }
  round_task_ids <- hubUtils::get_round_task_id_names(config_tasks, round_id)
  valid_task_ids <- intersect(derived_task_ids, round_task_ids)
  if (length(valid_task_ids) < length(derived_task_ids)) {
    cli::cli_warn(
      c(
        "x" = "{.val {setdiff(derived_task_ids, round_task_ids)}}
        {?is/are} not valid task ID{?s}. Ignored.",
        "i" = "{.arg derived_task_ids} must be a member of: {.val {round_task_ids}}"
      ),
      call = rlang::caller_call()
    )
  }
  model_tasks <- hubUtils::get_round_model_tasks(config_tasks, round_id)
  has_required <- purrr::map(
    model_tasks,
    ~ .x[["task_ids"]][valid_task_ids] %>%
      purrr::map_lgl(
        ~ !is.null(.x$required)
      )
  ) %>%
    purrr::reduce(`|`)
  if (any(has_required)) {
    cli::cli_abort(
      c(
        "x" = "Derived task IDs cannot have required task ID values.",
        "!" = "{.val {names(has_required)[has_required]}} ha{?s/ve}
          required task ID values. Ignored."
      ),
      call = rlang::caller_call()
    )
  }
  valid_task_ids <- intersect(
    valid_task_ids,
    names(has_required)[!has_required]
  )
  if (length(valid_task_ids) == 0L) {
    return(NULL)
  }
  valid_task_ids
}
