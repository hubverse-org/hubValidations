#' Check that task ID columns in a target data file have valid task ID values
#'
#' @param target_tbl A tibble/data.frame of the contents of the target data file
#' being validated.
#' @inheritParams check_target_file_name
#' @inheritParams check_target_tbl_colnames
#' @inherit check_tbl_colnames params return
#' @inheritParams hubData::get_target_path
#' @export
check_target_tbl_values <- function(target_tbl,
                                    target_type = c(
                                      "time-series", "oracle-output"
                                    ),
                                    file_path, hub_path) {
  target_type <- rlang::arg_match(target_type)
  config_tasks <- read_config(hub_path)
  task_ids <- hubUtils::get_task_id_names(config_tasks)

  details <- NULL

  valid_tbl <- expand_target_data_vals(config_tasks, target_tbl)
  by <- intersect(
    colnames(target_tbl),
    c(task_ids, "output_type", "output_type_id")
  )
  # If no valid config values are found to overlap with target_tbl, it means the
  # entire target_tbl is invalid.
  if (nrow(valid_tbl) == 0L) {
    invalid_tbl <- target_tbl
    valid_tbl <- extract_target_data_vals(config_tasks, target_tbl,
      collapse = TRUE,
      intersect = FALSE
    )
  } else {
    # Otherwise any rows in target_tbl that do not match valid_tbl are considered
    # invalid
    invalid_tbl <- dplyr::anti_join(
      target_tbl,
      valid_tbl,
      by = by
    )
  }

  check <- nrow(invalid_tbl) == 0L

  if (!check) {
    details <- c(
      details,
      summarise_invalid_target_values(valid_tbl, invalid_tbl)
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline("{.var target_tbl}"),
    msg_attribute = "",
    msg_verbs = c(
      "contains valid values/value combinations.",
      "contains invalid values/value combinations."
    ),
    error_tbl = invalid_tbl,
    details = details,
    error = TRUE
  )
}

#' Expand target values from hub configuration
#'
#' Expand and rbind all combinations of valid config values for all rounds and
#' modeling tasks that intersect with values in a `target_tbl`.
#'
#' Used internally to determine all valid target combinations for downstream checks.
#'
#' @param config_tasks A list of modeling rounds, typically taken from the
#' `"tasks"` section of a hub configuration.
#' @param target_tbl A tibble of target data.
#' @param intersect If `TRUE`, only returns values that intersect with `target_tbl`.
#'
#' @return A tibble containing all valid combinations of
#' task ID/output_type/output_type_id values present
#' in both the hub configuration and `target_tbl`.
expand_target_data_vals <- function(config_tasks, target_tbl, intersect = TRUE) {
  extract_target_data_vals(config_tasks, target_tbl, intersect = intersect) |>
    purrr::map(~ expand.grid(.x, stringsAsFactors = FALSE)) |>
    purrr::list_rbind()
}

#' Extract target data values for all rounds and tasks
#'
#' Extracts all valid config values for each model task in each round,
#' returning a list of value sets present in `target_tbl`.
#' Optionally collapses across rounds and tasks to produce unique values for each column.
#'
#' Used internally by `expand_target_data_vals()`.
#'
#' @param config_tasks A list of modeling rounds, typically taken from the
#' `"tasks"` section of a hub configuration.
#' @param target_tbl A tibble of target data, with columns corresponding to task IDs/output types.
#' @param collapse If `TRUE`, returns a single collapsed list of unique values
#' for each relevant column.
#' @param intersect If `TRUE`, only returns values that intersect with value
#' in `target_tbl`.
#'
#' @return A list of value sets for each model task, or a collapsed list of
#' unique values if `collapse = TRUE`.
#' @noRd
extract_target_data_vals <- function(config_tasks, target_tbl, collapse = FALSE,
                                intersect = TRUE) {
  out <- config_tasks[["rounds"]] |>
    purrr::map(~ extract_round_vals(.x, target_tbl, intersect)) |>
    purrr::list_flatten()

  if (collapse) {
    out <- out |>
      # This turns the flattened list of model_task values inside out so that at
      # the top level are elements for each column name, and at the second level
      # are vectors of the values for each model task.
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
#' returning lists of valid value sets present in `target_tbl`, one for each model
#æ task in the round.
#'
#' Used internally by `extract_target_data_vals()`.
#'
#' @param round_config A list describing a single round's model tasks (from
#' hub configuration).
#' @param target_tbl A tibble of target data, with columns corresponding to
#æ task IDs/output types.
#' @param intersect If `TRUE`, only returns values that intersect with `target_tbl`.
#'
#' @return A list of value combinations for each model task in the round.
#' @noRd
extract_round_vals <- function(round_config, target_tbl, intersect = TRUE) {
  purrr::map(
    round_config[["model_tasks"]],
    ~ extract_model_task_vals(.x, target_tbl, intersect)
  ) |>
    unique() |>
    purrr::compact()
}

#' Extract intersecting config valid values for a model task
#'
#' Extracts valid config values for a given model task, based on
#' values present in `target_tbl`.
#'
#' Returns `NULL` if no valid combination exists, i.e. when any of
#' the task IDs or output types (if applicable) have no intersecting values with
#' the `target_tbl` values.
#'
#' Used internally by `extract_round_vals()`.
#'
#' @param model_task A single model task configuration (from hub config).
#' @param target_tbl A tibble of target data, with columns corresponding to task IDs.
#' @param intersect If `TRUE`, only returns values that intersect with `target_tbl`.
#'
#' @return A named list of valid task ID/output_type/output_type_id values for
#' the model task, or `NULL` if no intersection is found.
extract_model_task_vals <- function(model_task, target_tbl, intersect = TRUE) {
  # Extracts the values for the task IDs from the target_tbl
  # and returns a named list of model task task ID values that intersect with
  # table values.
  task_id_target_cols <- intersect(
    colnames(target_tbl), names(model_task[["task_ids"]])
  )
  if (length(task_id_target_cols) == 0L) {
    return(NULL)
  }

  target_task_id_vals <- target_tbl[task_id_target_cols] |>
    purrr::map(~ unique(.x))

  config_task_id_vals <- null_taskids_to_na(
    model_task[["task_ids"]]
  )[task_id_target_cols] |>
    purrr::modify_depth(.depth = 1, ~ unlist(.x, use.names = FALSE))

  if (intersect) {
    vals <- purrr::map2(
      target_task_id_vals,
      config_task_id_vals,
      ~ intersect(.x, .y)
    )
  } else {
    vals <- config_task_id_vals
  }

  if (any(lengths(vals) == 0L) && !intersect) {
    return(NULL)
  }

  vals
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
    invalid_tbl[, names(unique_valid)],
    unique_valid,
    ~ setdiff(.x, .y)
  ) %>%
    purrr::compact()

  if (length(invalid_vals) != 0L) {
    invalid_vals_msg <- purrr::imap_chr(
      invalid_vals,
      ~ cli::format_inline(
        "Column {.var {.y}} contains invalid {cli::qty(length(.x))}
        value{?s} {.val {.x}}"
      )
    ) %>%
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
    setdiff(seq(nrow(invalid_tbl)))

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

