#' Parse model output file metadata from file name
#'
#' @param file_path Character string. A model output file name.
#' Can include parent directories which are ignored.
#' @param file_type Character string. Type of file name being parsed. One of `"model_output"`
#' or `"model_metadata"`.
#' @details
#' File names are allowed to contain the following compression extension prefixes:
#' `r paste0(".", compress_codec)`.
#' These extension prefixes are now extracted when parsing the file name
#' and returned as `compression_ext` element if present.
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
parse_file_name <- function(
  file_path,
  file_type = c("model_output", "model_metadata")
) {
  file_type <- rlang::arg_match(file_type)
  checkmate::assert_string(file_path)
  file_name <- tools::file_path_sans_ext(basename(file_path))
  # Detect, validate and remove compression extension before validating and splitting
  # file name
  compression_ext <- validate_compression_ext(
    compression_ext = fs::path_ext(file_name)
  )
  file_name <- tools::file_path_sans_ext(file_name)
  validate_filename_contents(file_name)
  validate_filename_pattern(file_name, file_type)

  split_res <- split_filename(file_name, file_type)

  list(
    round_id = split_res[1],
    team_abbr = split_res[2],
    model_abbr = split_res[3],
    model_id = paste(split_res[2], split_res[3], sep = "-"),
    ext = fs::path_ext(file_path),
    compression_ext = compression_ext
  ) %>%
    purrr::compact()
}

# Split file name into round_id, team_abbr and model_abbr
split_filename <- function(file_name, file_type) {
  split_pattern <- stringr::regex(
    "([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2})|[a-z_0-9]+",
    TRUE
  )
  split_res <- stringr::str_extract_all(file_name, split_pattern) |> unlist()

  exp_n <- switch(file_type, model_output = 3L, model_metadata = 2L)

  if (length(split_res) != exp_n) {
    cli::cli_abort(
      "Could not parse file name {.path {file_name}} for submission metadata.
      Please consult
      {.href [documentation on file name requirements
      ](https://docs.hubverse.io/en/latest/user-guide/model-output.html#directory-structure)} 
      for correct metadata parsing."
    )
  }
  if (file_type == "model_metadata") {
    split_res <- c(NA, split_res)
  }
  split_res
}

# Function that validates a hubverse file name does not contain invalid characters
validate_filename_contents <- function(file_name, call = rlang::caller_env()) {
  pattern <- "^[A-Za-z0-9_-]+$"
  invalid_contents <- isFALSE(grepl(pattern, file_name))

  if (invalid_contents) {
    invalid_char <- stringr::str_remove_all(file_name, "[A-Za-z0-9_-]+") |> # nolint: object_usage_linter
      strsplit("") |>
      unlist() |>
      unique()

    cli::cli_abort(
      c(
        "x" = "File name {.file {file_name}} contains character{?s}
        {.val {invalid_char}} that {?is/are} not allowed"
      ),
      call = call
    )
  }
}

# Function that validates a hubverse file name matches expected pattern:
# [round_id]-[team_abbr]-[model_abbr]
validate_filename_pattern <- function(
  file_name,
  file_type,
  call = rlang::caller_env()
) {
  pattern <- switch(
    file_type,
    model_output = "^((\\d{4}-\\d{2}-\\d{2})|[A-Za-z0-9_]+)-([A-Za-z0-9_]+)-([A-Za-z0-9_]+)$",
    model_metadata = "^([A-Za-z0-9_]+)-([A-Za-z0-9_]+)$"
  )

  expected_pattern <- switch(
    file_type, # nolint: object_usage_linter
    model_output = "[round_id]-[team_abbr]-[model_abbr]",
    model_metadata = "[team_abbr]-[model_abbr]"
  )

  info_url <- switch(
    file_type, # nolint: object_usage_linter
    model_output = "https://docs.hubverse.io/en/latest/user-guide/model-output.html#directory-structure",
    model_metadata = "https://docs.hubverse.io/en/latest/user-guide/model-metadata.html#directory-structure"
  )

  if (!grepl(pattern, file_name)) {
    cli::cli_abort(
      c(
        "x" = "File name {.file {file_name}} does not match expected pattern of
      {.field {expected_pattern}}. Please consult
      {.href [documentation on file name requirements
      ]({info_url})}
      for details."
      ),
      call = call
    )
  }
}

# Function that validates a hubverse file name compression extension.
# Returns NULL if empty string or compression_ext if valid.
validate_compression_ext <- function(
  compression_ext,
  call = rlang::caller_env()
) {
  if (compression_ext == "") {
    return(NULL)
  }
  if (!compression_ext %in% compress_codec) {
    cli::cli_abort(
      c(
        "x" = "Compression extension {.val {compression_ext}} is not valid.
      Must be one of {.val {compress_codec}}.
      Please consult {.href [documentation on file name requirements
      ](https://docs.hubverse.io/en/latest/user-guide/model-output.html#directory-structure)}
      for details."
      ),
      call = call
    )
  }
  compression_ext
}
