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

  invalid_row_idx <- which_invalid_rows(
    tbl,
    config_tasks = config_tasks,
    round_id = round_id,
    derived_task_ids = derived_task_ids
  )
  check <- length(invalid_row_idx) == 0L

  if (check) {
    details <- NULL
    error_tbl <- NULL
  } else {
    invalid_tbl <- tbl[invalid_row_idx, names(tbl) != "value"]
    error_summary <- summarise_invalid_values(
      invalid_tbl,
      invalid_row_idx,
      config_tasks,
      round_id,
      derived_task_ids
    )
    details <- error_summary$msg
    if (length(error_summary$comb_rows) == 0L) {
      error_tbl <- NULL
    } else {
      error_tbl <- invalid_tbl[error_summary$comb_rows, ]
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

#' Find the rows of `tbl` that no modeling task allows
#'
#' A row holds a valid combination when a single modeling task allows every one
#' of its values. `which_mt_rows()` answers that for one modeling task at a
#' time, so the combinations themselves are never built.
#'
#' @param tbl a tibble/data.frame of the contents of the file being validated.
#' Column types must **all be character**.
#' @inheritParams expand_model_out_grid
#'
#' @returns An integer vector of row indexes into `tbl`, ascending.
#' @noRd
which_invalid_rows <- function(tbl, config_tasks, round_id, derived_task_ids) {
  call <- rlang::caller_env()
  value_sets <- get_config_mt_value_sets(
    config_tasks = config_tasks,
    round_id = round_id,
    derived_task_ids = derived_task_ids,
    call = call
  )
  check_match_cols(tbl, config_tasks, round_id, call = call)

  valid <- logical(nrow(tbl))
  for (mt in value_sets) {
    valid[which_mt_rows(tbl, mt, derived_task_ids)] <- TRUE
    # A row that has matched stays matched, so once every row has, the
    # remaining modeling tasks cannot change the result.
    if (all(valid)) {
      break
    }
  }
  which(!valid)
}

#' Build the message details and `error_tbl` rows for a failed check
#'
#' A rejected row is reported in one of two ways. A value the config does not
#' list for the column it appears in is reported as an invalid value, naming
#' the column and the value. A row whose values are each valid, but which no
#' single modeling task allows together, is reported as an invalid combination,
#' naming the row and returning it in `error_tbl`.
#'
#' Note that a row can qualify for both. It is then reported only as an invalid
#' value, which is the more specific of the two explanations.
#'
#' @param invalid_tbl The rows of the submission that no modeling task allows,
#' without the `value` column. Column types must **all be character**.
#' @param invalid_row_idx Integer vector of the rows of the submission that
#' `invalid_tbl` holds, so that a row can be reported by its number in the file.
#' @inheritParams expand_model_out_grid
#'
#' @returns A list of:
#' - `msg`: the details appended to the check's message.
#' - `comb_rows`: integer vector of the rows of `invalid_tbl` to return in
#'   `error_tbl`, which are the invalid combinations. An invalid value needs no
#'   table, because the message already names the column and the value.
#' @noRd
summarise_invalid_values <- function(
  invalid_tbl,
  invalid_row_idx,
  config_tasks,
  round_id,
  derived_task_ids
) {
  # Two kinds of value are left out, for different reasons. A sample's
  # `output_type_id` is an identifier the submitter chose, so the config
  # enumerates no values to compare it against. The config does list values for
  # a derived task ID, but this check ignores derived task IDs, and
  # `get_round_config_values()` is asked to return `NA` for them, so comparing
  # them would report every derived value as invalid.
  #
  # Note that the sample entries are blanked rather than their column dropped,
  # because `output_type_id` also carries the enumerated IDs of every other
  # output type.
  vals <- as.list(invalid_tbl[setdiff(names(invalid_tbl), derived_task_ids)])
  output_type <- hubUtils::std_colnames[["output_type"]]
  output_type_id <- hubUtils::std_colnames[["output_type_id"]]
  is_sample <- invalid_tbl[[output_type]] == "sample"
  if (any(is_sample)) {
    vals[[output_type_id]][is_sample] <- NA_character_
  }

  uniq_config <- get_round_config_values(
    config_tasks,
    round_id,
    derived_task_ids
  )[names(vals)]

  invalid_vals <- purrr::map2(
    purrr::map(vals, unique),
    uniq_config,
    ~ .x[!.x %in% .y]
  ) |>
    purrr::compact()

  if (length(invalid_vals) != 0L) {
    invalid_vals_msg <- purrr::imap_chr(
      invalid_vals,
      ~ cli::format_inline(
        "Column {.var {.y}} contains invalid {cli::qty(length(.x))}
        value{?s} {.val {.x}}."
      )
    ) |>
      paste(collapse = " ")
  } else {
    invalid_vals_msg <- NULL
  }

  # A row already reported for an invalid value is not reported a second time
  # as an invalid combination. What is left is every other rejected row.
  reported <- purrr::imap(invalid_vals, ~ which(vals[[.y]] %in% .x)) |>
    unlist(use.names = FALSE) |>
    unique()
  comb_rows <- setdiff(seq_len(nrow(invalid_tbl)), reported)
  if (length(comb_rows) == 0L) {
    invalid_combs_msg <- NULL
  } else {
    comb_row_idx <- invalid_row_idx[comb_rows] # nolint: object_usage_linter
    invalid_combs_msg <- cli::format_inline(
      "Additionally {cli::qty(length(comb_row_idx))} row{?s}
      {.val {comb_row_idx}} {cli::qty(length(comb_row_idx))}
      {?contains/contain} invalid combinations of valid values.
      See {.var error_tbl} for details."
    )
  }
  list(
    msg = paste(invalid_vals_msg, invalid_combs_msg, sep = "\n"),
    comb_rows = comb_rows
  )
}
