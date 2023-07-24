read_model_out_file <- function(file_path) {
  if (!fs::file_exists(file_path)) {
    cli::cli_abort("No file exists at path {.path {file_path}}")
  }

  file_ext <- rlang::arg_match(
    fs::path_ext(file_path),
    values = c("csv", "parquet", "arrow")
  )
  switch(file_ext,
    csv = arrow::read_csv_arrow(file_path),
    parquet = arrow::read_parquet(file_path),
    arrow = arrow::read_feather(file_path)
  )
}
