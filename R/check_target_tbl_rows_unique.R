#' Check target data rows are all unique
#'
#' Check that there are no duplicate rows in target data files being validated.
#'
#' @details
#' Row uniqueness is determined by checking for duplicate combinations of
#' key columns (excluding value columns).
#'
#' **With `target-data.json` config:**
#' Columns to check are determined from the config's `observable_unit`
#' specification. For `oracle-output` data with output type IDs, the
#' `output_type` and `output_type_id` columns are also included in the
#' uniqueness check.
#'
#' **Without `target-data.json` config:**
#' For `time-series` data, if versioned, multiple observations are allowed
#' so long as they have different `as_of` values. The `as_of` column is
#' therefore included when determining duplicates.
#' For `oracle-output` data, there should be only a single observation,
#' regardless of the `as_of` value, so the column is not included when
#' determining duplicates.
#' @inheritParams check_target_tbl_colnames
#' @inherit check_tbl_col_types return
#' @export
check_target_tbl_rows_unique <- function(
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

  # Determine columns to check for uniqueness
  if (!is.null(config_target_data)) {
    # Config mode: use observable unit from config
    check_cols <- get_obs_unit_from_config(
      config_target_data,
      target_type,
      include_as_of = target_type == "time-series"
    )
    # For oracle-output, include output_type columns if present
    if (
      target_type == "oracle-output" &&
        hubUtils::get_has_output_type_ids(config_target_data)
    ) {
      check_cols <- c(check_cols, "output_type", "output_type_id")
    }
  } else {
    # Inference mode: remove value columns and check remaining for duplicates
    cols_to_remove <- switch(
      target_type,
      `time-series` = "observation",
      `oracle-output` = c("oracle_value", "as_of")
    )
    # Only remove columns that actually exist
    cols_to_remove <- intersect(cols_to_remove, colnames(target_tbl))
    check_cols <- setdiff(colnames(target_tbl), cols_to_remove)
  }

  # Check for duplicates on the determined columns
  duplicates <- duplicated(target_tbl[, check_cols, drop = FALSE])
  check <- !any(duplicates)

  if (check) {
    details <- NULL
    duplicate_rows <- NULL
  } else {
    duplicate_rows <- which(duplicates)
    if (!is.null(config_target_data)) {
      details <- cli::format_inline(
        "Rows containing duplicate value combinations across columns defined in {.file target-data.json}: {.val {duplicate_rows}}" # nolint: line_length_linter
      )
    } else {
      details <- cli::format_inline(
        "Rows containing duplicate value combinations: {.val {duplicate_rows}}"
      )
    }
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "{.field {target_type}} target data rows"
    ),
    msg_attribute = "unique.",
    msg_verbs = c("are", "must be"),
    details = details,
    duplicate_rows = duplicate_rows
  )
}
