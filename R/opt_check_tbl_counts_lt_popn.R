#' Check that predicted values per location are less than total location population.
#'
#' @param targets Either a single target key list or a list of multiple target key lists.
#' @param popn_file_path Character string.
#' Path to population data relative to the hub root.
#' Defaults to `auxiliary-data/locations.csv`.
#' @param popn_col Character string.
#' The name of the population size column in the population data set.
#' @param location_col Character string.
#' The name of the location column.
#' Used to join population data to submission file data.
#' Must be shared by both files.
#' @details
#' Should only be applied to rows containing count predictions. Use argument
#' `targets` to filter `tbl` data to appropriate count target rows.
#'
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_col_types return
#' @export
#' @examples
#' hub_path <- system.file("testhubs/flusight", package = "hubValidations")
#' file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
#' tbl <- hubValidations::read_model_out_file(file_path, hub_path)
#' # Single target key list
#' targets <- list("target" = "wk ahead inc flu hosp")
#' opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets)
opt_check_tbl_counts_lt_popn <- function(tbl, file_path, hub_path, targets = NULL,
                                         popn_file_path = "auxiliary-data/locations.csv",
                                         popn_col = "population",
                                         location_col = "location") {
  checkmate::assert_choice(location_col, choices = names(tbl))
  tbl$row_id <- seq_along(tbl[[location_col]])

  if (!is.null(targets)) {
    assert_target_keys(targets, hub_path, file_path)
    tbl <- filter_targets(tbl, targets)
    if (nrow(tbl) == 0L) {
      return(
        capture_check_info(
          file_path,
          msg = "Target filtering returned tbl with zero rows. Check skipped."
        )
      )
    }
  }

  popn_full_path <- fs::path(hub_path, popn_file_path)
  if (!fs::file_exists(popn_full_path)) {
    cli::cli_abort(
      "File not found at {.path {popn_file_path}}"
    )
  }
  popn <- switch(fs::path_ext(popn_full_path),
    csv = arrow::read_csv_arrow(popn_full_path),
    parquet = arrow::read_parquet(popn_full_path),
    arrow = arrow::read_feather(popn_full_path)
  )
  checkmate::assert_choice(location_col, choices = names(popn))
  checkmate::assert_choice(popn_col, choices = names(popn))
  popn <- popn[, c(location_col, popn_col)]

  tbl <- dplyr::left_join(tbl, popn, by = location_col)

  if (any(is.na(tbl[[popn_col]]))) {
    invalid_location <- unique(tbl[[location_col]][is.na(tbl[[popn_col]])])
    cli::cli_abort(
      "No match for {cli::qty(length(invalid_location))} location{?s}
          {.val {invalid_location}} found in {.path {popn_file_path}}"
    )
  }

  compare <- tbl[["value"]] < tbl[[popn_col]]
  check <- all(compare)

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline("Affected rows: {.val {tbl$row_id[!compare]}}.")
  }

  n_loc <- length(unique(tbl[[location_col]]))

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Target counts ",
    msg_verbs = c("are", "must be"),
    msg_attribute = cli::format_inline(
      "{cli::qty(n_loc)} less than location population size{?s}."
    ),
    details = details
  )
}

assert_target_keys <- function(targets, hub_path, file_path) {
  single_tk <- purrr::pluck_depth(targets) == 2L
  if (single_tk) {
    valid_target_keys <- validate_target_key(targets, hub_path, file_path)
  } else {
    valid_target_keys <- purrr::map_lgl(
      targets, ~ validate_target_key(.x, hub_path, file_path)
    )
  }
  if (all(valid_target_keys)) {
    return(invisible(TRUE))
  }
  if (single_tk) {
    cli::cli_abort("Target does not match any round target keys.")
  } else {
    n <- sum(valid_target_keys)
    cli::cli_abort("{cli::qty(n)}Target{?s} with ind{?ex/ices}
                       {.val {which(!valid_target_keys)}}
                       {cli::qty(n)} do{?es/} not match any round target keys.")
  }
}

validate_target_key <- function(target, hub_path, file_path) {
  any(purrr::map_lgl(
    get_file_target_metadata(hub_path, file_path),
    ~ identical(.x, target)
  ))
}

filter_expr <- function(filter) {
  paste(paste0(".data$", names(filter)),
    filter,
    sep = " %in% "
  ) %>%
    paste(collapse = ";") %>%
    rlang::parse_exprs()
}

#' @importFrom rlang !!!
filter_targets <- function(tbl, targets) {
  if (purrr::pluck_depth(targets) == 2L) {
    targets <- purrr::map_if(
      targets,
      ~ is.character(.x) && length(.x) == 1L,
      ~ paste0("'", .x, "'")
    )
    dplyr::filter(tbl, !!!filter_expr(targets))
  } else {
    purrr::map(
      targets,
      ~ dplyr::filter(tbl, !!!filter_expr(.x))
    ) %>% purrr::list_rbind()
  }
}
