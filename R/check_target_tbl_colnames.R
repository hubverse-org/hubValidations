#' Check that a target data file has the correct column names according to
#' target type
#'
#' @details
#' Column name validation depends on whether a `target-data.json` configuration
#' file is provided:
#'
#' **With `target-data.json` config:**
#' Expected columns are determined directly from the configuration. The target
#' table must contain exactly the columns defined in the config.
#'
#' **Without `target-data.json` config:**
#' Expected columns are inferred from the task ID configuration in `tasks.json`,
#' allowed columns according to the target type, and expectations based on the
#' detected output types in the target data. Additional optional columns
#' (e.g., `as_of`) are allowed.
#'
#' @param target_tbl A tibble/data.frame of the contents of the target data file
#' being validated.
#' @param config_target_data Optional. A `target-data.json` config object. If
#' provided, validation uses deterministic schema from config. If `NULL`
#' (default), validation uses inference from `tasks.json`.
#' @inheritParams check_target_file_name
#' @inherit check_tbl_colnames params return
#' @inheritParams hubData::get_target_path
#' @export
check_target_tbl_colnames <- function(
  target_tbl,
  target_type = c(
    "time-series",
    "oracle-output"
  ),
  file_path,
  hub_path,
  config_target_data = NULL
) {
  target_type <- rlang::arg_match(target_type)
  col_names <- colnames(target_tbl)
  details <- NULL

  # Config-based validation: exact column match required
  if (!is.null(config_target_data)) {
    expected_cols <- hubData::get_target_data_colnames(
      config_target_data,
      target_type
    )

    # Check for exact match using setequal
    check <- setequal(col_names, expected_cols)

    if (!check) {
      missing_cols <- setdiff(expected_cols, col_names)
      extra_cols <- setdiff(col_names, expected_cols)

      if (length(missing_cols) > 0L) {
        details <- c(
          details,
          cli::format_inline(
            "Required column{?s} {.val {missing_cols}} defined in {.file target-data.json} {?is/are} missing."
          )
        )
      }

      if (length(extra_cols) > 0L) {
        details <- c(
          details,
          cli::format_inline(
            "Extra column{?s} {.val {extra_cols}} detected that {?is/are} not defined in {.file target-data.json}."
          )
        )
      }
    }
  } else {
    # Inference mode: use existing validation logic
    config_tasks <- read_config(hub_path)
    task_ids <- hubUtils::get_task_id_names(config_tasks)

    required <- switch(
      target_type,
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

    if (target_type == "time-series") {
      has_as_of_col <- "as_of" %in% col_names
      req_col_n <- length(required) + 1L + has_as_of_col
      check_col_n <- ncol(target_tbl) >= req_col_n
      if (!check_col_n) {
        details <- c(
          details,
          cli::format_inline(
            "Fewer columns ({.val {ncol(target_tbl)}}) than the required number of
            columns ({.val {req_col_n}}) detected."
          )
        )
      }
    } else {
      check_col_n <- TRUE
    }

    invalid_cols <- switch(
      target_type,
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

    check <- check_missing && check_invalid && check_col_n
  }

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
