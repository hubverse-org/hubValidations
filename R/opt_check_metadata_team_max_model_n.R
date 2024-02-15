#' Check that submitting team does not exceed maximum number of allowed models
#' per team
#'
#' @inherit check_metadata_file_exists params
#' @param n_max Integer. Number of maximum allowed models per team.
#' @inherit check_tbl_col_types return
#' @details
#' Should be deployed as part of `validate_model_metadata` optional checks.
#'
#'
#' @export
opt_check_metadata_team_max_model_n <- function(file_path, hub_path, n_max = 2L) {
  team_abbr <- parse_file_name(
    file_path,
    file_type = "model_metadata"
  )$team_abbr
  all_model_meta <- hubUtils::load_model_metadata(hub_path)

  team_models <- all_model_meta[["model_abbr"]][all_model_meta[["team_abbr"]] == team_abbr]
  n_models <- length(team_models)
  check <- isFALSE(n_models > n_max)
  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "Team {.val {team_abbr}} has submitted valid metadata for
            {.val {n_models}} model{?s}:
            {.val {team_models}}."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = cli::format_inline(
      "Maximum number of models per team ({.val {n_max}})"
    ),
    msg_attribute = "exceeded.",
    msg_verbs = c("not", ""),
    details = details
  )
}
