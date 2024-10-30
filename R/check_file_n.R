#' Check number of files submitted per round does not exceed the allowed number
#' of submissions per team.
#'
#' @inheritParams check_tbl_col_types
#' @param allowed_n integer(1). The maximum number of files allowed per round.
#' @inherit check_tbl_col_types return
#'
#' @export
check_file_n <- function(file_path, hub_path, allowed_n = 1L) {
  checkmate::assert_integer(allowed_n, lower = 1L, len = 1L)
  file_name <- basename(file_path)
  file_name_sans_ext <- fs::path_ext_remove(file_name)
  team_dir <- dirname(abs_file_path(file_path, hub_path))

  existing_files <- fs::dir_ls(team_dir, regex = file_name_sans_ext) |>
    fs::path_rel(dirname(team_dir)) |>
    setdiff(file_path) # Remove file being validated from check
  existing_n <- length(existing_files)

  check <- existing_n < allowed_n

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "Should be {.val {allowed_n}} but {cli::qty(existing_n)} pre-existing round
    submission file{?s} {.val {existing_files}} found in team directory."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Number of accepted model output files per round",
    msg_verbs = c("met.", "exceeded."),
    msg_attribute = NULL,
    error = FALSE,
    details = details
  )
}
