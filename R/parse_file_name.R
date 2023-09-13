parse_file_name <- function(file_path) {
    file_name <- tools::file_path_sans_ext(basename(file_path))

    split_pattern <- stringr::regex(
        "([[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2})|[a-z_0-9]+",
        TRUE
    )
    split_res <- unlist(
        stringr::str_extract_all(
            file_name,
            split_pattern
        )
    )
    if (length(split_res) != 3L) {
        cli::cli_abort(
            "Could not parse file name {.path {file_name}} for submission metadata.
      Please consult documentation for file name requirements for correct
      metadata parsing."
        )
    }
    list(
        round_id = split_res[1],
        team_abbr = split_res[2],
        model_abbr = split_res[3],
        model_id = paste(split_res[2], split_res[3], sep = "-"),
        ext = fs::path_ext(file_path)
    )
}
