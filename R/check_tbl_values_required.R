#' Check all required task ID/output type/output type ID value combinations present
#' in model data.
#'
#' @inheritParams check_tbl_values
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
#' @details
#' Note that it is **necessary for `derived_task_ids` to be specified if any of
#' the task IDs a derived task ID depends on have required values**. If this is the
#' case and derived task IDs are not specified, the dependent nature of derived
#' task ID values will result in **false validation errors when validating
#' required values**.
check_tbl_values_required <- function(tbl, round_id, file_path, hub_path,
                                      derived_task_ids = get_derived_task_ids(hub_path)) {
  tbl[["value"]] <- NULL
  config_tasks <- read_config(hub_path, "tasks")

  if (hubUtils::is_v3_config(config_tasks)) {
    tbl[tbl$output_type == "sample", "output_type_id"] <- NA
  }
  if (!is.null(derived_task_ids)) {
    tbl[, derived_task_ids] <- NA_character_
  }
  is_v4 <- hubUtils::version_gte("v4.0.0", config = config_tasks)
  if (is_v4) {
    # In v4, whether an output type is optional is determined by `is_required`, not
    # by values in `optional` vs `required` properties and all output type IDs are
    # stored in the required property.
    # Also, in v4, if an optional output type is submitted, all output type IDs
    # associated with it become required.
    # To support back-compatibility and use existing infrastructure we need to:
    # 1. Determine the output types that are are being submitted
    output_types <- get_submission_required_output_types(
      tbl, config_tasks, round_id
    )
    # 2. Force all output types being submitted to be required, regardless of whether
    # they are optional in the config.
    force_output_types <- TRUE
  } else {
    # For pre v4 configs, we use the legacy settings and rules.
    output_types <- NULL
    force_output_types <- FALSE
  }
  req <- expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    output_types = output_types,
    required_vals_only = TRUE,
    force_output_types = force_output_types,
    all_character = TRUE,
    bind_model_tasks = FALSE,
    derived_task_ids = derived_task_ids
  )

  full <- expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    output_types = output_types,
    required_vals_only = FALSE,
    all_character = TRUE,
    as_arrow_table = FALSE,
    bind_model_tasks = FALSE,
    derived_task_ids = derived_task_ids
  )

  tbl <- join_tbl_to_model_task(full, tbl, subset_to_tbl_cols = TRUE)

  missing_df <- purrr::pmap(
    combine_mt_inputs(tbl, req, full),
    check_modeling_task_values_required
  ) %>%
    purrr::list_rbind()

  check <- nrow(missing_df) == 0L

  if (check) {
    details <- NULL
  } else {
    missing_df <- coerce_to_hub_schema(missing_df, config_tasks)
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

check_modeling_task_values_required <- function(tbl, req, full) {
  if (nrow(tbl) == 0L) {
    if (setequal(names(tbl), names(req))) {
      return(req[, names(tbl)])
    } else {
      return(tbl)
    }
  }
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
  missing_df <- dplyr::anti_join(missing_df, tbl, by = names(tbl))
}

# For a combination of optional values, check the data subset x of the combination
# contains all required values as well as each subset of combination of optional
# values of successively smaller n.
missing_required <- function(x, mask, req, full) {
  opt_cols_list <- get_opt_col_list(x, mask, full, req)
  map_missing_req_rows(opt_cols_list, x, mask, req, full)
}

# Function creates a list of all optional column/value combinations of successively
# smaller m for a given req_mask.
# Checking all combinations is required to ensure required values
# in columns that contain both required and optional values are checked.
get_opt_col_list <- function(x, mask, full, req) {
  min_opt_col <- ncol(x) - ncol(req)
  all_opt_cols <- setdiff(names(x), names(req)) # nolint: object_usage_linter

  opt_vals <- get_opt_vals(x, mask) %>%
    ignore_optional_output_type(x, mask, full, req)

  opt_val_combs <- get_opt_val_combs(opt_vals, min_opt_col)

  c(
    list(get_opt_cols(mask)),
    purrr::map(
      opt_val_combs,
      ~ get_opt_cols(mask, .x, all_opt_cols)
    )
  ) %>% unique()
}

# Identify missing required values for optional value combinations.
# Output full missing rows compiled from optional values and missing required values.
missing_req_rows <- function(opt_cols, x, mask, req, full) {

  if (all(opt_cols == FALSE)) {
    return(req[!conc_rows(req) %in% conc_rows(x), ])
  }

  opt_colnms <- names(x)[opt_cols]

  req <- req[, !names(req) %in% opt_colnms]

  # To ensure we focus on applicable required values (which may differ across
  # modeling tasks) we first subset rows from the full combination of values that
  # match a concatenated id of optional value combinations in x.
  applicaple_full <- dplyr::inner_join(full, unique(x[, opt_colnms]),
    by = opt_colnms
  )
  # Then we subset req for only the value combinations that are applicable to the
  # values being validated. This gives a table of expected required values and
  # avoids erroneously returning missing required values that are not applicable
  # to a given model task or output type.
  expected_req <- dplyr::inner_join(req,
    applicaple_full[, names(req)],
    by = names(req)
  ) %>%
    unique()

  # Finally, we compare the expected required values for the optional value
  # combination we are validating to those in x and return any expected rows
  # that are not included in x.
  missing <- dplyr::anti_join(expected_req, x[, names(expected_req)],
    by = names(expected_req)
  )
  if (nrow(missing) != 0L) {
    cbind(
      missing,
      unique(x[, opt_cols])
    )[, names(x)]
  } else {
    full[0L, names(x)]
  }
}

map_missing_req_rows <- function(opt_cols_list, x, mask, req, full) {
  purrr::map(
    opt_cols_list,
    ~ missing_req_rows(.x, x, mask, req, full)
  ) %>%
    purrr::list_rbind()
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
get_opt_cols <- function(mask, check_opt_comb = NULL, all_opt_cols = NULL) {
  opt_cols <- purrr::map_lgl(mask, ~ !all(.x))
  if (!is.null(check_opt_comb)) {
    opt_cols[names(check_opt_comb)] <- FALSE
  }
  # Always include columns whose values are all optional in opt_cols if provided.
  # This ensures correct applicable values are subset from appropriate model tasks.
  opt_cols[all_opt_cols] <- TRUE
  opt_cols
}

# Get a character vector of output types that are required in the applicable
# model task.
get_required_output_types <- function(x, mask, full, req) {
  cols <- get_opt_cols(mask)
  join_colnames <- names(cols)[cols]

  applicaple_full <- dplyr::inner_join(
    full, unique(x[, join_colnames]),
    by = join_colnames
  )

  join_colnames <- names(cols)[!cols]
  dplyr::inner_join(
    unique(applicaple_full[, join_colnames]), req,
    by = join_colnames
  )[[hubUtils::std_colnames["output_type"]]] %>%
    unique()
}

# If an output type is optional, ignore so that output type IDs associated with it
# are not errorneously flagged as missing.
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

all_na_colnames <- function(x) {
  names(x)[purrr::map_lgl(x, ~ all(is.na(.x)))]
}

split_na_req <- function(req) {
  na_idx <- which(is.na(req), arr.ind = TRUE)
  req[na_idx[, "row"], ] %>%
    split(na_idx[, "col"])
}

combine_mt_inputs <- function(tbl, req, full) {
  keep_mt <- purrr::map_lgl(req, ~ nrow(.x) > 0L)
  list(
    tbl[keep_mt],
    req[keep_mt],
    full[keep_mt]
  )
}

is_zero_tbl <- function(tbl) {
  isTRUE(ncol(tbl) == 0L)
}
