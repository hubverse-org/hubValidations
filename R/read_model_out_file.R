#' Check file can be read successfully
#'
#' @inheritParams check_valid_round_id
#' @return a tibble of contents of the model output file.
#' @export
read_model_out_file <- function(file_path, hub_path = ".") {
  full_path <- abs_file_path(file_path, hub_path)

  if (!fs::file_exists(full_path)) {
    rel_path <- rel_file_path(file_path, hub_path)
    cli::cli_abort("No file exists at path {.path {rel_path}}")
  }

  file_ext <- fs::path_ext(file_path)

  if (!file_ext %in% valid_ext) {
    cli::cli_abort("File cannot be read. File extension must be one of
                   {.val {valid_ext}} not {.val {file_ext}}")
  }

  switch(file_ext,
    csv = arrow::read_csv_arrow(
      full_path,
      col_types = hubUtils::create_hub_schema(
        config_tasks = hubUtils::read_config(hub_path, "tasks"),
        partitions = NULL
      )
    ),
    parquet = arrow::read_parquet(full_path),
    arrow = arrow::read_feather(full_path)
  )
}
