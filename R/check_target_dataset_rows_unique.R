#' Check target dataset rows are all unique
#'
#' Check that there are no duplicate rows in a target dataset.
#' Function designed to be used as part of overall target data integrity check.
#'
#' @details
#' If datasets are versioned, multiple observations are allowed in `time-series`
#' target data, so long as they have different `as_of` values. The `as_of` column
#' is therefore included when determining duplicates.
#' In `oracle-output` data, there should be only a single observation,
#' regardless of the `as_of` value so the column it is not be included when
#' determining duplicates.
#' @param date_col Optional column name to be interpreted as date for dataset
#' connection. Useful when the date column does not correspond to a valid task ID
#' (e.g., calculated from other task IDs like `origin_date + horizon`), particularly when
#' it is also a partitioning column. Ignored when
#' `target-data.json` config is provided.
#' @inheritParams check_target_tbl_colnames
#' @inheritParams hubData::connect_target_timeseries
#' @inheritParams hubData::connect_target_oracle_output
#' @inherit check_tbl_col_types return
#' @importFrom dplyr group_by filter across select n summarise collect ungroup everything
#' @export
check_target_dataset_rows_unique <- function(
  target_type = c(
    "time-series",
    "oracle-output"
  ),
  na = c("NA", ""),
  date_col = NULL,
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  hub_path
) {
  target_type <- rlang::arg_match(target_type)

  ds <- switch(
    target_type,
    "time-series" = hubData::connect_target_timeseries(
      hub_path = hub_path,
      na = na,
      date_col = date_col
    ),
    "oracle-output" = hubData::connect_target_oracle_output(
      hub_path = hub_path,
      na = na,
      output_type_id_datatype = output_type_id_datatype
    )
  )

  unique_cols <- setdiff(
    colnames(ds),
    switch(
      target_type,
      "time-series" = "observation",
      "oracle-output" = c("oracle_value", "as_of")
    )
  )

  duplicate_df <- select(ds, !!!unique_cols) |>
    group_by(across(everything())) |>
    summarise(count = n()) |>
    filter(.data[["count"]] > 1) |>
    ungroup() |>
    collect()

  check <- nrow(duplicate_df) == 0L

  if (check) {
    details <- NULL
    duplicate_df <- NULL
  } else {
    details <- cli::format_inline(
      "Rows containing duplicate observations detected."
    )
  }

  file_path <- basename(
    hubData::get_target_path(hub_path, target_type)
  )
  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "{.field {target_type}} target dataset rows"
    ),
    msg_attribute = "unique.",
    msg_verbs = c("are", "must be"),
    details = details,
    duplicate_df = duplicate_df
  )
}
