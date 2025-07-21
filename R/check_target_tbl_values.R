#' Check that task ID columns in a target data file have valid task ID values
#'
#' Check is only performed when the target data file contains columns that map onto
#' task IDs or output types defined in the hub configuration.
#' @param target_tbl_chr A tibble/data.frame of the contents of the target data file
#' being validated. All columns should be coerced to character.
#' @inheritParams check_target_file_name
#' @inheritParams check_target_tbl_colnames
#' @inherit check_tbl_colnames params return
#' @inheritParams hubData::get_target_path
#' @export
check_target_tbl_values <- function(target_tbl_chr,
                                    target_type = c(
                                      "time-series", "oracle-output"
                                    ),
                                    file_path, hub_path) {
  target_type <- rlang::arg_match(target_type)
  config_tasks <- read_config(hub_path)

  # If no task IDs and output types are present in the target_tbl_chr, we can skip the check
  if (!has_conf_cols(target_tbl_chr, config_tasks)) {
    return(
      capture_check_info(
        file_path = file_path,
        msg = cli::format_inline(
          "`target_tbl_chr` contains no task ID or output type columns, skipping check."
        )
      )
    )
  }

  details <- NULL

  invalid_tbl <- detect_invalid_target_vals(target_tbl_chr, config_tasks)

  check <- nrow(invalid_tbl) == 0L

  if (!check) {
    details <- c(
      details,
      summarise_invalid_target_values(
        valid_tbl = extract_target_data_vals(
          config_tasks, target_tbl_chr,
          collapse = TRUE, intersect = FALSE
        ),
        invalid_tbl
      )
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline("{.var target_tbl_chr}"),
    msg_attribute = "",
    msg_verbs = c(
      "contains valid values/value combinations.",
      "contains invalid values/value combinations."
    ),
    error_tbl = if (check) NULL else invalid_tbl,
    details = details,
    error = TRUE
  )
}

#' Detect invalid target table values
#'
#' Identify rows in a target table that do not match any valid combinations
#' defined in the hub configuration. If output types are included in the columns
#' to validate, the function is iterated over each output type separately.
#'
#' Used internally by `check_target_tbl_values()`.
#'
#' @param target_tbl_chr A tibble of target data.
#' @param config_tasks A list representation of the contents of the `tasks.json`
#' hub configuration file.
#'
#' @return A tibble of invalid rows.
#' @noRd
detect_invalid_target_vals <- function(target_tbl_chr, config_tasks) {
  if (has_output_types(target_tbl_chr)) {
    split(target_tbl_chr, f = target_tbl_chr$output_type) |>
      purrr::imap(~ create_invalid_tbl(
        config_tasks,
        target_tbl_chr = .x, output_type = .y
      )) |>
      purrr::list_rbind()
  } else {
    create_invalid_tbl(
      config_tasks,
      target_tbl_chr = target_tbl_chr, output_type = NULL
    )
  }
}

#' Create a tibble of invalid rows for a target table
#'
#' Compares target table values to valid config values and returns any invalid rows.
#'
#' Used internally by `detect_invalid_target_vals()`.
#'
#' @param config_tasks A list representation of the contents of the `tasks.json`
#' hub configuration file.
#' @param target_tbl_chr A tibble of target data.
#' @param output_type The output type to filter by, or `NULL`.
#'
#' @return A tibble of invalid rows.
#' @noRd
create_invalid_tbl <- function(config_tasks, target_tbl_chr, output_type = NULL) {
  valid_tbl <- expand_target_data_vals(config_tasks,
    target_tbl_chr = target_tbl_chr,
    output_type = output_type
  )
  # If no valid config values are found to overlap with target_tbl_chr, it means the
  # entire target_tbl_chr is invalid.
  if (nrow(valid_tbl) == 0L) {
    target_tbl_chr
  } else {
    # Otherwise any rows in target_tbl_chr that do not match valid_tbl are considered
    # invalid
    dplyr::anti_join(
      target_tbl_chr,
      valid_tbl,
      by = target_cols_to_validate(target_tbl_chr, config_tasks)
    )
  }
}

#' Expand target values from hub configuration
#'
#' Expand and rbind all combinations of valid config values for all rounds and
#' modeling tasks that intersect with values in a `target_tbl_chr`.
#'
#' Used internally to determine all valid target combinations for downstream checks.
#'
#' @param config_tasks A list of modeling rounds, typically taken from the
#' `"tasks"` section of a hub configuration.
#' @param target_tbl_chr A tibble of target data.
#' @param output_type The output type to expand (if applicable), or `NULL` to
#' expand across all output types.
#' @param intersect If `TRUE`, only returns values that intersect with `target_tbl_chr`.
#'
#' @return A tibble containing all valid combinations of
#' task ID/output_type/output_type_id values present
#' in both the hub configuration and `target_tbl_chr`.
#' @noRd
expand_target_data_vals <- function(config_tasks, target_tbl_chr,
                                    output_type = NULL, intersect = TRUE) {
  extract_target_data_vals(
    config_tasks,
    target_tbl_chr,
    output_type = output_type,
    intersect = intersect
  ) |>
    purrr::map(~ expand.grid(.x, stringsAsFactors = FALSE)) |>
    purrr::list_rbind()
}

#' Extract target data values for all rounds and tasks
#'
#' Extracts all valid config values for each model task in each round,
#' returning a list of value sets present in `target_tbl_chr`.
#' Optionally collapses across rounds and tasks to produce unique values for each column.
#'
#' Used internally by `expand_target_data_vals()`.
#'
#' @param config_tasks A list of modeling rounds, typically taken from the
#' `"tasks"` section of a hub configuration.
#' @param target_tbl_chr A tibble of target data, with columns corresponding to task IDs/output types.
#' @param collapse If `TRUE`, returns a single collapsed list of unique values
#' for each relevant column.
#' @param intersect If `TRUE`, only returns values that intersect with value
#' in `target_tbl_chr`.
#'
#' @return A list of value sets for each model task, or a collapsed list of
#' unique values if `collapse = TRUE`.
#' @noRd
extract_target_data_vals <- function(config_tasks, target_tbl_chr, output_type = NULL,
                                     collapse = FALSE, intersect = TRUE) {
  out <- config_tasks[["rounds"]] |>
    purrr::map(~ extract_round_vals(
      .x,
      target_tbl_chr,
      output_type = output_type,
      intersect = intersect
    )) |>
    # Remove round depth of nesting so that we have a list of all model tasks
    purrr::list_flatten() |>
    unique()

  if (collapse) {
    out <- out |>
      # This turns the flattened list of model_task values inside out so that at
      # the top level are elements for each column name, and at the second level
      # are vectors of the values one for each model task.
      purrr::list_transpose(simplify = FALSE) |>
      # Next we unlist the values for each column, so that we have a single
      # vector of unique values for each column name.
      purrr::modify_depth(.depth = 1, ~ unique(unlist(.x, use.names = FALSE)))
  }
  return(out)
}


#' Extract valid value combinations for a round
#'
#' Extracts config values for all model tasks in a single round configuration,
#' returning lists of valid value sets present in `target_tbl_chr`, one for each model
# æ task in the round.
#'
#' Used internally by `extract_target_data_vals()`.
#'
#' @param round_config A list describing a single round's model tasks (from
#' hub configuration).
#' @param target_tbl_chr A tibble of target data, with columns corresponding to
# æ task IDs/output types.
#' @param intersect If `TRUE`, only returns values that intersect with `target_tbl_chr`.
#'
#' @return A list of value combinations for each model task in the round.
#' @noRd
extract_round_vals <- function(round_config, target_tbl_chr, output_type = NULL,
                               intersect = TRUE) {
  purrr::map(
    round_config[["model_tasks"]],
    ~ extract_model_task_vals(.x, target_tbl_chr,
      output_type = output_type,
      intersect = intersect
    )
  ) |>
    unique() |>
    purrr::compact()
}

#' Extract intersecting config valid values for a model task
#'
#' Extracts valid config values for a given model task, based on
#' values present in `target_tbl_chr`.
#'
#' Returns `NULL` if no valid combination exists, i.e. when any of
#' the task IDs or output types (if applicable) have no intersecting values with
#' the `target_tbl_chr` values.
#'
#' Used internally by `extract_round_vals()`.
#'
#' @param model_task A single model task configuration (from hub config).
#' @param target_tbl_chr A tibble of target data, with columns corresponding to task IDs.
#' @param intersect If `TRUE`, only returns values that intersect with `target_tbl_chr`.
#'
#' @return A named list of valid task ID/output_type/output_type_id values for
#' the model task, or `NULL` if no intersection is found.
#' @noRd
extract_model_task_vals <- function(model_task, target_tbl_chr, output_type = NULL,
                                    intersect = TRUE) {
  # If output_type is specified but not present in the model_task, return NULL
  if (!is.null(output_type) && is.null(model_task$output_type[[output_type]])) {
    return(NULL)
  }

  task_id_target_cols <- intersect(
    colnames(target_tbl_chr), names(model_task[["task_ids"]])
  )
  output_type_target_cols <- intersect(
    colnames(target_tbl_chr),
    hubUtils::std_colnames[c("output_type", "output_type_id")]
  )
  cols_to_extract <- c(task_id_target_cols, output_type_target_cols)

  # If no task ID or output type columns are present in target_tbl_chr, return NULL
  if (length(cols_to_extract) == 0L) {
    return(NULL)
  }

  # Extracts a list of task ID values from the model_task for task IDs that match columns
  # in target_tbl_chr. If no task ID columns are present in target_tbl_chr, returns NULL.
  config_task_id_vals <- extract_config_task_is_vals(model_task, task_id_target_cols)

  # Extracts the output_type and output_type_id values from the model_task if
  # output type columns are present in target_tbl_chr
  if (has_output_types(target_tbl_chr)) {
    if (is.null(output_type)) {
      config_output_type_vals <- extract_config_all_output_type_vals(
        model_task,
        output_type_target_cols
      )
    } else {
      config_output_type_vals <- extract_config_output_type_vals(
        model_task, output_type_target_cols, output_type
      )
    }
  } else {
    config_output_type_vals <- NULL
  }

  config_vals <- c(config_task_id_vals, config_output_type_vals)[cols_to_extract]

  if (intersect) {
    # If intersect = TRUE, filter config values to include only those that are
    # present in the target_tbl_chr. First extract the unique target values to
    # intersect against, then apply intersection for each column.
    target_vals <- target_tbl_chr[cols_to_extract] |>
      purrr::map(~ unique(.x))

    vals <- purrr::map2(
      target_vals,
      config_vals,
      ~ intersect(.x, .y)
    )
  } else {
    # If intersect = FALSE, return full set of config values without filtering.
    vals <- config_vals
  }

  # If any of the variable values are empty, indicating the target_tbl_chr data does not
  # map onto this particular model task, and intersect is FALSE, return NULL.
  if (any(lengths(vals) == 0L) && !intersect) {
    return(NULL)
  }

  vals
}

#' Extract valid output_type values for a model task
#'
#' Returns a named list of `output_type` and `output_type_id` values for a given
#' model task and specified output type.
#' If the output type does not expect an `output_type_id`, returns `NA`.
#'
#' Used internally by `extract_model_task_vals()`.
#'
#' @param model_task A single model task configuration (from hub config).
#' @param output_type_target_cols Columns to extract (subset of
#' `c("output_type", "output_type_id")`).
#' @param output_type The output type to extract.
#'
#' @return A named list of `output_type` and `output_type_id` values.
#' @noRd
extract_config_output_type_vals <- function(model_task, output_type_target_cols,
                                            output_type) {
  # Extract the output_type_id from the model_task or
  # cast as NA if expected for the output_type in target data.
  if (output_type %in% c("cdf", "pmf")) {
    list(
      output_type = output_type,
      output_type_id = purrr::pluck(
        model_task, "output_type",
        output_type, "output_type_id"
      ) |>
        unlist(use.names = FALSE) |>
        # Ensure vectors returned are character.
        as.character()
    )[output_type_target_cols]
  } else {
    list(
      output_type = output_type,
      output_type_id = NA_character_
    )[output_type_target_cols]
  }
}

#' Extract valid output_type values for all output types in a model task
#'
#' Returns a named list of all valid `output_type` and `output_type_id` values
#' for a given model task.
#'
#' Used internally by `extract_model_task_vals()`.
#'
#' @param model_task A single model task configuration (from hub config).
#' @param output_type_target_cols Columns to extract (subset of
#' `c("output_type", "output_type_id")`).
#'
#' @return A named list of `output_type` and `output_type_id` values.
#' @noRd
extract_config_all_output_type_vals <- function(model_task, output_type_target_cols) {
  names(model_task[["output_type"]]) |>
    purrr::map(
      ~ extract_config_output_type_vals(model_task, output_type_target_cols,
        output_type = .x
      )
    ) |>
    purrr::list_transpose(simplify = FALSE) |>
    purrr::modify_depth(.depth = 1, ~ unique(unlist(.x, use.names = FALSE)))
}


#' Extract valid task ID values for a model task
#'
#' Returns a named list of task ID values for a model task, collapsing across
#' `required` and `optional` entries and encoding NULLs as `NA`.
#'
#' Used internally by `extract_model_task_vals()`.
#'
#' @param model_task A single model task configuration (from hub config).
#' @param task_id_target_cols Columns to extract (subset of task ID columns).
#'
#' @return A named list of task ID values for the model task.
#' @noRd
extract_config_task_is_vals <- function(model_task, task_id_target_cols) {
  if (length(task_id_target_cols) == 0L) {
    return(NULL)
  }
  model_task[["task_ids"]][task_id_target_cols] |>
    # Encode task IDs that might be NULL in a given model task as NA
    null_taskids_to_na() |>
    # Unlist the values to collapse `required` and `optional` properties and
    # ensure vectors returned are character.
    purrr::modify_depth(
      .depth = 1,
      ~ unlist(.x, use.names = FALSE) |>
        as.character()
    )
}


# Summarise results of check for invalid values by creating appropriate
# messages.
# First we report any invalid values in the tbl that do not match any values in the
# config. Second we report the presence of rows that contain valid values but in invalid
# combinations.
summarise_invalid_target_values <- function(valid_tbl, invalid_tbl) {
  # Check for invalid values
  unique_valid <- purrr::map(valid_tbl, unique)

  invalid_vals <- purrr::map2(
    .x = invalid_tbl[, names(unique_valid)],
    .y = unique_valid,
    ~ setdiff(.x, .y)
  ) |>
    purrr::compact()

  if (length(invalid_vals) != 0L) {
    invalid_vals_msg <- purrr::imap_chr(
      invalid_vals,
      ~ cli::format_inline(
        "Column {.var {.y}} contains invalid {cli::qty(length(.x))}
        value{?s} {.val {.x}}"
      )
    ) |>
      paste(collapse = "; ") |>
      paste0(".")
  } else {
    invalid_vals_msg <- NULL
  }

  # Check for invalid combinations by determining which rows in the
  # invalid_tbl do not contain invalid values.
  invalid_combo_rows <- purrr::imap(
    invalid_vals,
    ~ which(invalid_tbl[[.y]] %in% .x)
  ) |>
    unlist(use.names = FALSE) |>
    unique() |>
    setdiff(seq_len(nrow(invalid_tbl)))

  if (length(invalid_combo_rows) > 0L) {
    invalid_combs_msg <- cli::format_inline(
      "Additionally {cli::qty(length(invalid_combo_rows))} row{?s} with invalid
      combinations of valid values detected."
    )
  } else {
    invalid_combs_msg <- NULL
  }
  paste(
    paste(invalid_vals_msg, invalid_combs_msg, collapse = " | "),
    cli::format_inline("See {.var error_tbl} for details.")
  )
}
# Utils ----
target_cols_to_validate <- function(target_tbl, config_tasks) {
  c(
    task_id_cols_to_validate(target_tbl, config_tasks),
    output_type_cols_to_validate(target_tbl)
  )
}

task_id_cols_to_validate <- function(target_tbl, config_tasks) {
  intersect(
    colnames(target_tbl),
    hubUtils::get_task_id_names(config_tasks)
  )
}
output_type_cols_to_validate <- function(target_tbl) {
  intersect(
    colnames(target_tbl),
    hubUtils::std_colnames[c("output_type", "output_type_id")]
  )
}

has_output_types <- function(target_tbl) {
  hubUtils::std_colnames["output_type"] %in% colnames(target_tbl)
}

has_task_ids <- function(target_tbl, config_tasks) {
  any(hubUtils::get_task_id_names(config_tasks) %in% colnames(target_tbl))
}

has_conf_cols <- function(target_tbl, config_tasks) {
  length(target_cols_to_validate(target_tbl, config_tasks)) > 0L
}
