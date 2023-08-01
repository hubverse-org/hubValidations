#' Check all required task ID/output type/output type ID value combinations present
#' in model data.
#'
#' @inheritParams check_tbl_unique_round_id
#' @inherit check_tbl_colnames return
#' @export
check_tbl_values_required <- function(tbl, round_id, file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  tbl <- hubUtils::coerce_to_hub_schema(tbl, config_tasks)
  req <- hubUtils::expand_model_out_val_grid(
    config_tasks,
    round_id = round_id,
    required_vals_only = TRUE
  )
  all <- hubUtils::expand_model_out_val_grid(
    config_tasks,
    round_id = round_id,
    required_vals_only = FALSE
  )

  tbl[["value"]] <- NULL
  opt_cols <- !names(tbl) %in% names(req)
  split_tbl <- split(tbl, conc_rows(tbl[, opt_cols]))

  missing_df <- purrr::map(
    split_tbl,
    ~ missing_req_rows(.x, req, all, opt_cols)
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


missing_req_rows <- function(x, req, all, opt_cols) {
  opt_colnms <- names(x)[opt_cols]
  applicaple_all <- all[
    conc_rows(all[, opt_colnms]) %in% conc_rows(x[, opt_colnms]),
  ]
  applicaple_req <- req[
    conc_rows(req) %in%
      conc_rows(applicaple_all[, names(applicaple_all) != opt_colnms]),
  ]

  missing <- !conc_rows(applicaple_req) %in% conc_rows(x[, !opt_cols])
  if (any(missing)) {
    cbind(
      applicaple_req[missing, ],
      unique(x[, opt_cols])
    )[names(x)]
  } else {
    NULL
  }
}
