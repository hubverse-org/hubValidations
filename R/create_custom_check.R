#' Create a custom validation check function template file.
#'
#' @param name Character string. Name of the custom check function. We recommend
#' following the hubValidations package naming convention. For more details, consult the
#' article on [writing custom check functions](
#' https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html).
#' @param hub_path Character string. Path to the hub directory. Default is the
#' current working directory.
#' @param r_dir Character string. Path (relative to `hub_path`) to the directory
#' the custom check function file will be written to. Default is `src/validations/R`
#' which is the recommended directory for storing custom check functions.
#' @param error Logical. If `TRUE`, the custom check function will return a
#' `<error/check_error>` class object in the case of a failed check instead of the
#' default `<error/check_failure>`.
#' @param conditional Logical. If `TRUE`, the custom check function template will
#' include a block of code to check a condition before running the check. This is useful
#' when a check may need to be skipped based on a condition.
#' @param error_object Logical. If `TRUE`, the custom check function template will
#' include an error object that can be used to store additional information about the
#' properties of the object being checked that caused check failure. For example,
#' it could store the index of rows in a `tbl` that caused a check failure.
#' @param extra_args Logical. If `TRUE`, the custom check function template will
#' include an `extra_arg` template argument and template block of code to check
#' the input arguments of the custom check function.
#' @param overwrite Logical. If `TRUE`, the function will overwrite an existing
#'
#' @return Invisible `TRUE` if the custom check function file is created successfully.
#' @details
#' See the article on [writing custom check functions](
#' https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html)
#' for more.
#' @export
#'
#' @examples
#' withr::with_tempdir({
#'   # Create the custom check file with default settings.
#'   create_custom_check("check_default")
#'   cat(readLines("src/validations/R/check_default.R"), sep = "\n")
#'
#'  # Create fully featured custom check file.
#'   create_custom_check("check_full",
#'     error = TRUE, conditional = TRUE,
#'     error_object = TRUE, extra_args = TRUE
#'   )
#'   cat(readLines("src/validations/R/check_full.R"), sep = "\n")
#' })
create_custom_check <- function(name, hub_path = ".",
                                r_dir = "src/validations/R",
                                error = FALSE, conditional = FALSE,
                                error_object = FALSE, extra_args = FALSE,
                                overwrite = FALSE) {
  checkmate::assert_character(name, len = 1L)
  checkmate::assert_scalar(hub_path)
  checkmate::assert_scalar(r_dir)
  checkmate::assert_logical(error, len = 1L)
  checkmate::assert_logical(conditional, len = 1L)
  checkmate::assert_logical(error_object, len = 1L)
  checkmate::assert_logical(extra_args, len = 1L)
  checkmate::assert_logical(overwrite, len = 1L)

  # If hub_path not current working directory, prefix path to R dir with hub_path.
  if (hub_path != ".") {
    r_dir <- fs::path(hub_path, r_dir)
  }

  # Create the file path
  if (!fs::dir_exists(r_dir)) {
    fs::dir_create(r_dir, recurse = TRUE)
    cli::cli_alert_success("Directory {.path {r_dir}} created.")
  }

  check_path <- fs::path(r_dir, paste0(name, ".R"))
  if (fs::file_exists(check_path) && !overwrite) {
    cli::cli_abort("File {.path {check_path}} already exists.
                   Use {.code overwrite = TRUE} to overwrite.")
    return(invisible(FALSE))
  }

  data <- list(
    name = name,
    error = error,
    conditional = conditional,
    error_object = error_object,
    extra_args = extra_args
  )

  # Create the check template function and write to file
  template_fn <- create_template_fn(data)
  writeLines(template_fn, con = check_path)

  cli::cli_alert_success(
    "Custom validation check template function file {.val {name}.R} created."
  )
  cli::cli_bullets(c(">" = "Edit the function template to add your custom check logic."))
  cli::cli_alert_info(
    "See the {.field Writing custom check functions} article for more information.
    ({.url https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html})"
  )
  return(invisible(TRUE))
}

# Much of the following functionality is heavily based on usethis function `use_template()`
# licensed under MIT License. See
create_template_fn <- function(data) {
  template_path <- system.file("templates/custom_check_template",
    package = "hubValidations"
  )
  readLines(template_path, encoding = "UTF-8", warn = FALSE) |>
    whisker::whisker.render(data) |>
    strsplit("\n") |>
    unlist()
}
