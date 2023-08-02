#' Check all required task ID/output type/output type ID value combinations present
#' in model data.
#'
#' @inheritParams check_tbl_unique_round_id
#' @inherit check_tbl_colnames return
#' @export
check_tbl_values_required <- function(tbl, round_id, file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- hubUtils::coerce_to_hub_schema(tbl, config_tasks)
  tbl[["value"]] <- NULL

  req <- hubUtils::expand_model_out_val_grid(
    config_tasks,
    round_id = round_id,
    required_vals_only = TRUE
  )
  full <- hubUtils::expand_model_out_val_grid(
    config_tasks,
    round_id = round_id,
    required_vals_only = FALSE
  )
  req_mask <- are_required_vals(tbl, req)

  # We split the tbl & mask using a concatination of optional values in each row.
  split_tbl <- split(tbl, conc_rows(tbl, mask = req_mask))
  split_req_mask <- split(
    tibble::as_tibble(req_mask),
    conc_rows(tbl, mask = req_mask)
  )

  # We can then map our check over each unique combination of optional
  # values, ensuring any required value combination across the remaining columns
  # exists in the tbl subset.
  missing_df <- purrr::map2(
    split_tbl, split_req_mask,
    ~ missing_req_rows(.x, .y, req, full)
  ) %>%
    purrr::list_rbind()

  check <- nrow(missing_df) == 0L

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline("See {.var missing} attribute for details.")
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Required task ID/output type/output type ID combinations",
    msg_attribute = NULL,
    msg_verbs = c("all present.", "missing."),
    details = details,
    missing = missing_df
  )
}


missing_req_rows <- function(x, mask, req, full) {
  opt_cols <- purrr::map_lgl(mask, ~ !all(.x))
  if (all(opt_cols == FALSE)) {
    return(req[!conc_rows(req) %in% conc_rows(x), ])
  }
  opt_colnms <- names(x)[opt_cols]
  req <- req[, !names(req) %in% opt_colnms]

  # To ensure we focus on applicable required values (which may differ across
  # modeling tasks) we first subset rows from the full combination of values that
  # match a concanetated id of optional value combinations in x.
  applicaple_full <- full[
    conc_rows(full[, opt_colnms]) %in% conc_rows(x[, opt_colnms]),
  ]
  # Then we subset req for only the value combinations that are applicable to the
  # values being validated. This gives a table of expected required values and
  # avoids erroneously returning missing required values that are not applicable
  # to a given model task or output type.
  expected_req <- req[
    conc_rows(req) %in%
      conc_rows(applicaple_full[, names(applicaple_full) != opt_colnms]),
  ] %>%
    unique()

  # Finally, we compare the expected required values for the optional value
  # combination we are validating to those in x and return any expected rows
  # that are not included in x.
  missing <- !conc_rows(expected_req) %in% conc_rows(x[, !opt_cols])
  if (any(missing)) {
    cbind(
      expected_req[missing, ],
      unique(x[, opt_cols])
    )[names(x)]
  } else {
    full[0, ]
  }
}

are_required_vals <- function(tbl, req) {
  req[, setdiff(names(tbl), names(req))] <- ""
  req <- req[, names(tbl)]

  req_vals <- purrr::map2(
    tbl, purrr::map(req, unique),
    ~ .x %in% .y
  )
  do.call(cbind, req_vals)
}
