#' Validate the contents of a submitted target data file.
#'
#' @param date_col Optional name of the column containing the date observations
#' actually occurred (e.g., `"target_end_date"`) to be interpreted as date.
#' Useful when this column does not correspond to a valid task ID (e.g.,
#' calculated from other task IDs like `origin_date + horizon`) for: (1) correct
#' schema creation, particularly when it's also a partitioning column, and (2)
#' more robust column name validation when `target-data.json` config does not
#' exist. Ignored when `target-data.json` exists.
#' @inheritParams check_target_tbl_values
#' @inherit validate_target_file params return
#' @inheritParams check_target_tbl_coltypes
#' @details
#'
#' Details of checks performed by `validate_target_data()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations"))  |>
#' dplyr::filter(.data$`parent fun` == "validate_target_data", !.data$optional)  |>
#'   dplyr::select(-"parent fun", -"check fun", -"optional")  |>
#'   dplyr::mutate("Extra info" = dplyr::case_when(
#'     is.na(.data$`Extra info`) ~ "",
#'     TRUE ~ .data$`Extra info`
#'   ))  |>
#'   knitr::kable()  |>
#'   kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive"))  |>
#'   kableExtra::column_spec(1, bold = TRUE)
#' ```
#' @examples
#' hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
#' validate_target_data(hub_path,
#'   file_path = "time-series.csv",
#'   target_type = "time-series"
#' )
#' validate_target_data(hub_path,
#'   file_path = "oracle-output.csv",
#'   target_type = "oracle-output"
#' )
#' hub_path <- system.file("testhubs/v5/target_dir", package = "hubUtils")
#' validate_target_data(hub_path,
#'   file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
#'   target_type = "time-series"
#' )
#' validate_target_data(hub_path,
#'   file_path = "oracle-output/output_type=pmf/part-0.parquet",
#'   target_type = "oracle-output"
#' )
#' @export
validate_target_data <- function(
  hub_path,
  file_path,
  target_type = c("time-series", "oracle-output"),
  date_col = NULL,
  allow_extra_dates = FALSE,
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
  validations_cfg_path = NULL,
  round_id = "default"
) {
  checkmate::assert_string(date_col, null.ok = TRUE)
  target_type <- rlang::arg_match(target_type)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)

  checks <- new_target_validations()

  # -- File parsing checks ----
  checks$target_file_read <- try_check(
    check_target_file_read(
      file_path = file_path,
      hub_path = hub_path
    ),
    file_path
  )
  if (is_any_error(checks$target_file_read)) {
    return(checks)
  }

  # If `csv` file, read in using hub schema. Otherwise use file
  # schema for other file formats.
  if (fs::path_ext(file_path) == "csv") {
    target_tbl <- read_target_file(
      target_file_path = file_path,
      hub_path = hub_path,
      coerce_types = "target"
    )
  } else {
    target_tbl <- read_target_file(
      target_file_path = file_path,
      hub_path = hub_path,
      coerce_types = "none"
    )
  }

  # Read target-data.json config if available (NULL if doesn't exist)
  config_target_data <- if (hubUtils::has_target_data_config(hub_path)) {
    hubUtils::read_config(hub_path, "target-data")
  } else {
    NULL
  }

  # When config exists, ignore user-provided date_col and use config value
  # (schema creation functions will extract it from config)
  if (!is.null(config_target_data)) {
    date_col <- NULL
  }

  # -- Standard checks ----
  checks$target_tbl_colnames <- try_check(
    check_target_tbl_colnames(
      target_tbl = target_tbl,
      target_type = target_type,
      file_path = file_path,
      hub_path = hub_path,
      config_target_data = config_target_data,
      date_col = date_col
    ),
    file_path
  )
  if (is_any_error(checks$target_tbl_colnames)) {
    return(checks)
  }
  checks$target_tbl_coltypes <- try_check(
    check_target_tbl_coltypes(
      target_tbl = target_tbl,
      target_type = target_type,
      date_col = date_col,
      na = na,
      output_type_id_datatype = output_type_id_datatype,
      file_path = file_path,
      hub_path = hub_path
    ),
    file_path
  )
  if (is_any_error(checks$target_tbl_coltypes)) {
    return(checks)
  }
  checks$target_tbl_ts_targets <- try_check(
    check_target_tbl_ts_targets(
      target_tbl = target_tbl,
      target_type = target_type,
      file_path = file_path,
      hub_path = hub_path
    ),
    file_path
  )
  if (is_any_error(checks$target_tbl_ts_targets)) {
    return(checks)
  }

  checks$target_tbl_rows_unique <- try_check(
    check_target_tbl_rows_unique(
      target_tbl = target_tbl,
      target_type = target_type,
      file_path = file_path,
      hub_path = hub_path,
      config_target_data = config_target_data
    ),
    file_path
  )

  target_tbl_chr <- hubData::coerce_to_character(target_tbl)

  checks$target_tbl_values <- try_check(
    check_target_tbl_values(
      target_tbl_chr = target_tbl_chr,
      target_type = target_type,
      file_path = file_path,
      hub_path = hub_path,
      date_col = date_col,
      allow_extra_dates = allow_extra_dates,
      config_target_data = config_target_data
    ),
    file_path
  )
  if (is_any_error(checks$target_tbl_values)) {
    return(checks)
  }

  # oracle-output specific checks
  checks$target_tbl_output_type_ids <- try_check(
    check_target_tbl_output_type_ids(
      target_tbl_chr = target_tbl_chr,
      target_type = target_type,
      file_path = file_path,
      hub_path = hub_path,
      config_target_data = config_target_data
    ),
    file_path
  )
  if (is_any_error(checks$target_tbl_output_type_ids)) {
    return(checks)
  }
  checks$target_tbl_oracle_value <- try_check(
    check_target_tbl_oracle_value(
      target_tbl = target_tbl,
      target_type = target_type,
      file_path = file_path,
      hub_path = hub_path,
      config_target_data = config_target_data
    ),
    file_path
  )

  custom_checks <- execute_custom_checks(
    validations_cfg_path = validations_cfg_path,
    subclass = "target_validations"
  )
  checks <- combine(checks, custom_checks)

  checks
}
