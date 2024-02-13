#' Check file exists at the file path specified
#'
#' @param subdir subdirectory within the hub
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_file_exists <- function(file_path, hub_path = ".",
                              subdir = c(
                                "model-output", "model-metadata",
                                "hub-config"
                              )) {
  abs_path <- abs_file_path(file_path, hub_path, subdir)
  rel_path <- rel_file_path(file_path, hub_path, subdir) # nolint: object_usage_linter
  check <- fs::file_exists(abs_path)

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "File",
    msg_attribute = cli::format_inline("at path {.path {rel_path}}."),
    msg_verbs = c("exists", "does not exist"),
    error = TRUE
  )
}
