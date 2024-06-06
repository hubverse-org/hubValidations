#' Parse model output file metadata from file name
#'
#' @param file_path Character string. A model output file name.
#' Can include parent directories which are ignored.
#' @param file_type Character string. Type of file name being parsed. One of `"model_output"`
#' or `"model_metadata"`.
#' @details
#' File names are allowed to contain the following compression extension prefixes:
#' `r paste0(".", compress_codec)`.
#' These extension prefixes are removed before parsing the file name.
#'
#' @return A list with the following elements:
#'  - `round_id`: The round ID the model output is associated with (`NA` for
#'  model metadata files.)
#'  - `team_abbr`: The team responsible for the model.
#'  - `model_abbr`: The name of the model.
#'  - `model_id`: The unique model ID derived from the concatenation of
#'  `<team_abbr>-<model_abbr>`.
#'  - `ext`: The file extension.
#'  - `compression_ext`: optional. The compression extension if present.
#'
#' @export
#'
#' @examples
#' parse_file_name("hub-baseline/2022-10-15-hub-baseline.csv")
#' parse_file_name("hub-baseline/2022-10-15-hub-baseline.gzip.parquet")
parse_file_name <- function(file_path, file_type = c("model_output", "model_metadata")) {
  file_type <- rlang::arg_match(file_type)
  checkmate::assert_string(file_path)
  file_name <- tools::file_path_sans_ext(basename(file_path))

  split_pattern <- stringr::regex(
    "([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2})|[a-z_0-9]+",
    TRUE
  )
  compress_regex <- paste0(
    "\\.(",
    paste0(compress_codec, collapse = "|"),
    ")$"
  )
  split_res <- unlist(
    stringr::str_extract_all(
      # remove compression extension before splitting
      stringr::str_remove(file_name, compress_regex),
      split_pattern
    )
  )
  exp_n <- switch(file_type,
    model_output = 3L,
    model_metadata = 2L
  )
  if (length(split_res) != exp_n) {
    cli::cli_abort(
      "Could not parse file name {.path {file_name}} for submission metadata.
      Please consult documentation for file name requirements for correct
      metadata parsing."
    )
  }
  if (file_type == "model_metadata") {
    split_res <- c(NA, split_res)
  }
  # extract compression extension if present
  compression_ext <- stringr::str_extract(file_name, compress_regex)
  if (is.na(compression_ext)) {
    compression_ext <- NULL
  } else {
    compression_ext <- stringr::str_remove(compression_ext, "^\\.")
  }

  list(
    round_id = split_res[1],
    team_abbr = split_res[2],
    model_abbr = split_res[3],
    model_id = paste(split_res[2], split_res[3], sep = "-"),
    ext = fs::path_ext(file_path),
    compression_ext = compression_ext
  ) %>% purrr::compact()
}
