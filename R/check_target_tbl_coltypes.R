#' Check that a target data file has the correct column types according to
#' target type
#'
#' @details
#' Column type validation depends on whether a `target-data.json` configuration
#' file is provided:
#'
#' **With `target-data.json` config:**
#' Expected column types are determined directly from the schema defined in
#' the configuration. Validation is performed against the schema specifications
#' in `target-data.json`.
#'
#' **Without `target-data.json` config:**
#' Expected column types are determined from the dataset itself and validated
#' for internal consistency across files, which mainly applies to partitioned
#' datasets.
#'
#' @param target_tbl A tibble/data.frame of the contents of the target data file
#' being validated.
#' @inherit check_target_tbl_colnames params return
#' @inheritParams hubData::connect_target_oracle_output
#' @inheritParams hubData::connect_target_timeseries
#' @export
check_target_tbl_coltypes <- function(
  target_tbl,
  target_type = c(
    "time-series",
    "oracle-output"
  ),
  date_col = NULL,
  na = c("NA", ""),
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  ),
  file_path,
  hub_path
) {
  target_type <- rlang::arg_match(target_type)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)

  schema <- switch(
    target_type,
    `time-series` = hubData::create_timeseries_schema(
      hub_path = hub_path,
      date_col = date_col,
      na = na,
      r_schema = TRUE
    ),
    `oracle-output` = hubData::create_oracle_output_schema(
      hub_path = hub_path,
      na = na,
      r_schema = TRUE,
      output_type_id_datatype = output_type_id_datatype
    )
  )[colnames(target_tbl)]

  tbl_types <- purrr::map_chr(
    target_tbl,
    ~ if (inherits(.x, "numeric")) {
      typeof(.x)
    } else {
      paste(class(.x), collapse = "/")
    }
  )
  compare_types <- schema == tbl_types

  check <- all(compare_types)

  if (check) {
    details <- NULL
  } else {
    invalid_cols <- names(compare_types)[!compare_types]
    details <- paste0(
      "{.var ",
      invalid_cols,
      "} should be {.cls ",
      schema[invalid_cols],
      "} not {.cls ",
      tbl_types[invalid_cols],
      "}"
    ) %>%
      paste(collapse = ", ") %>%
      paste0(".") %>%
      cli::format_inline()
  }

  # Enhance message to reference config when available
  schema_source <- if (hubUtils::has_target_data_config(hub_path)) {
    "{target_type} target schema defined in `target-data.json` config."
  } else {
    "{target_type} target schema."
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Column data types",
    msg_attribute = cli::format_inline(schema_source),
    msg_verbs = c("match", "do not match"),
    details = details
  )
}
