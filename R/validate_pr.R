#' Validate pull request submission
#'
#' @param gh_repo GitHub repository address in the format `username/repo`
#' @param pr_number Number of the pull request to validate
#' @inheritParams validate_model_file
#'
#' @return An object of class `hub_validations`.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' validate_pr(
#'   hub_path = "."
#'   gh_repo = "Infectious-Disease-Modeling-Hubs/ci-testhub-simple",
#'   pr_number = 3
#' )
#' }
validate_pr <- function(hub_path = ".", gh_repo, pr_number) {
    model_output_dir <- get_hub_model_output_dir(hub_path)
    model_metadata_dir <- "model-metadata"

    validations <- list()

    tryCatch({

            pr_files <- gh::gh(
                "/repos/{gh_repo}/pulls/{pr_number}/files",
                gh_repo = gh_repo,
                pr_number = pr_number
            )

            pr_filenames <- purrr::map_chr(pr_files, ~.x$filename)
            model_output_files <- get_pr_dir_files(pr_filenames,
                                                   model_output_dir)
            model_metadata_files <- get_pr_dir_files(pr_filenames,
                                                     model_metadata_dir)
            validations <- c(
                validations,
                purrr::map(model_output_files,
                           ~validate_submission(hub_path, file_path = .x)
                ) %>% purrr::list_flatten(),
                purrr::map(model_metadata_files,
                           ~validate_model_metadata(hub_path, file_path = .x)
                ) %>% purrr::list_flatten()
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
        validations <<- c(validations, list(e))
    })

    class(validations) <- c("hub_validations", "list")
    return(validations)
}

get_pr_dir_files <- function(pr_filenames, dir_name) {
    pr_filenames[
        fs::path_has_parent(pr_filenames, dir_name)
    ] %>% fs::path_rel(dir_name)
}
