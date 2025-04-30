#' Check that a target data file has the correct column names according to
#' target type
#'
#' @param target_tbl A tibble/data.frame of the contents of the target data file
#' being validated.
#' @inheritParams check_target_file_name
#' @inherit check_tbl_colnames params return
#' @inheritParams hubData::get_target_path
#' @export
check_target_tbl_colnames <- function(target_tbl, target_type = c(
                                        "time-series", "oracle-output"
                                      ), file_path, hub_path) {
  target_type <- rlang::arg_match(target_type)
  col_names <- colnames(target_tbl)
  config_tasks <- read_config(hub_path)
  task_ids <- hubUtils::get_task_id_names(config_tasks)

  details <- NULL

  required <- switch(target_type,
    `time-series` = c(
      "observation",
      get_target_task_id(config_tasks)
    ),
    `oracle-output` = c(
      "oracle_value",
      get_target_task_id(config_tasks),
      # output_type and output_type_id are only required for "cdf" and "pmf"
      # output types.
      if (any(unique(target_tbl[["output_type"]]) %in% c("cdf", "pmf"))) {
        hubUtils::std_colnames[c("output_type", "output_type_id")]
      } else {
        NULL
      }
    )
  )
  missing_cols <- setdiff(required, col_names)
  check_missing <- length(missing_cols) == 0L
  if (!check_missing) {
    details <- c(
      details,
      cli::format_inline(
        "Required column{?s} {.val {missing_cols}} {?is/are} missing."
      )
    )
  }

  invalid_cols <- switch(target_type,
    `time-series` = {
      # Time series is more lenient as it allows additional columns.
      # So we check against invalid columns.
      invalid <- c(
        "value",
        "output_type",
        "output_type_id",
        "oracle_value"
      )
      intersect(col_names, invalid)
    },
    `oracle-output` = {
      # Oracle output is stricter as no additional columns are allowed.
      # Columns must be a subset of valid task IDs and optionally
      valid <- c(
        required,
        hubUtils::std_colnames[c("output_type", "output_type_id")],
        task_ids
      ) |>
        unique()
      setdiff(col_names, valid)
    }
  )
  check_invalid <- length(invalid_cols) == 0L
  if (!check_invalid) {
    details <- c(
      details,
      cli::format_inline(
        "Invalid column{?s} {.val {invalid_cols}} detected."
      )
    )
  }

  check <- check_missing && check_invalid

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Column names",
    msg_attribute = cli::format_inline(
      "consistent with expected column names for {.field {target_type}} target type data."
    ),
    msg_verbs = c("are", "must be"),
    details = details,
    error = TRUE
  )
}
