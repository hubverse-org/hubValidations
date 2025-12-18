#' Check that oracle values in an oracle output target data file are valid
#'
#' This check is only performed when the target data file contains an
#' `output_type_id` column and `cdf` or `pmf` output types.
#' It verifies that distributional output type (`cdf` and `pmf`) oracle
#' values meet the following criteria:
#' - `oracle_value` values are either `0` or `1`.
#' - `pmf` oracle values sum to `1` for each observation unit.
#' - `cdf` oracle values are non-decreasing for each observation unit when
#' sorted by the `output_type_id` set defined in the hub config.
#'
#' @details
#' When validating oracle values, data is grouped by observation unit to check
#' PMF sums and CDF monotonicity within each unit.
#'
#' **With `target-data.json` config:**
#' Observable unit is determined from the config's `observable_unit` specification.
#'
#' **Without `target-data.json` config:**
#' Observable unit is inferred from task ID columns present in the data.
#'
#' The `as_of` column is NOT included in the grouping. Oracle data is designed to
#' contain a single version per observable unit with a one-to-one mapping to model
#' output data.
#'
#' @inheritParams check_target_tbl_output_type_ids
#' @inheritParams check_target_tbl_colnames
#' @inherit check_tbl_col_types params return
#' @export
check_target_tbl_oracle_value <- function(
  target_tbl,
  target_type = c(
    "oracle-output",
    "time-series"
  ),
  file_path,
  hub_path,
  config_target_data = NULL
) {
  target_type <- rlang::arg_match(target_type)
  if (target_type == "time-series") {
    return(
      capture_check_info(
        file_path,
        msg = "Check not applicable to {.field time-series} target data. Skipped."
      )
    )
  }
  if (!has_output_type_ids(target_tbl)) {
    return(
      capture_check_info(
        file_path,
        msg = cli::format_inline(
          "Target table does not have {.code output_type_id} column. Check skipped."
        )
      )
    )
  }
  if (!has_distributional(target_tbl)) {
    return(
      capture_check_info(
        file_path,
        msg = cli::format_inline(
          "Target table does not contain {.val cdf} or {.val pmf} output types. Check skipped."
        )
      )
    )
  }

  config_tasks <- read_config(hub_path)

  check_vals <- check_oracle_value_vals(target_tbl)
  check_cdf <- check_cdf_oracle_value(
    target_tbl,
    config_tasks,
    config_target_data
  )
  check_pmf <- check_pmf_oracle_value(
    target_tbl,
    config_tasks,
    config_target_data
  )

  details <- details_summarise_oracle_value_checks(
    check_vals,
    check_cdf,
    check_pmf
  )
  error_df <- rbind(
    check_vals,
    check_cdf,
    check_pmf
  )
  check <- is.null(error_df)

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "{.field oracle-output} {.var target_tbl}"
    ),
    msg_attribute = "oracle values.",
    msg_verbs = c(
      "contains valid",
      "contains invalid"
    ),
    error_df = error_df,
    details = details,
    error = FALSE
  )
}

# Check oracle_value values are 0 or 1
#'
#' Identify invalid `oracle_value` entries in `cdf` or `pmf` output types.
#'
#' Filters the table to `cdf` and `pmf` rows and checks that `oracle_value` entries
#' are limited to 0 or 1. Returns a data frame of invalid entries or `NULL`.
#'
#' @param tbl A data frame containing `oracle_value` and `output_type` columns.
#' @return A data frame of invalid rows, or `NULL` if all values are valid.
#' @noRd
check_oracle_value_vals <- function(tbl) {
  tbl <- tbl[tbl$output_type %in% c("cdf", "pmf"), ]

  invalid_vals <- !tbl[["oracle_value"]] %in% c(0L, 1L)
  if (any(invalid_vals)) {
    tbl[invalid_vals, ]
  } else {
    NULL
  }
}

#' Validate `pmf` oracle values sum to 1 per observation unit.
#'
#' Groups the table by observation unit (as defined in the hub config) and checks
#' that the `oracle_value` column sums to 1 for each group. Returns rows from
#' groups where the sum deviates from 1.
#'
#' @param tbl An oracle output data frame.
#' @param config_tasks List of hub task configurations.
#' @param config_target_data Optional config from target-data.json.
#' @return A data frame of rows from observational units with invalid PMF sums,
#' or `NULL`.
#' @noRd
#' @importFrom dplyr near left_join
check_pmf_oracle_value <- function(
  tbl,
  config_tasks,
  config_target_data = NULL
) {
  tbl <- tbl[tbl$output_type == "pmf", ]

  # For oracle-output, as_of should NOT be included in grouping.
  # Oracle data is designed to contain a single version per observable unit
  # with a one-to-one mapping to model output data.
  obs_unit <- get_obs_unit(
    tbl,
    config_tasks,
    config_target_data,
    target_type = "oracle-output",
    include_as_of = FALSE
  )
  tbl <- group_by(tbl, across(all_of(obs_unit)))

  check_tbl <- summarise(
    tbl,
    invalid = !near(sum(.data[["oracle_value"]]), 1L),
    .groups = "drop"
  )

  if (any(check_tbl$invalid)) {
    left_join(
      # Subset to invalid rows only
      check_tbl[check_tbl$invalid, colnames(check_tbl) != "invalid"],
      tbl,
      by = obs_unit
    )
  } else {
    NULL
  }
}

#' Validate that `cdf` oracle values are non-decreasing.
#'
#' Checks that `oracle_value` values within each observation unit are
#' non-decreasing when sorted by the expected `output_type_id` order
#' defined in the hub config. Delegates output_type_id groupwise validation to
#' `check_oracle_value_cdf_crossing()`.
#'
#' @param tbl An oracle output data frame.
#' @param config_tasks List of hub task configurations.
#' @param config_target_data Optional config from target-data.json.
#' @return A data frame of rows violating CDF monotonicity, or `NULL`.
#' @noRd
check_cdf_oracle_value <- function(
  tbl,
  config_tasks,
  config_target_data = NULL
) {
  tbl <- tbl[tbl$output_type == "cdf", ]
  # Gather expected unique vectors of output_type_id values from config
  output_type_ids <- extract_output_type_id_vals(
    output_type = "cdf",
    tbl = tbl,
    config_tasks = config_tasks
  ) |>
    unique()

  error_df <- purrr::map(
    output_type_ids,
    ~ check_oracle_value_cdf_crossing(
      tbl = tbl,
      output_type_ids = .x,
      config_tasks = config_tasks,
      config_target_data = config_target_data
    )
  ) |>
    purrr::compact() |>
    purrr::list_rbind()

  if (nrow(error_df) == 0) {
    NULL
  } else {
    error_df
  }
}

#' Check for CDF violations (decreasing oracle values) within an observation unit
#' for a set of `output_type_id`s.
#'
#' Validates that `oracle_value` values are non-decreasing in order of
#' `output_type_id`, using config-defined order. Returns rows where monotonicity
#' is violated.
#'
#' @param tbl A data frame for one or more CDF observation units.
#' @param output_type_ids A vector of expected `output_type_id` values in order.
#' @param config_tasks List of hub task configurations.
#' @param config_target_data Optional config from target-data.json.
#' @return A data frame of rows with decreasing oracle values, or `NULL`.
#' @noRd
#' @importFrom dplyr arrange filter mutate select ungroup all_of
check_oracle_value_cdf_crossing <- function(
  tbl,
  output_type_ids,
  config_tasks,
  config_target_data = NULL
) {
  tbl <- tbl[tbl$output_type_id %in% output_type_ids, ]

  if (nrow(tbl) == 0L) {
    return(NULL)
  }
  # Ensure output_type_id is a factor with levels in the order of output_type_ids
  # extracted from config and arrange in that order
  tbl[["output_type_id"]] <- factor(
    tbl[["output_type_id"]],
    levels = output_type_ids
  )
  # For oracle-output, as_of should NOT be included in grouping.
  # Oracle data is designed to contain a single version per observable unit
  # with a one-to-one mapping to model output data.
  tbl <- group_by_obs_unit(
    tbl,
    config_tasks,
    config_target_data,
    target_type = "oracle-output",
    include_as_of = FALSE
  ) |>
    arrange(.data[["output_type_id"]], .by_group = TRUE)

  mutate(
    tbl,
    # Identify any oracle values per observation unit that violate the CDF’s
    # non-decreasing constraint
    invalid = diff(
      c(0, .data[["oracle_value"]])
    ) <
      0L
  ) |>
    filter(.data[["invalid"]]) |>
    select(-all_of("invalid")) |>
    ungroup()
}

#' Format summary message for oracle value validation results.
#'
#' Constructs an inline-formatted summary message describing any validation
#' failures for `oracle_value` values in `cdf` or `pmf` outputs.
#'
#' @param check_vals A data frame of invalid oracle values, or `NULL`.
#' @param check_cdf A data frame of CDF violations, or `NULL`.
#' @param check_pmf A data frame of PMF sum violations, or `NULL`.
#' @return A single string summarizing issues, or `NULL` if all checks passed.
#' @noRd
#' @importFrom cli qty format_inline
details_summarise_oracle_value_checks <- function(
  check_vals,
  check_cdf,
  check_pmf
) {
  details <- NULL

  if (!is.null(check_vals)) {
    invalid_output_types <- unique(check_vals[["output_type"]]) # nolint: object_usage_linter
    invalid_vals <- unique(check_vals[["oracle_value"]]) # nolint: object_usage_linter
    details <- c(
      details,
      format_inline(
        "Invalid {.var oracle_value} {qty(length(invalid_vals))} value{?s}
        {.val {invalid_vals}} in {.val {invalid_output_types}} output type{?s}
        detected"
      )
    )
  }

  if (!is.null(check_cdf)) {
    details <- c(
      details,
      format_inline(
        "{.val cdf} oracle values that violate CDF non-decreasing constrain detected"
      )
    )
  }

  if (!is.null(check_pmf)) {
    details <- c(
      details,
      format_inline(
        "{.val pmf} oracle values that do not sum to 1 for each observation unit
        detected"
      )
    )
  }

  if (!is.null(details)) {
    details <- paste(
      c(
        details,
        format_inline("See {.var error_tbl} for details.")
      ),
      collapse = " | "
    )
  }
  details
}
