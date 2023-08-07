#' Check all required task ID/output type/output type ID value combinations present
#' in model data.
#'
#' @inherit check_tbl_colnames return params
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
  # Get a logical mask of whether values in each column are required or not.
  req_mask <- are_required_vals(tbl, req)

  # When required values are specified across all columns in the config (i.e. in `req`),
  # we need to ensure that the full grid of required values is tested (i.e.
  # there is a block in the data file containing required values across all columns).
  # We therefore perform a specific check for this.
  if (full_req_grid_tested(req_mask, req)) {
    missing_df <- list(NULL)
  } else {
    missing_df <- list(req)
  }
  # We split the tbl & mask using a concatenation of optional values in each row.
  # This enables us to check that for each unique combination of optional values,
  # all related required values have also been supplied.
  split_idx <- conc_rows(tbl, mask = req_mask)
  split_tbl <- split(tbl, split_idx)
  split_req_mask <- split(
    tibble::as_tibble(req_mask),
    split_idx
  )

  # We can then map our check over each unique combination of optional
  # values, ensuring any required value combination across the remaining columns
  # exists in the tbl subset.
  missing_df <- c(
    missing_df,
    purrr::map2(
      .x = split_tbl, .y = split_req_mask,
      ~ missing_required(x = .x, mask = .y, req, full)
    )
  ) %>%
    purrr::list_rbind() %>%
    unique()

  # Remove false positives that may have been erroneously identified because checks
  # were performed on subsets of data.
  missing_df <- missing_df[
    !conc_rows(missing_df) %in% conc_rows(tbl),
  ]

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

# For a combination of optional values, check the data subset x of the combination
# contains all required values as well as each subset of combination of optional
# values of successively smaller n.
missing_required <- function(x, mask, req, full) {

  opt_cols_list <- get_opt_col_list(x, mask, full, req)

  purrr::map(
    opt_cols_list,
    ~ missing_req_rows(.x, x, mask, req, full)
  ) %>%
    purrr::list_rbind()
}

# Function creates a list of all optional column/value combinations of successively
# smaller m for a given req_mask.
# Checking all combinations is required to ensure required values
# in columns that contain both required and optional values are checked.
get_opt_col_list <- function(x, mask, full, req) {
    min_opt_col <- ncol(x) - ncol(req)

    opt_vals <- get_opt_vals(x, mask) %>%
        ignore_optional_output_type(x, mask, full, req)

    opt_val_combs <- get_opt_val_combs(opt_vals, min_opt_col)
    opt_cols_list <- list(get_opt_cols(mask))

    opt_cols_list <- c(
        opt_cols_list,
        purrr::map(
            opt_val_combs,
            ~ get_opt_cols(mask, .x)
        )
    )
    # Always include columns whose values are all optional in opt_cols.
    # This ensures correct applicable values are subset from appropriate model tasks.
    if (!setequal(names(x), names(req))) {
        opt_cols_list <- purrr::map(
            opt_cols_list,
            ~ {
                .x[setdiff(names(x), names(req))] <- TRUE
                .x
            }
        ) %>% unique()
    }
    opt_cols_list
}


missing_req_rows <- function(opt_cols, x, mask, req, full) {
  if (all(opt_cols == FALSE)) {
    return(req[!conc_rows(req) %in% conc_rows(x), ])
  }

  opt_colnms <- names(x)[opt_cols]
  req <- req[, !names(req) %in% opt_colnms]

  # To ensure we focus on applicable required values (which may differ across
  # modeling tasks) we first subset rows from the full combination of values that
  # match a concatenated id of optional value combinations in x.
  applicaple_full <- full[
    conc_rows(full[, opt_colnms]) %in% conc_rows(x[, opt_colnms]),
  ]
  # Then we subset req for only the value combinations that are applicable to the
  # values being validated. This gives a table of expected required values and
  # avoids erroneously returning missing required values that are not applicable
  # to a given model task or output type.
  expected_req <- req[
    conc_rows(req) %in%
      conc_rows(applicaple_full[, names(req)]),
  ] %>%
    unique()

  # Finally, we compare the expected required values for the optional value
  # combination we are validating to those in x and return any expected rows
  # that are not included in x.
  missing <- !conc_rows(expected_req) %in% conc_rows(x[, names(expected_req)])
  if (any(missing)) {
    cbind(
      expected_req[missing, ],
      unique(x[, opt_cols])
    )[, names(x)]
  } else {
    full[0, names(x)]
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

# If all columns have been configured with required values, check that there is
# a block in the file of all required values.
full_req_grid_tested <- function(req_mask, req) {
  if (setequal(colnames(req_mask), names(req))) {
    any(apply(req_mask, 1, FUN = function(x, req_cols = names(req)) {
      all(req_cols %in% names(x)[x])
    }))
  } else {
    TRUE
  }
}

# Get a named list of the unique optional value in each optional column in x.
get_opt_vals <- function(x, mask) {
  idx <- purrr::map_lgl(mask, all)
  if (all(idx)) {
    return(NULL)
  }
  as.vector(unique(x[!idx]))
}

# Get each subset of combination of optional values of successively smaller n.
get_opt_val_combs <- function(opt_vals, min_opt_col = 0L) {
  if (is.null(opt_vals)) {
    return(NULL)
  }

  if (min_opt_col == 0L) {
    base_opt_vals <- list(NULL)
  } else {
    base_opt_vals <- NULL
  }
  c(
    base_opt_vals,
    purrr::map(
      seq(1, length(opt_vals)) - 1L,
      ~ combn(opt_vals, m = .x, simplify = FALSE)
    ) %>%
      unlist(recursive = FALSE) %>%
      purrr::compact()
  )
}

# Get a logical vector of whether a column contains all optional values or not.
get_opt_cols <- function(mask, check_opt_comb = NULL) {
  opt_cols <- purrr::map_lgl(mask, ~ !all(.x))
  if (!is.null(check_opt_comb)) {
    opt_cols[names(check_opt_comb)] <- FALSE
  }
  opt_cols
}

get_required_output_types <- function(x, mask, full, req) {
  cols <- get_opt_cols(mask)
  applicaple_full <- full[
    conc_rows(full[, cols]) %in% conc_rows(x[, cols]),
  ]
  req[
    conc_rows(req[, !cols]) %in%
      conc_rows(applicaple_full[, !cols]),
  ][[
  hubUtils::std_colnames["output_type"]
  ]] %>%
    unique()
}

ignore_optional_output_type <- function(opt_vals, x, mask, full, req) {
  output_tid_col <- hubUtils::std_colnames["output_type"]
  if (!output_tid_col %in% names(opt_vals)) {
    return(opt_vals)
  }

  req_output_types <- get_required_output_types(x, mask, full, req)
  if (!opt_vals[[output_tid_col]] %in% req_output_types) {
    opt_vals[hubUtils::std_colnames[
      c("output_type", "output_type_id")
    ]] <- NULL
  }
  opt_vals
}
