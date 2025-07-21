#' Read a single target data file
#'
#' @param target_file_path Character string. Path to the target data file being validated
#' relative to the hub's `target-data` directory.
#' @inheritParams hubData::connect_target_timeseries
#' @inheritParams read_model_out_file
#' @param coerce_types character string. What to coerce column types to on read.
#' - `hub`: (default) read in (`csv`) or coerce (`parquet`) to schema according to
#'  `hub` config (See [hubData::create_timeseries_schema()] and
#'  [hubData::create_oracle_output_schema()] for details).
#' When coercing data types using the `hub` schema, the `output_type_id_datatype`
#' can also be used to set the `output_type_id` column data type manually.
#' - `chr`: read in (`csv`) or coerce (`parquet`) all columns to character.
#' - `none`: No coercion. Use `arrow` `read_*` function defaults.
#'
#' @returns  a tibble of contents of the target data file.
#' @export
#'
#' @examplesIf requireNamespace("curl", quietly = TRUE) && curl::has_internet()
#' # download example hub
#' hub_path <- withr::local_tempdir()
#' example_hub <- "https://github.com/hubverse-org/example-complex-forecast-hub.git"
#' gert::git_clone(url = example_hub, path = hub_path)
#' # read in time-series file
#' read_target_file("time-series.csv", hub_path)
#' read_target_file("time-series.csv", hub_path, coerce_types = "chr")
#' # read in oracle-output file
#' read_target_file("oracle-output.csv", hub_path)
#' read_target_file("oracle-output.csv", hub_path, coerce_types = "chr")
read_target_file <- function(
  target_file_path,
  hub_path,
  coerce_types = c("target", "chr", "none"),
  date_col = NULL,
  na = c("NA", "")
) {
  checkmate::assert_character(target_file_path, len = 1)
  checkmate::assert_character(hub_path, len = 1)

  coerce_types <- rlang::arg_match(coerce_types)
  target_type <- guess_target_type_from_path(target_file_path)

  full_path <- abs_file_path(target_file_path, hub_path, subdir = "target-data")

  if (!fs::file_exists(full_path)) {
    # nolint start: object_usage_linter
    rel_path <- rel_file_path(
      target_file_path,
      hub_path,
      subdir = "target-data"
    )
    # nolint end
    cli::cli_abort("No file exists at path {.path {rel_path}}") # nolint: object_usage_linter
  }

  file_ext <- fs::path_ext(target_file_path)
  valid_ext <- c("csv", "parquet")
  if (!file_ext %in% valid_ext) {
    cli::cli_abort(
      "File cannot be read. File extension must be one of {.val {valid_ext}}, not {.val {file_ext}}"
    )
  }

  # Determine schema if coercion is required
  schema <- NULL
  if (coerce_types == "target") {
    schema <- switch(
      target_type,
      `time-series` = hubData::create_timeseries_schema(
        hub_path = hub_path,
        date_col = date_col,
        na = na
      ),
      `oracle-output` = hubData::create_oracle_output_schema(
        hub_path = hub_path,
        na = na
      )
    )
  }

  # Read file
  tbl <- switch(
    file_ext,
    csv = {
      out <- arrow::read_csv_arrow(full_path, col_types = schema)
      if (coerce_types == "chr") {
        out <- hubData::coerce_to_character(out)
      }
      out
    },
    parquet = {
      if (coerce_types == "target") {
        arrow::read_parquet(full_path, schema = schema)
      } else if (coerce_types == "chr") {
        arrow::read_parquet(full_path) |>
          hubData::coerce_to_character()
      } else {
        arrow::read_parquet(full_path)
      }
    }
  )

  # Convert to tibble
  tbl <- tibble::as_tibble(tbl)

  # Extract partition values and bind them
  partition_df <- extract_partition_df(
    target_file_path,
    schema,
    strict = TRUE
  )
  if (!is.null(partition_df)) {
    tbl <- dplyr::bind_cols(tbl, partition_df)
  }
  tbl
}

guess_target_type_from_path <- function(
  target_file_path,
  call = rlang::caller_env()
) {
  if (grepl("time-series", target_file_path)) {
    return("time-series")
  }
  if (grepl("oracle-output", target_file_path)) {
    return("oracle-output")
  }
  cli::cli_abort(
    c(
      x = "Could not determine target type of file.",
      i = "{.arg target_file_path} must contain either {.val time-series}
        or {.val oracle-output}"
    ),
    call = call
  )
}
