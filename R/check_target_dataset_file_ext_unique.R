#' Check that all files of a given target type share a single unique file format
#'
#' @inheritParams hubData::get_target_path
#' @inherit check_tbl_col_types return
#' @export
check_target_dataset_file_ext_unique <- function(hub_path,
                                                 target_type = c(
                                                   "time-series", "oracle-output"
                                                 )) {
  target_type <- rlang::arg_match(target_type)
  target_path <- hubData::get_target_path(hub_path, target_type)
  file_path <- fs::path("target-data", target_type)

  if (length(target_path) == 0L) {
    return(
      capture_check_info(
        file_path = file_path,
        cli::format_inline("No {.field {target_type}} target type files detected in
        {.code target-data} directory. Check skipped.")
      )
    )
  }

  ext <- purrr::map(
    target_path,
    ~ hubData::get_target_file_ext(hub_path, .x)
  ) |>
    purrr::flatten_chr() |>
    unique()

  check <- length(ext) == 1L
  details <- NULL

  if (!check) {
    details <- cli::format_inline(
      "Multiple {.field {target_type}} file extensions found:
      {.val {ext}}."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "{.field {target_type}} dataset files"
    ),
    msg_attribute = "single unique file format.",
    msg_verbs = c("share", "must share"),
    error = FALSE,
    details = details
  )
}
