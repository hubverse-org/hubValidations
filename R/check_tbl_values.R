#' Check model output data tbl contains valid value combinations
#'
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
check_tbl_values <- function(tbl, file_path, hub_path) {
  round_id <- get_file_round_id(file_path)
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  # Coerce both tbl and accepted vals to character for easier comparison of
  # values. Tried to use arrow tbls for comparisons as more efficient when
  # working with larger files but currently arrow does not match NAs as dplyr
  # does, returning false positives for mean & median rows which contain NA in
  # output type ID column.
  tbl <- hubUtils::coerce_to_character(tbl)
  accepted_vals <- hubUtils::expand_model_out_val_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    all_character = TRUE
  )

  # This approach uses dplyr to identify tbl rows that don't have a complete match
  # in accepted_vals.
  accepted_vals$valid <- TRUE
  valid_tbl <- dplyr::left_join(
    tbl, accepted_vals,
    by = names(tbl)[names(tbl) != "value"]
  )

  check <- !any(is.na(valid_tbl$valid))

  if (check) {
    details <- NULL
  } else {
    # TODO: Should this be returning a row index or a df of invalid rows?
    details <- cli::format_inline(
      "Affected rows: {.val {which(is.na(valid_tbl$valid))}}"
    )
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
