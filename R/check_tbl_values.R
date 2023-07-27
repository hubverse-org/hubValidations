#' Check model output data tbl contains valid value combinations
#'
#' @inheritParams check_tbl_colnames
#' @inherit check_tbl_colnames return
#' @export
check_tbl_values <- function(tbl, file_path, hub_path) {
  round_id <- get_file_round_id(file_path)
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  accepted_vals <- hubUtils::expand_model_out_val_grid(
    config_tasks = config_tasks,
    round_id = round_id
  )
  # TODO: Make this part of expand_model_out_val_grid
  accepted_vals <- hubUtils::create_hub_schema(
    config_tasks = config_tasks,
    partitions = NULL,
    r_schema = TRUE
  )[names(accepted_vals)] %>%
    purrr::map2(
      accepted_vals,
      ~ get(paste0("as.", .x))(.y)
    ) %>%
    tibble::as_tibble()

  # This approach uses dplyr to identify tbl rows that don't have a complete match
  # in accepted_vals.
  accepted_vals$valid <- TRUE
  valid_tbl <- dplyr::left_join(tbl, accepted_vals)

  check <- any(is.na(valid_tbl$valid))

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
        "Affected rows: {.val {which(is.na(valid_tbl$valid))}}")
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Data rows",
    msg_attribute = "valid value combinations",
    msg_verbs = c("contain", "do not contain"),
    details = details
  )
}
