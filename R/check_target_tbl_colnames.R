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
#' **Without `target-data.json` config (inference mode):**
#' Expected columns are inferred from the task ID configuration in `tasks.json`,
#' allowed columns according to the target type, and expectations based on the
#' detected output types in the target data. Additional optional columns
#' (e.g., `as_of`) are allowed for time-series data.
#'
#' **Note on date columns:** Target data always contains a date column (e.g.,
#' `target_end_date`) representing when observations occurred. However, in
#' horizon-based forecast hubs, task IDs may only define `origin_date`
#' and `horizon` (with target dates calculated from these). In such cases,
#' provide `date_col` to enable deterministic validation of the date column
#' when it is not a valid task ID. Validation of date column existence and
#' type is performed by `check_target_tbl_coltypes()`.
#'
#' Inference mode validation for time-series data is limited. For robust
#' validation, create a `target-data.json` config file. See 
#' [`target-data.json` schema](https://docs.hubverse.io/en/latest/user-guide/hub-config.html#hub-target-data-configuration-target-data-json-file) 
#' for more information on the json schema scpecifics.
#'
#' @param target_tbl A tibble/data.frame of the contents of the target data file
#' being validated.
#' @param config_target_data Optional. A `target-data.json` config object. If
#' provided, validation uses deterministic schema from config. If `NULL`
#' (default), validation uses inference from `tasks.json`.
#' @param date_col Optional. Name of the date column in target data (e.g.,
#' `"target_end_date"`) representing the date observations actually occurred.
#' Only relevant when it is not a task ID defined in `tasks.json`.
#' Enables deterministic validation in inference mode. Ignored when
#' `config_target_data` is provided.
#' @inheritParams check_target_file_name
#' @inherit check_tbl_colnames params return
#' @inheritParams hubData::get_target_path
#' @importFrom hubUtils get_task_id_names
#' @export
check_target_tbl_colnames <- function(
  target_tbl,
  target_type = c(
    "time-series",
    "oracle-output"
  ),
  file_path,
  hub_path,
  config_target_data = NULL,
  date_col = NULL
) {
  checkmate::assert_string(date_col, null.ok = TRUE)
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

    # Add date_col to required if provided (for horizon-based hubs)
    # Use unique() in case date_col is actually a task ID
    if (!is.null(date_col)) {
      required <- unique(c(required, date_col))
    }

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
      # Time series is more lenient as it allows additional columns.
      # So we check against invalid columns.
      invalid <- c(
        "value",
        "output_type",
        "output_type_id",
        "oracle_value"
      )
      invalid_cols <- intersect(col_names, invalid)
    } else {
      # oracle-output
      # Oracle output allows required columns, output_type/output_type_id,
      # task IDs, and as_of (for versioning)
      valid <- c(
        required,
        hubUtils::std_colnames[c("output_type", "output_type_id")],
        task_ids,
        "as_of" # Oracle output can be versioned
      ) |>
        unique()
      invalid_cols <- setdiff(col_names, valid)
    }

    check_invalid <- length(invalid_cols) == 0L
    if (!check_invalid) {
      details <- c(
        details,
        cli::format_inline(
          "Invalid column{?s} {.val {invalid_cols}} detected."
        )
      )
    }

    # Add inference mode limitation note for time-series
    if (target_type == "time-series") {
      details <- c(
        details,
        cli::format_inline(
          "Column name validation for time-series data in inference mode is
          limited. For robust validation, create a {.file target-data.json}
          config file. See {.href [`target-data.json` documentation](https://docs.hubverse.io/en/latest/user-guide/hub-config.html#hub-target-data-configuration-target-data-json-file)}"
        )
      )
    }

    check <- check_missing && check_invalid
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
