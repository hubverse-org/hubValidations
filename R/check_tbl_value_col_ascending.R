check_tbl_value_col_ascending <- function(tbl, file_path) {

    output_type_tbl <- split(tbl, tbl$output_type)[c("cdf", "quantile")] %>%
        purrr::compact()

    if (length(output_type_tbl) == 0L) {
        return(NULL)
    }

     non_asc_df <- purrr::map(
         output_type_tbl,
         check_values_ascending) %>%
         purrr::list_rbind()

    check <- nrow(non_asc_df) == 0L

    if (check) {
        details <- NULL
        non_asc_df <- NULL
    } else {
        details <- cli::format_inline("See {.var non_ascending} attribute for details.")
    }

    capture_check_cnd(
        check = check,
        file_path = file_path,
        msg_subject = "For each unique task ID value/output type combination,",
        msg_verbs = c("all values non-decreasing", "decreasing values detected"),
        msg_attribute = "as output_type_ids increase.",
        details = details,
        non_ascending = non_asc_df)
}


check_values_ascending <- function(tbl) {
    group_cols <- names(tbl)[!names(tbl) %in% hubUtils::std_colnames]
    tbl[["value"]] <- as.numeric(tbl[["value"]])

    check_tbl <- dplyr::group_by(tbl, dplyr::across(dplyr::all_of(group_cols))) %>%
        dplyr::arrange("output_type_id", .by_group = TRUE) %>%
        dplyr::summarise(non_asc = any(diff(.data[["value"]]) < 0))

    if (!any(check_tbl$non_asc)) {
        return(NULL)
    }

    output_type <- unique(tbl["output_type"])

    dplyr::filter(check_tbl, .data[["non_asc"]]) %>%
        dplyr::select(-dplyr::all_of("non_asc")) %>%
        dplyr::ungroup() %>%
        dplyr::mutate(.env$output_type)
}
