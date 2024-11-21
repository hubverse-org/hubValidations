#' Check output type values of model output data against config
#'
#' Checks that values in the `value` column of a tibble/data.frame of data read
#' in from the file being validated conform to the configuration for each output
#' type of the appropriate model task.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @inheritParams expand_model_out_grid
#' @export
check_tbl_value_col <- function(tbl, round_id, file_path, hub_path,
                                derived_task_ids = get_derived_task_ids(hub_path, round_id)) {
  config_tasks <- read_config(hub_path, "tasks")

  tbl[, names(tbl) != "value"] <- hubData::coerce_to_character(
    tbl[, names(tbl) != "value"]
  )
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }

  details <- split(tbl, f = tbl$output_type) %>%
    purrr::imap(
      \(.x, .y) {
        check_value_col_by_output_type(
          tbl = .x, output_type = .y,
          config_tasks = config_tasks,
          round_id = round_id,
          derived_task_ids = derived_task_ids
        )
      }
    ) %>%
    unlist(use.names = TRUE)

  check <- is.null(details)

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Values in column {.var value}",
    msg_verbs = c("all", "are not all"),
    msg_attribute = "valid with respect to modeling task config.",
    details = details
  )
}

check_value_col_by_output_type <- function(tbl, output_type,
                                           config_tasks, round_id,
                                           derived_task_ids = NULL) {
  purrr::map2(
    .x = match_tbl_to_model_task(tbl, config_tasks,
      round_id, output_type,
      derived_task_ids = derived_task_ids
    ),
    .y = get_round_output_types(config_tasks, round_id),
    \(.x, .y) {
      compare_values_to_config(
        tbl = .x, output_type_config = .y, output_type = output_type
      )
    }
  ) %>%
    unlist(use.names = TRUE)
}

compare_values_to_config <- function(tbl, output_type, output_type_config) {
  if (any(is.null(tbl), is.null(output_type_config))) {
    return(NULL)
  }
  details <- NULL
  values <- tbl$value
  config <- output_type_config[[output_type]][["value"]]

  # Check and coerce value data type
  values_type <- config$type
  values <- coerce_values(values, values_type)
  if (any(is.na(values))) {
    invalid_vals <- tbl$value[is.na(values)] # nolint: object_usage_linter
    details <- c(
      details,
      cli::format_inline(
        "{cli::qty(length(invalid_vals))} Value{?s} {.val {invalid_vals}}
        cannot be coerced to expected data type {.val {values_type}}
        for output type {.val {output_type}}."
      )
    )
    values <- stats::na.omit(values)
    if (length(values) == 0L) {
      return(details)
    }
  }

  invalid_int <- detect_invalid_int(
    original_values = tbl$value,
    coerced_values = values
  )
  if (invalid_int$check) {
    details <- c(
      details,
      cli::format_inline(
        "{cli::qty(length(invalid_int$vals))} Value{?s} {.val {invalid_int$vals}}
        cannot be coerced to expected data type
        {.val {values_type}} for output type {.val {output_type}}."
      )
    )
  }

  if (any(names(config) == "maximum")) {
    value_max <- config[["maximum"]]
    is_invalid <- values > value_max
    if (any(is_invalid)) {
      details <- c(
        details,
        cli::format_inline(
          "{cli::qty(sum(is_invalid))} Value{?s} {.val {unique(values[is_invalid])}}
                {cli::qty(sum(is_invalid))}{?is/are}
                greater than allowed maximum value {.val {value_max}} for output type
          {.val {output_type}}."
        )
      )
    }
  }
  if (any(names(config) == "minimum")) {
    value_min <- config[["minimum"]]
    is_invalid <- values < value_min
    if (any(is_invalid)) {
      details <- c(
        details,
        cli::format_inline(
          "{cli::qty(sum(is_invalid))} Value{?s} {.val {unique(values[is_invalid])}}
                {cli::qty(sum(is_invalid))}{?is/are}
                smaller than allowed minimum value {.val {value_min}} for output type
          {.val {output_type}}."
        )
      )
    }
  }
  details
}

coerce_values <- function(values, type) {
  coerce_fn <- get(paste("as", type, sep = "."))
  suppressWarnings(coerce_fn(values))
}

detect_invalid_int <- function(original_values, coerced_values) {
  if (!is.integer(coerced_values)) {
    return(list(check = FALSE, vals = NULL))
  }
  if (!is.null(attr(coerced_values, "na.action"))) {
    original_values <- original_values[-attr(coerced_values, "na.action")]
  }

  compare <- as.numeric(original_values) - coerced_values
  invalid_int <- compare > 0L

  if (any(invalid_int)) {
    return(
      list(
        check = TRUE,
        vals = original_values[invalid_int]
      )
    )
  } else {
    return(list(check = FALSE, vals = NULL))
  }
}
