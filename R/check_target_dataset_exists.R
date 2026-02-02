#' Check target dataset can be detected for a given target type
#'
#' @inheritParams check_target_dataset_unique
#' @inherit check_target_dataset_unique return
#'
#' @export
check_target_dataset_exists <- function(
  hub_path,
  target_type = c("time-series", "oracle-output")
) {
  target_type <- rlang::arg_match(target_type)
  target_path <- hubData::get_target_path(hub_path, target_type)

  check <- length(target_path) > 0L

  # Use target_type as file_path (required for valid target_validations object)
  capture_check_cnd(
    check = check,
    file_path = target_type,
    msg_subject = cli::format_inline("{.field {target_type}} dataset"),
    msg_attribute = NULL,
    msg_verbs = c("detected.", "not detected."),
    error = TRUE
  )
}
