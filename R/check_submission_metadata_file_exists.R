#' Check whether a metadata file for the given model exists
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_submission_metadata_file_exists <- function(file_path, hub_path = ".") {
    model_id <- parse_file_name(file_path)$model_id
    metadata_file_paths <- paste0(model_id, c(".yml", ".yaml"))
    abs_path <- abs_file_path(metadata_file_paths, hub_path,
                              subdir = "model-metadata")
    rel_path <- rel_file_path(metadata_file_paths, hub_path,
                              subdir = "model-metadata")
    fe_results <- fs::file_exists(abs_path)
    check <- any(fe_results)

    if (check) {
      ind <- which(fe_results)
      msg_attribute <- cli::format_inline("at path {.path {rel_path[ind]}}.")
    } else {
      msg_attribute <- cli::format_inline("at path {.path {rel_path[1]}} or
                                           {.path {rel_path[2]}}.")
    }

    capture_check_cnd(
        check = check,
        file_path = file_path,
        msg_subject = "Metadata file",
        msg_attribute = msg_attribute,
        msg_verbs = c("exists", "does not exist"),
        error = TRUE)
}
