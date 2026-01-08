#' Check model output data tbl round ID matches submission round ID.
#'
#' @inherit check_tbl_unique_round_id params details return
#' @export
check_tbl_match_round_id <- function(
  tbl,
  file_path,
  hub_path,
  round_id_col = NULL
) {
  check_round_id_col <- check_valid_round_id_col(
    tbl,
    file_path,
    hub_path,
    round_id_col
  )

  if (is_info(check_round_id_col)) {
    return(check_round_id_col)
  }
  if (is_failure(check_round_id_col) || is_exec_error(check_round_id_col)) {
    class(check_round_id_col)[1] <- "check_error"
    check_round_id_col$call <- rlang::call_name(rlang::current_call())
    return(check_round_id_col)
  }

  if (is.null(round_id_col)) {
    round_id_col <- get_file_round_id_col(file_path, hub_path)
  }
  round_id <- parse_file_name(file_path)$round_id

  round_id_match <- tbl[[round_id_col]] == round_id
  check <- all(round_id_match)

  if (check) {
    details <- NULL
  } else {
    unmatched_round_ids <- unique(tbl[[round_id_col]][!round_id_match]) # nolint: object_usage_linter
    details <- cli::format_inline(
      "{.var round_id} {cli::qty(length(unmatched_round_ids))}
            value{?s} {.val {unmatched_round_ids}} {?does/do} not match
            submission {.var round_id} {.val {round_id}}"
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "All {.var round_id_col} {.val {round_id_col}} values"
    ),
    msg_attribute = "submission {.var round_id} from file name.",
    msg_verbs = c("match", "must match"),
    error = TRUE,
    details = details
  )
}
