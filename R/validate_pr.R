#' Validate Pull Request
#'
#' @param gh_repo GitHub repository address in the format `username/repo`
#' @param pr_number Number of the pull request to validate
#' @param round_id_col Character string. The name of the column containing
#' `round_id`s. Only required if files contain a column that contains `round_id`
#' details but has not been configured via `round_id_from_variable: true` and
#' `round_id:` in in hub `tasks.json` config file.
#' @inheritParams validate_model_file
#' @inheritParams validate_submission
#'
#' @return An object of class `hub_validations`.
#' @export
#'
#' @examples
#' \dontrun{
#' validate_pr(
#'   hub_path = ".",
#'   gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
#'   pr_number = 3
#' )
#' }
validate_pr <- function(hub_path = ".", gh_repo, pr_number,
                        round_id_col = NULL, validations_cfg_path = NULL,
                        skip_submit_window_check = FALSE) {
  model_output_dir <- get_hub_model_output_dir(hub_path)
  model_metadata_dir <- "model-metadata"
  validations <- new_hub_validations()

  validations$valid_config <- try_check(check_config_hub_valid(hub_path),
    file_path = basename(hub_path)
  )
  if (is_any_error(validations$valid_config)) {
    return(validations)
  }

  tryCatch(
    {
      pr_files <- gh::gh(
        "/repos/{gh_repo}/pulls/{pr_number}/files",
        gh_repo = gh_repo,
        pr_number = pr_number
      )
      pr_filenames <- purrr::map_chr(pr_files, ~ .x$filename)
      model_output_files <- get_pr_dir_files(
        pr_filenames,
        model_output_dir
      )
      model_metadata_files <- get_pr_dir_files(
        pr_filenames,
        model_metadata_dir
      )

      model_output_vals <- purrr::map(
        model_output_files,
        ~ validate_submission(
          hub_path,
          file_path = .x,
          validations_cfg_path = validations_cfg_path,
          skip_submit_window_check = skip_submit_window_check,
          skip_check_config = TRUE
        )
      ) %>%
        purrr::list_flatten() %>%
        as_hub_validations()

      model_metadata_vals <- purrr::map(
        model_metadata_files,
        ~ validate_model_metadata(
          hub_path,
          file_path = .x,
          validations_cfg_path = validations_cfg_path
        )
      ) %>%
        purrr::list_flatten() %>%
        as_hub_validations()

      validations <- combine(
        validations,
        model_output_vals,
        model_metadata_vals
      )
    },
    error = function(e) {
      # This handler is used when an unrecoverable error is thrown. This can
      # happen when, e.g., the csv file cannot be parsed by read_csv(). In this
      # situation, we want to output all the validations until this point plus
      # this "unrecoverable" error.
      e <- capture_exec_error(
        file_path = gh_repo,
        msg = conditionMessage(e)
      )
      validations <<- combine(
        validations,
        new_hub_validations(e)
      )
    }
  )

  inform_unvalidated_files(
    model_output_files,
    model_metadata_files,
    pr_filenames
  )
  return(validations)
}

get_pr_dir_files <- function(pr_filenames, dir_name) {
  pr_filenames[
    fs::path_has_parent(pr_filenames, dir_name)
  ] %>% fs::path_rel(dir_name)
}

inform_unvalidated_files <- function(model_output_files,
                                     model_metadata_files,
                                     pr_filenames) {
  validated_files <- c(model_output_files, model_metadata_files)
  if (length(pr_filenames) != length(validated_files)) {
    validated_idx <- purrr::map_int(
      validated_files,
      ~ grep(.x, pr_files, fixed = TRUE)
    )
    cli::cli_inform(
      "PR contains commits to additional files which have not been checked:
          {.val {pr_filenames[-validated_idx]}}."
    )
  }
}
