#' Read a model output file
#'
#' @inheritParams check_valid_round_id
#' @param coerce_types character. What to coerce column types to on read.
#' - `hub`: read in (`csv`) or coerce (`parquet`, `arrow`) to hub schema.
#' - `chr`: read in (`csv`) or coerce (`parquet`, `arrow`) all columns to character.
#' - `none`: No coercion. Use `arrow` `read_*` function defaults.
#' @return a tibble of contents of the model output file.
#' @export
read_model_out_file <- function(file_path, hub_path = ".",
                                coerce_types = c("hub", "chr", "none")) {
  coerce_types <- rlang::arg_match(coerce_types)
  full_path <- abs_file_path(file_path, hub_path)

  if (!fs::file_exists(full_path)) {
    rel_path <- rel_file_path(file_path, hub_path) # nolint: object_usage_linter
    cli::cli_abort("No file exists at path {.path {rel_path}}")
  }

  file_ext <- fs::path_ext(file_path)

  if (!file_ext %in% valid_ext) {
    cli::cli_abort("File cannot be read. File extension must be one of
                   {.val {valid_ext}} not {.val {file_ext}}")
  }

  tbl <- switch(file_ext,
    csv = {
      schema <- NULL
      coerce_on_read <- ifelse(coerce_types == "none", FALSE, TRUE)
      if (coerce_on_read) {
        schema <- create_model_out_schema(
          hub_path,
          col_types = coerce_types
        )
      }
      arrow::read_csv_arrow(
        full_path,
        col_types = schema
      )
    },
    parquet = {
      if (coerce_types == "hub") {
        arrow::read_parquet(full_path) %>%
          hubData::coerce_to_hub_schema(
            config_tasks = hubUtils::read_config(hub_path, "tasks")
          )
      } else if (coerce_types == "chr") {
        arrow::read_parquet(full_path) %>%
          hubData::coerce_to_character()
      } else {
        arrow::read_parquet(full_path)
      }
    },
    arrow = {
      if (coerce_types == "hub") {
        arrow::read_feather(full_path) %>%
          hubData::coerce_to_hub_schema(
            config_tasks = hubUtils::read_config(hub_path, "tasks")
          )
      } else if (coerce_types == "chr") {
        arrow::read_feather(full_path) %>%
          hubData::coerce_to_character()
      } else {
        arrow::read_feather(full_path)
      }
    }
  )
  tibble::as_tibble(tbl)
}

create_model_out_schema <- function(hub_path,
                                    col_types = c("hub", "chr")) {
  col_types <- rlang::arg_match(col_types)
  schema <- hubData::create_hub_schema(
    config_tasks = hubUtils::read_config(hub_path, "tasks"),
    partitions = NULL
  )

  switch(col_types,
    hub = schema,
    chr = {
      purrr::map(
        names(schema),
        ~ arrow::field(.x, type = arrow::utf8())
      ) %>%
        arrow::schema()
    }
  )
}
