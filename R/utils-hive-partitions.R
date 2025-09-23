#' Extract and coerce Hive-style partition values as a tibble
#'
#' This function extracts Hive-style partition key-value pairs from a file or
#' directory path, and coerces them into a tibble using the provided Arrow schema.
#' This is useful when you want to interpret partition metadata with consistent
#' data types (e.g., integer, boolean, date).
#'
#' The function checks that all extracted partition keys are defined in the provided schema.
#' If any are missing, it aborts with an informative error.
#'
#' @inheritParams extract_hive_partitions
#' @param schema An [`arrow::schema`] object that includes definitions for the partition
#'   columns. All extracted keys must be present in the schema.
#'
#' @return A single-row tibble with the partition keys as columns, and values coerced
#'   to types defined in the schema. Returns `NULL` if no valid partitions are found.
#'
#' @examples
#' schema <- arrow::schema(country = arrow::utf8(), year = arrow::int32())
#' extract_partition_df("data/country=US/year=2024/file.parquet", schema)
#' @seealso [extract_hive_partitions()], [is_hive_partitioned_path()]
#' @noRd
extract_partition_df <- function(path, schema = NULL, strict = TRUE) {
  if (!is_hive_partitioned_path(path, strict = strict)) {
    return(NULL)
  }
  parts <- extract_hive_partitions(path, strict = strict)

  # Manually coerce all values according to schema types
  if (!is.null(schema)) {
    # check that schema has file types for all the partition keys
    missing_keys <- setdiff(names(parts), names(schema))
    if (length(missing_keys) > 0L) {
      cli::cli_abort(c(
        "x" = "Partition key{?s} {.val {missing_keys}} missing in {.arg schema}."
      ))
    }
    parts <- purrr::imap(
      parts,
      function(val, key) {
        type <- schema[[key]]$type$ToString()

        switch(
          type,
          "string" = as.character(val),
          "int32" = as.integer(val),
          "int64" = as.integer(val),
          "float" = as.double(val),
          "double" = as.double(val),
          "boolean" = as.logical(val),
          "date32[day]" = as.Date(val),
          cli::cli_abort(c(
            "x" = "Unsupported Arrow type {.val {type}} for key {.val {key}}."
          ))
        )
      }
    )
  }

  tibble::as_tibble_row(parts)
}
