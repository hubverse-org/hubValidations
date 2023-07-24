check_tbl_unique_round_id <- function(tbl, round_id_col, file_path) {

    round_id_col <- rlang::arg_match(round_id_col, values = names(tbl))

    unique_round_ids <- unique(tbl[[round_id_col]])
    check <- length(unique_round_ids) == 1L

    if (check) {
        details <- NULL
    } else {
        details <- cli::format_inline(
            "Column actually contains {.val {length(unique_round_ids)}}
            round ID values, {.val {unique_round_ids}}")
    }

    capture_check_cnd(check = check,
                      file_path = file_path,
                      msg_subject = cli::format_inline("{.var round_id} column
                                                       {.val {round_id_col}}"),
                      msg_attribute = "a single, unique round ID value.",
                      msg_verbs = c("contains", "must contain"),
                      error = TRUE,
                      details = details)
}




