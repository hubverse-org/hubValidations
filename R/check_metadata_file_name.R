#' Check whether the file name of a metadata file matches the model_id or
#' combination of team_abbr and model_abbr specified within the metadata file
#'
#' @inherit check_metadata_file_exists params
#' @inherit check_tbl_col_types return
#'
#' @export
check_metadata_file_name <- function(file_path, hub_path = ".") {
  abs_metadata_path <- abs_file_path(hub_path = hub_path,
                                     subdir = "model-metadata",
                                     file_path = file_path)
  metadata <- yaml::read_yaml(abs_metadata_path)

  if ("model_id" %in% names(metadata)) {
    model_id <- metadata$model_id
  } else if (all(c("team_abbr", "model_abbr") %in% names(metadata))) {
    model_id <- paste0(metadata$team_abbr, "-", metadata$model_abbr)
  } else {
    return(
      capture_check_cnd(
        check = FALSE,
        file_path = file_path,
        msg_subject = "Metadata file",
        msg_attribute = "either a {.var model_id} or both a {.var team_abbr} and {.var model_abbr}.",
        msg_verbs = c("contains", "must contain"),
        details = "There is an error in the set up of the hub's {.val model-metadata-schema.json} config file.",
        error = TRUE))
  }

  check <- model_id == fs::path_ext_remove(basename(file_path))
  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline("File name was {.val {basename(file_path)}},
                                   but {.var model_id} was {.val {model_id}}.")
  }

  return(
    capture_check_cnd(
      check = check,
      file_path = file_path,
      msg_subject = "Metadata file name",
      msg_attribute = "the {.var model_id} specified within the metadata file.",
      msg_verbs = c("matches", "must match"),
      details = details,
      error = TRUE))
}
