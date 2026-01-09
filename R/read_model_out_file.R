#' Read a model output file
#'
#' @inheritParams check_valid_round_id
#' @inheritParams hubData::create_hub_schema
#' @param coerce_types character. What to coerce column types to on read.
#' - `hub`: (default) read in (`csv`) or coerce (`parquet`, `arrow`) to hub
#'  schema.
#' When coercing data types using the `hub` schema, the `output_type_id_datatype`
#' can also be used to set the `output_type_id` column data type manually.
#' - `chr`: read in (`csv`) or coerce (`parquet`, `arrow`) all columns to character.
#' - `none`: No coercion. Use `arrow` `read_*` function defaults.
#' @return a tibble of contents of the model output file.
#' @export
read_model_out_file <- function(
  file_path,
  hub_path = ".",
  coerce_types = c("hub", "chr", "none"),
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  )
) {
  coerce_types <- rlang::arg_match(coerce_types)
  full_path <- abs_file_path(file_path, hub_path)
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)

  if (!fs::file_exists(full_path)) {
    rel_path <- rel_file_path(file_path, hub_path) # nolint: object_usage_linter
    cli::cli_abort("No file exists at path {.path {rel_path}}")
  }

  file_ext <- fs::path_ext(file_path)

  if (!file_ext %in% valid_ext) {
    cli::cli_abort(
      "File cannot be read. File extension must be one of
                   {.val {valid_ext}} not {.val {file_ext}}"
    )
  }

  tbl <- switch(
    file_ext,
    csv = {
      schema <- NULL
      coerce_on_read <- ifelse(coerce_types == "none", FALSE, TRUE)
      if (coerce_on_read) {
        schema <- create_model_out_schema(
          hub_path,
          col_types = coerce_types,
          output_type_id_datatype = output_type_id_datatype
        )
      }
      arrow::read_csv_arrow(
        full_path,
        col_types = schema
      )
    },
    parquet = {
      if (coerce_types == "hub") {
        arrow::read_parquet(full_path) |>
          coerce_to_hub_schema(
            config_tasks = read_config(hub_path, "tasks"),
            output_type_id_datatype = output_type_id_datatype
          )
      } else if (coerce_types == "chr") {
        arrow::read_parquet(full_path) |>
          hubData::coerce_to_character()
      } else {
        arrow::read_parquet(full_path)
      }
    },
    arrow = {
      if (coerce_types == "hub") {
        arrow::read_feather(full_path) |>
          coerce_to_hub_schema(
            config_tasks = read_config(hub_path, "tasks"),
            output_type_id_datatype = output_type_id_datatype
          )
      } else if (coerce_types == "chr") {
        arrow::read_feather(full_path) |>
          hubData::coerce_to_character()
      } else {
        arrow::read_feather(full_path)
      }
    }
  )
  tibble::as_tibble(tbl)
}

create_model_out_schema <- function(
  hub_path,
  col_types = c("hub", "chr"),
  output_type_id_datatype = c(
    "from_config",
    "auto",
    "character",
    "double",
    "integer",
    "logical",
    "Date"
  )
) {
  col_types <- rlang::arg_match(col_types)
  schema <- create_hub_schema(
    config_tasks = read_config(hub_path, "tasks"),
    partitions = NULL,
    output_type_id_datatype = output_type_id_datatype
  )

  switch(col_types, hub = schema, chr = {
    purrr::map(
      names(schema),
      ~ arrow::field(.x, type = arrow::utf8())
    ) |>
      arrow::schema()
  })
}
