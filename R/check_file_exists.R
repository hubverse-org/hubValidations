#' Check file exists at the file path specified
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_file_exists <- function(file_path, hub_path = ".") {
    model_output_dir <- get_hub_model_output_dir(hub_path)
    full_path <- fs::path(hub_path, model_output_dir, file_path)
    check <- fs::file_exists(full_path)

    capture_check_cnd(
        check = check,
        file_path = file_path,
        msg_subject = "File",
        msg_attribute = cli::format_inline("at path {.path {full_path}}."),
        msg_verbs = c("exists", "does not exist"),
        error = TRUE)
}
