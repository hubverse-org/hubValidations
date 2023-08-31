#' Check output type values of model output data against config
#'
#' Checks that values in the `value` column of a tibble/data.frame of data read
#' in from the file being validated conform to the configuration for each output
#' type of the appropriate model task.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
check_tbl_value_col <- function(tbl, round_id, file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  tbl[, names(tbl) != "value"] <- hubUtils::coerce_to_character(
    tbl[, names(tbl) != "value"]
  )

  full <- hubUtils::expand_model_out_val_grid(
    config_tasks,
    round_id = round_id,
    required_vals_only = FALSE,
    all_character = TRUE,
    as_arrow_table = TRUE,
    bind_model_tasks = FALSE
  )

  join_cols <- names(tbl)[names(tbl) != "value"]
  tbl <- purrr::map(
    full,
    ~ dplyr::inner_join(.x, tbl, by = join_cols) %>%
      tibble::as_tibble()
  )

  round_config <- get_file_round_config(file_path, hub_path)
  output_type_config <- round_config[["model_tasks"]] %>%
    purrr::map(~ .x[["output_type"]])


  details <- purrr::map2(
    tbl, output_type_config,
    check_modeling_task_value_col
  ) %>%
    unlist(use.names = TRUE)

  check <- is.null(details)

  ## Example code for attempting bullets of details. Needs more experimentation
  ## but parking for now.
  # if (!check) {
  #     details_bullets_div <- function(details) {
  #         cli::cli_div()
  #         cli::format_bullets_raw(
  #             stats::setNames(details, rep("*", length(details)))
  #         )
  #     }
  #     details <- details_bullets_div(details)
  # }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Values in column {.var value}",
    msg_verbs = c("all", "are not all"),
    msg_attribute = "valid with respect to modeling task config.",
    details = details
  )
}


check_modeling_task_value_col <- function(tbl, output_type_config) {
  purrr::imap(
    split(tbl, tbl[["output_type"]]),
    ~ compare_values_to_config(
      tbl = .x, output_type = .y,
      output_type_config
    )
  ) %>%
    unlist(use.names = TRUE)
}

compare_values_to_config <- function(tbl, output_type, output_type_config) {
  details <- NULL
  values <- tbl$value
  config <- output_type_config[[output_type]][["value"]]

  # Check and coerce value data type
  values_type <- json_datatypes[config$type]
  values <- coerce_values(values, values_type)
  if (any(is.na(values))) {
    details <- c(
      details,
      cli::format_inline(
        "Contains values that cannot be coerced to
              expected data type {.val {values_type}} for output type {.val {output_type}}."
      )
    )
    values <- stats::na.omit(values)
    if (length(values) == 0L) {
      return(details)
    }
  }

  if (any(names(config) == "maximum")) {
    value_max <- config[["maximum"]]
    is_invalid <- values >= value_max
    if (any(is_invalid)) {
      details <- c(
        details,
        cli::format_inline(
          "{cli::qty(sum(is_invalid))} Value{?s} {.val {values[is_invalid]}}
                {cli::qty(sum(is_invalid))}{?is/are}
                greater than allowed maximum value {.val {value_max}} for output type
          {.val {output_type}}."
        )
      )
    }
  }
  if (any(names(config) == "minimum")) {
    value_min <- config[["minimum"]]
    is_invalid <- values <= value_min
    if (any(is_invalid)) {
      details <- c(
        details,
        cli::format_inline(
          "{cli::qty(sum(is_invalid))} Value{?s} {.val {values[is_invalid]}}
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
