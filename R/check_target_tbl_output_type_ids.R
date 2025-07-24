#' Check that output type ID values in a target data file are valid and complete
#'
#' This check is only performed when the target data file contains an
#' `output_type_id` column. It verifies that non-distributional
#' output types have all NA output type IDs, and that distributional output types
#' (`cdf`, `pmf`) include the complete output_type_id set defined in the hub config.
#' @param target_type Type of target data to validate. One of `"time-series"` or
#' `"oracle-output"`. Defaults to `"oracle-output"`.
#' @inheritParams check_target_tbl_values
#' @inherit check_tbl_colnames params return
#' @export
check_target_tbl_output_type_ids <- function(
  target_tbl_chr,
  target_type = c(
    "oracle-output",
    "time-series"
  ),
  file_path,
  hub_path
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
  if (!has_output_type_ids(target_tbl_chr)) {
    return(
      capture_check_info(
        file_path,
        msg = cli::format_inline(
          "Target table does not have {.code output_type_id} column. Check skipped."
        )
      )
    )
  }
  details <- NULL
  missing <- NULL

  if (!has_distributional(target_tbl_chr)) {
    # If no distributional output types (i.e. no pmf or cdf), just check that all
    # output_type_id values are NA
    check <- has_all_na_output_type_ids(target_tbl_chr)
    if (!check) {
      invalid_output_types <- has_non_na_output_type_ids(target_tbl_chr)
      details <- cli::format_inline(
        "Non-{.code NA} output type ID values detected for output type{?s} {.val {invalid_output_types}}."
      )
    }
  } else {
    config_tasks <- read_config(hub_path)
    output_types <- unique(target_tbl_chr[["output_type"]])

    # If target data contain a distributional output type (i.e. pmf or cdf),
    # validate each output type separately.
    check_list <- purrr::map(
      purrr::set_names(output_types),
      \(.x) check_td_output_type_ids(.x, target_tbl_chr, config_tasks)
    )
    invalid_output_types <- !purrr::map_lgl(check_list, "check")
    check <- !any(invalid_output_types)

    if (!check) {
      details <- details_summarise_non_dist(invalid_output_types)
      # Process missing output_type_id value rows
      missing <- rbind_missing(check_list)
      details <- c(details, details_summarise_missing(missing))
    }
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "{.field oracle-output} {.var target_tbl}"
    ),
    msg_attribute = "",
    msg_verbs = c(
      "contains valid complete output_type_id values.",
      "does not contain valid complete output_type_id values."
    ),
    missing = missing,
    details = details,
    error = TRUE
  )
}

#' Check output type IDs for a specific output type
#'
#' @param output_type A single output type string (e.g., "cdf", "pmf", or other).
#' @param target_tbl_chr Data frame filtered to rows with that output_type.
#' @param config_tasks List of task configurations obtained from hub config.
#' @return A list with elements `check` (logical) and `missing` (data.frame or NULL).
#' @noRd
check_td_output_type_ids <- function(
  output_type,
  target_tbl_chr,
  config_tasks
) {
  tbl <- target_tbl_chr[target_tbl_chr$output_type == output_type, ]
  if (!is_distributional(output_type)) {
    check <- has_all_na_output_type_ids(tbl)
    list(
      check = check,
      missing = NULL
    )
  } else {
    check_dist_output_type_ids(output_type, tbl, config_tasks)
  }
}
#' Check distributional output type IDs against configuration `output_type_id` set
#'
#' @param output_type A distributional type ("cdf" or "pmf").
#' @param tbl Data frame filtered to that output_type.
#' @param config_tasks List of task configurations with expected support values.
#' @return A list with elements `check` (logical) and `missing` (data.frame or NULL).
#' @noRd
check_dist_output_type_ids <- function(
  output_type = c("cdf", "pmf"),
  tbl,
  config_tasks
) {
  output_type <- rlang::arg_match(output_type)

  # Gather expected unique vectors of output_type_id values from config
  output_type_ids <- extract_output_type_id_vals(
    output_type = output_type,
    tbl = tbl,
    config_tasks = config_tasks
  ) |>
    unique()

  # Identify any missing output_type id values per unique combinations of
  # values in columns that belong to the observation unit
  missing <- purrr::map(
    output_type_ids,
    ~ diff_output_type_ids(
      tbl = tbl,
      output_type_ids = .x,
      config_tasks
    )
  ) |>
    purrr::compact() |>
    purrr::list_rbind()

  check <- nrow(missing) == 0
  if (check) {
    missing <- NULL
  }

  list(
    check = check,
    missing = missing
  )
}
#' Identify missing output_type_id values for a specific target unit
#'
#' @param tbl Data frame for that target and output type.
#' @param output_type_ids Expected vector of output_type_id values.
#' @param config_tasks List of hub configuration tasks.
#' @return A data frame of missing support rows, grouped by non-unique columns.
#' @importFrom dplyr group_by across all_of reframe
#' @noRd
diff_output_type_ids <- function(tbl, output_type_ids, config_tasks) {
  tbl <- tbl[tbl$output_type_id %in% output_type_ids, ]
  if (nrow(tbl) == 0L) {
    return(NULL)
  }
  # TODO: eventually the obs_unit will be defined in the target-data.json config
  # file
  tbl <- group_by_obs_unit(tbl, config_tasks)

  reframe(
    tbl,
    output_type = unique(.data[["output_type"]]),
    output_type_id = setdiff(
      output_type_ids,
      .data[["output_type_id"]]
    )
  )
}

#' Extract expected output_type_id values from config and target data
#'
#' @param output_type A distributional type string, e.g. "cdf" or "pmf".
#' @param tbl A data frame for that output type.
#' @param config_tasks List of hub configuration tasks.
#' @return A named list mapping target IDs to their expected support vectors.
#' @noRd
extract_output_type_id_vals <- function(output_type = NULL, tbl, config_tasks) {
  vals <- extract_target_data_vals(
    config_tasks,
    tbl,
    output_type = output_type,
    intersect = FALSE,
    collapse = FALSE
  )
  purrr::map(vals, "output_type_id")
}

#' Summarise output_type_id values in a table
#'
#' @param tbl A data frame potentially containing `output_type_id` and `output_type`.
#' @return A summary tibble of unique IDs per output type or NULL if none.
#' @importFrom dplyr summarise
#' @noRd
summarise_output_type_ids <- function(tbl) {
  if (!has_output_type_ids(tbl)) {
    return(NULL)
  }
  if (!has_distributional(tbl)) {
    return(
      summarise(
        tbl,
        output_type = unique(.data[["output_type"]]),
        output_type_id = unique(.data[["output_type_id"]])
      )
    )
  }

  group_by(tbl, .data[["output_type"]]) |>
    summarise(
      output_type_id = list(unique(.data[["output_type_id"]])),
      .groups = "drop"
    )
}
#' Format details for non-distributional output types with invalid IDs
#'
#' @param invalid_output_types Named logical vector of types with invalid flags.
#' @return A formatted message string or NULL.
#' @noRd
details_summarise_non_dist <- function(invalid_output_types) {
  if (length(invalid_output_types) == 0L) {
    return(NULL)
  }
  non_dist <- !is_distributional(names(invalid_output_types))
  invalid_non_dist <- names(non_dist[non_dist & invalid_output_types])

  if (length(invalid_non_dist) == 0L) {
    NULL
  } else {
    cli::format_inline(
      "Non-{.code NA} output type ID values detected for output type{?s} {.val {invalid_non_dist}}."
    )
  }
}

#' Combine missing data frames from a list of checks
#'
#' @param check_list List of results from distributional checks, each with a `missing` element.
#' @return A combined data frame of all missing entries or NULL.
#' @noRd
rbind_missing <- function(check_list) {
  missing <- purrr::map(check_list, "missing") |>
    purrr::compact()

  if (length(missing) == 0L) {
    NULL
  } else {
    purrr::list_rbind(missing)
  }
}

#' Format details for missing output_type_id values in distributional types
#'
#' @param missing A data frame of missing output support rows.
#' @return A formatted message string or NULL.
#' @noRd
details_summarise_missing <- function(missing) {
  if (is.null(missing)) {
    return(NULL)
  }
  cli::format_inline(
    "Missing output type ID values detected for output type{?s}
    {.val {unique(missing$output_type)}}. See {.var missing} for details."
  )
}
