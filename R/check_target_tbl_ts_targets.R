#' Check that targets in a time-series target data file are valid
#'
#' Check is only performed when the target data type is `time-series`.
#' When the target task ID is not specified in the config (i.e. hub has single
#' target and `target_keys = NULL`), the validity of the target is only checked
#' through the config file. Otherwise, the values in the target task ID column
#' of `target_tbl` are checked. Note that valid `time-series` targets must be
#' step ahead and their target type must be one of `"continuous"`, `"discrete"`,
#' `"binary"` or `"compositional"`. If the hub contains no valid time-series
#' targets, no time-series target data should be present and validation of
#' such data will be skipped.
#' @param target_tbl A tibble/data.frame of the contents of the target data file
#' being validated.
#' @inheritParams check_target_file_name
#' @inheritParams check_target_tbl_colnames
#' @inherit check_tbl_colnames params return
#' @inheritParams hubData::get_target_path
#' @export
check_target_tbl_ts_targets <- function(target_tbl,
                                        target_type = c(
                                          "time-series", "oracle-output"
                                        ),
                                        file_path, hub_path) {
  target_type <- rlang::arg_match(target_type)
  if (target_type == "oracle-output") {
    return(
      capture_check_info(
        file_path,
        msg = "Check not applicable to {.field oracle-output} target data. Skipped."
      )
    )
  }
  config_tasks <- read_config(hub_path)
  target_task_id <- get_target_task_id(config_tasks)

  # Return error condition if target_task_id is not present in target_tbl.
  if (!is.null(target_task_id) && !target_task_id %in% colnames(target_tbl)) {
    details <- cli::format_inline(
      "Target task ID column {.val {target_task_id}} not present in {.var target_tbl}."
    )
    return(
      capture_check_cnd(
        check = FALSE,
        file_path = file_path,
        msg_subject = cli::format_inline("{.field time-series} targets"),
        msg_attribute = "could not be validated.",
        msg_verbs = c("", ""),
        details = details,
        error = TRUE
      )
    )
  }

  target_metadata <- unique(get_target_metadata(config_tasks))
  ts_targets <- target_metadata |>
    purrr::set_names(get_target_ids(target_metadata)) |>
    purrr::map_lgl(is_ts_target)
  valid_ts_targets <- ts_targets[ts_targets]

  if (is.null(target_task_id)) {
    # If hub has a single target that is implied (i.e. not explicitly included
    # in data), validate the target from the target metadata.
    check <- isTRUE(valid_ts_targets)
    invalid_targets <- names(ts_targets)
  } else {
    # Otherwise, validate that the target task ID contains only valid targets.
    invalid_targets <- setdiff(
      unique(target_tbl[[target_task_id]]),
      names(valid_ts_targets)
    )
    check <- length(invalid_targets) == 0L
  }

  details <- NULL

  if (!check) {
    if (!is.null(target_task_id)) {
      details <- cli::format_inline(
        "{.var target_tbl} column {.val {target_task_id}} contains data for  invalid target{?s}
        {.val {invalid_targets}}."
      )
      if (length(invalid_targets) == length(ts_targets)) {
        details <- paste(
          details,
          cli::format_inline(
            "All targets in {.var target_tbl} are invalid. Time-series target data not appropriate."
          )
        )
      }
    } else {
      details <- cli::format_inline(
        "Global target {.val {invalid_targets}} inferred from hub config is invalid. Time-series target data not appropriate."
      )
    }
    valid_target_types <- c("continuous", "discrete", "binary", "compositional") # nolint: object_usage_linter
    details <- paste(
      details,
      cli::format_inline(
        "Valid {.field time-series} targets must be step-ahead and their target type
      must be one of {.val {valid_target_types}}."
      )
    )
  }
  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline("{.field time-series} {cli::qty(length(ts_targets))} target{?s}"),
    msg_attribute = "",
    msg_verbs = c(
      cli::format_inline("{cli::qty(length(ts_targets))} {?is/are} {?all }valid."),
      cli::format_inline("{cli::qty(length(ts_targets))} {?is/are} not {?all }valid.")
    ),
    details = details,
    error = TRUE
  )
}

# Check whether a target_metadata item is a valid time-series target
is_ts_target <- function(x) {
  valid_target_types <- c("continuous", "discrete", "binary", "compositional")
  out <- x$is_step_ahead && x$target_type %in% valid_target_types

  purrr::set_names(out, x$target_id)
}
