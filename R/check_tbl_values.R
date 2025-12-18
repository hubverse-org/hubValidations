#' Check model output data tbl contains valid value combinations
#' @param tbl a tibble/data.frame of the contents of the file being validated. Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inheritParams check_tbl_spl_compound_taskid_set
#' @inheritParams expand_model_out_grid
#' @inherit check_tbl_colnames return
#' @export
check_tbl_values <- function(
  tbl,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
) {
  config_tasks <- read_config(hub_path, "tasks")

  valid_tbl <- tbl %>%
    tibble::rowid_to_column() %>%
    split(f = tbl$output_type) %>%
    purrr::imap(
      ~ check_values_by_output_type(
        tbl = .x,
        output_type = .y,
        config_tasks = config_tasks,
        round_id = round_id,
        derived_task_ids = derived_task_ids
      )
    ) %>%
    purrr::list_rbind()

  check <- !any(is.na(valid_tbl$valid))

  if (check) {
    details <- NULL
    error_tbl <- NULL
  } else {
    error_summary <- summarise_invalid_values(
      valid_tbl,
      config_tasks,
      round_id,
      derived_task_ids
    )
    details <- error_summary$msg
    if (length(error_summary$invalid_combs_idx) == 0L) {
      error_tbl <- NULL
    } else {
      error_tbl <- tbl[
        error_summary$invalid_combs_idx,
        names(tbl) != "value"
      ]
    }
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "{.var tbl}",
    msg_attribute = "",
    msg_verbs = c(
      "contains valid values/value combinations.",
      "contains invalid values/value combinations."
    ),
    error_tbl = error_tbl,
    error = TRUE,
    details = details
  )
}

check_values_by_output_type <- function(
  tbl,
  output_type,
  config_tasks,
  round_id,
  derived_task_ids = NULL
) {
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }

  # Coerce accepted vals to character for easier comparison of
  # values. Tried to use arrow tbls for comparisons as more efficient when
  # working with larger files but currently arrow does not match NAs as dplyr
  # does, returning false positives for mean & median rows which contain NA in
  # output type ID column.
  accepted_vals <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    all_character = TRUE,
    output_types = output_type,
    derived_task_ids = derived_task_ids
  )

  # This approach uses dplyr to identify tbl rows that don't have a complete match
  # in accepted_vals.
  accepted_vals$valid <- TRUE
  if (hubUtils::is_v3_config(config_tasks) && output_type == "sample") {
    tbl[tbl$output_type == "sample", "output_type_id"] <- NA
  }

  dplyr::left_join(
    tbl,
    accepted_vals,
    by = setdiff(names(tbl), c("value", "rowid"))
  )
}

# Summarise results of check for invalid values by creating appropriate
# messages and extracting the rowids of invalid value combinations with respect
# to the row order in the original tbl.
# Problems are summarised in two parts:
# First we report any invalid values in the tbl that do not match any values in the
# config. Second we report any rows that contain valid values but in invalid
# combinations.
summarise_invalid_values <- function(
  valid_tbl,
  config_tasks,
  round_id,
  derived_task_ids
) {
  # Chack for invalid values
  cols <- setdiff(names(valid_tbl), c("value", "valid", "rowid"))
  uniq_tbl <- purrr::map(valid_tbl[cols], unique)
  uniq_config <- get_round_config_values(
    config_tasks,
    round_id,
    derived_task_ids
  )[cols]

  invalid_vals <- purrr::map2(
    uniq_tbl,
    uniq_config,
    ~ .x[!.x %in% .y]
  ) %>%
    purrr::compact()

  if (length(invalid_vals) != 0L) {
    invalid_vals_msg <- purrr::imap_chr(
      invalid_vals,
      ~ cli::format_inline(
        "Column {.var {.y}} contains invalid {cli::qty(length(.x))}
        value{?s} {.val {.x}}."
      )
    ) %>%
      paste(collapse = " ")
  } else {
    invalid_vals_msg <- NULL
  }

  # Get rowids of invalid value combinations
  invalid_val_idx <- purrr::imap(
    invalid_vals,
    ~ which(valid_tbl[[.y]] %in% .x)
  ) %>%
    unlist(use.names = FALSE) %>%
    unique()
  invalid_row_idx <- which(is.na(valid_tbl$valid))
  # Ignore rows which have already been reported for invalid values
  invalid_combs_idx <- setdiff(invalid_row_idx, invalid_val_idx)
  if (length(invalid_combs_idx) == 0L) {
    invalid_combs_msg <- NULL
  } else {
    # invalid_combs_idx indicates invalid value combinations in the table joined
    # to expanded valid value grid. This changes the row order of the table, so
    # to return rowids with respect to the original tbl row order we use
    # invalid_combs_idx to extract values from the rowid column of the valid_tbl.
    invalid_combs_idx <- valid_tbl$rowid[invalid_combs_idx]
    invalid_combs_msg <- cli::format_inline(
      "Additionally {cli::qty(length(invalid_combs_idx))} row{?s}
      {.val {invalid_combs_idx}} {cli::qty(length(invalid_combs_idx))}
      {?contains/contain} invalid combinations of valid values.
      See {.var error_tbl} for details."
    )
  }
  list(
    msg = paste(invalid_vals_msg, invalid_combs_msg, sep = "\n"),
    invalid_combs_idx = invalid_combs_idx
  )
}
