#' Check model output data tbl contains valid value combinations
#' @param tbl a tibble/data.frame of the contents of the file being validated. Column types must **all be character**.
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @export
check_tbl_values <- function(tbl, round_id, file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  # Coerce accepted vals to character for easier comparison of
  # values. Tried to use arrow tbls for comparisons as more efficient when
  # working with larger files but currently arrow does not match NAs as dplyr
  # does, returning false positives for mean & median rows which contain NA in
  # output type ID column.
  accepted_vals <- hubData::expand_model_out_val_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    all_character = TRUE
  )

  # This approach uses dplyr to identify tbl rows that don't have a complete match
  # in accepted_vals.
  accepted_vals$valid <- TRUE
  if (hubUtils::is_v3_config(config_tasks)) {
    out_type_ids <- tbl[["output_type_id"]]
    tbl[tbl$output_type == "sample", "output_type_id"] <- NA
  }

  valid_tbl <- dplyr::left_join(
    tbl, accepted_vals,
    by = names(tbl)[names(tbl) != "value"]
  )

  check <- !any(is.na(valid_tbl$valid))

  if (check) {
    details <- NULL
    error_tbl <- NULL
  } else {
    error_summary <- summarise_invalid_values(valid_tbl, accepted_vals)
    details <- error_summary$msg
    if (length(error_summary$invalid_combs_idx) == 0L) {
      error_tbl <- NULL
    } else {
      if (hubUtils::is_v3_config(config_tasks)) {
        tbl[["output_type_id"]] <- out_type_ids
      }
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

summarise_invalid_values <- function(valid_tbl, accepted_vals) {
  cols <- names(valid_tbl)[!names(valid_tbl) %in% c("value", "valid")]
  uniq_tbl <- purrr::map(valid_tbl[cols], unique)
  uniq_config <- purrr::map(accepted_vals[cols], unique)

  invalid_vals <- purrr::map2(
    uniq_tbl, uniq_config,
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

  invalid_val_idx <- purrr::imap(
    invalid_vals,
    ~ which(valid_tbl[[.y]] %in% .x)
  ) %>%
    unlist(use.names = FALSE) %>%
    unique()
  invalid_row_idx <- which(is.na(valid_tbl$valid))
  invalid_combs_idx <- setdiff(invalid_val_idx, invalid_row_idx)
  if (length(invalid_combs_idx) == 0L) {
    invalid_combs_msg <- NULL
  } else {
    invalid_combs_msg <- cli::format_inline(
      "Additionally row{?s} {.val {invalid_combs_idx}} contain invalid
      combinations of valid values.
      See {.var error_tbl} for details."
    )
  }
  list(
    msg = paste(invalid_vals_msg, invalid_combs_msg, sep = "\n"),
    invalid_combs_idx = invalid_combs_idx
  )
}


get_numeric_output_type_ids <- function(file_path, hub_path) {
  get_file_round_config(file_path, hub_path)[["model_tasks"]] %>%
    purrr::map(~ .x[["output_type"]]) %>%
    unlist(recursive = FALSE) %>%
    purrr::map(~ purrr::pluck(.x, "output_type_id")) %>%
    purrr::map_lgl(~ is.numeric(unlist(.x))) %>%
    purrr::keep(isTRUE) %>%
    names() %>%
    unique()
}


coerce_num_output_type_ids <- function(tbl, file_path, hub_path) {
  num_output_types <- get_numeric_output_type_ids(
    file_path = file_path,
    hub_path = hub_path
  )

  if (
    any(tbl[["output_type"]] %in% num_output_types) &&
      inherits(tbl[["output_type_id"]], "character")
  ) {
    type_coerce <- tbl[["output_type"]] %in% num_output_types
    num_output_type_id <- suppressWarnings(
      as.numeric(tbl$output_type_id[type_coerce])
    )
    # establish only valid coercions to distinguish between the potential for
    # two cdf output types in the same round, one numeric and one character.
    valid <- !is.na(num_output_type_id)
    tbl$output_type_id[type_coerce][valid] <- as.character(
      num_output_type_id[valid]
    )
  }
  tbl
}
