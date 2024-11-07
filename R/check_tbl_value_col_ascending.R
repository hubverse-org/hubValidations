#' Check that `quantile` and `cdf` output type values of model output data
#' are non-descending
#'
#' Checks that values in the `value` column for `quantile` and `cdf` output type
#' data for each unique task ID/output type combination
#' are non-descending when arranged by increasing `output_type_id` order.
#' Check only performed if `tbl` contains `quantile` or `cdf` output type data.
#' If not, the check is skipped and a `<message/check_info>` condition class
#' object is returned.
#'
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
check_tbl_value_col_ascending <- function(tbl, file_path, hub_path, round_id) {

  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  # Coerce accepted vals to character for easier comparison of
  # values. Tried to use arrow tbls for comparisons as more efficient when
  # working with larger files but currently arrow does not match NAs as dplyr
  # does, returning false positives for mean & median rows which contain NA in
  # output type ID column.
  accepted_vals <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    all_character = TRUE
  )
  if (all(!c("cdf", "quantile") %in% tbl[["output_type"]])) {
    return(
      capture_check_info(
        file_path,
        "No quantile or cdf output types to check for non-descending values.
        Check skipped."
      )
    )
  }

  # FIX for <https://github.com/hubverse-org/hubValidations/issues/78>
  # sort the table by config by merging from config ----------------
  tbl_sorted <- order_output_type_ids(tbl, accepted_vals, c("cdf", "quantile"))
  output_type_tbl <- split_cdf_quantile(tbl_sorted)

  error_tbl <- purrr::map(
    output_type_tbl,
    check_values_ascending
  ) %>%
    purrr::list_rbind()

  check <- nrow(error_tbl) == 0L

  if (check) {
    details <- NULL
    error_tbl <- NULL
  } else {
    details <- cli::format_inline("See {.var error_tbl} attribute for details.")
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Values in {.var value} column",
    msg_verbs = c("are non-decreasing", "are not non-decreasing"),
    msg_attribute = "as output_type_ids increase for all unique task ID
    value/output type combinations of quantile or cdf output types.",
    details = details,
    error_tbl = error_tbl
  )
}


check_values_ascending <- function(tbl) {
  group_cols <- names(tbl)[!names(tbl) %in% hubUtils::std_colnames]
  tbl[["value"]] <- as.numeric(tbl[["value"]])

  # group by all of the target columns
  check_tbl <- dplyr::group_by(tbl, dplyr::across(dplyr::all_of(group_cols))) %>%
    dplyr::summarise(non_asc = any(diff(.data[["value"]]) < 0))

  if (!any(check_tbl$non_asc)) {
    return(NULL)
  }

  output_type <- unique(tbl["output_type"]) # nolint: object_usage_linter

  dplyr::filter(check_tbl, .data[["non_asc"]]) %>%
    dplyr::select(-dplyr::all_of("non_asc")) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(.env$output_type)
}

split_cdf_quantile <- function(tbl) {
  split(tbl, tbl[["output_type"]])[c("cdf", "quantile")] %>%
    purrr::compact()
}

# Order the output type ids in the order of the config
#
# This extracts the output_type_id from the config-generated table for the
# given types and creates a lookup table that has the types in the right order. 
#
# The data from `tbl` is then joined into the lookup table (after being coerced
# to character), which sorts `tbl` in the order of the lookup table.
#
# NOTE: this assumes that the cdf and quantile values in the `tbl` are complete.
order_output_type_ids <- function(tbl, config, types = c("cdf", "quantile")) {
  # step 1: create a lookup table from the config
  order_ref <- config[c("output_type", "output_type_id")]
  cdf_and_quantile <- order_ref$output_type %in% types
  order_ref <- order_ref[cdf_and_quantile, , drop = FALSE]
  order_ref <- unique(order_ref)
  # step 2: join
  tbl$output_type_id <- as.character(tbl$output_type_id)
  dplyr::inner_join(order_ref, tbl, by = c("output_type", "output_type_id"))
}
