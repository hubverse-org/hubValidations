#' Print results of `validate_...()` function as a bullet list
#'
#' @param x An object of class `hub_validations` or any of it's subclasses.
#' @param ... Unused argument present for class consistency
#'
#'
#' @export
print.hub_validations <- function(x, ...) {
  if (length(x) == 0L) {
    msg <- cli::format_inline("Empty {.cls {class(x)[1]}}")
    cli::cli_inform(msg)
  } else {
    print_file <- function(file_name, x) {
      x <- x[get_filenames(x) == file_name]
      msg <- stats::setNames(
        paste(
          apply_cli_span_class(names(x), class = "check_name"),
          purrr::map_chr(x, "message"),
          sep = ": "
        ),
        dplyr::case_when(
          is_check_class(x, "check_success") ~ "v",
          is_check_class(x, "check_failure") ~ "x",
          is_check_class(x, "check_exec_warn") ~ "!",
          is_check_class(x, "check_error") ~ "circle_cross",
          is_check_class(x, "check_exec_error") ~ "lower_block_8",
          is_check_class(x, "check_info") ~ "i",
          TRUE ~ "*"
        )
      )

      cli::cli_div(class = "hub_validations", theme = hub_validation_theme)
      cli::cli_h2(file_name)
      cli::cli_inform(msg)
      cli::cli_end()
    }

    purrr::walk(
      .x = get_filenames(x, unique = TRUE),
      .f = function(file_name, x) print_file(file_name, x),
      x = x
    )
  }
}

# TODO: Code to consider implementing more hierarchical printing of messages.
# Currently not implemented as pr_hub_validations class not implemented.
#' Print results of `validate_pr()` function as a bullet list
#'
#' @param x An object of class `pr_hub_validations`
#' @param ... Unused argument present for class consistency
#'
#'
#' @export
print.pr_hub_validations <- function(x, ...) {
  purrr::map(x, print)
}


# cli theme for hub_validations objects that add a circle cross to be applied
# to check_error objects
hub_validation_theme <- list(
  ".bullets .bullet-circle_cross" = list(
    "before" = function(x) {
      paste0(cli::col_red(cli::symbol$circle_cross), " ")
    },
    "text-exdent" = 2L
  ),
  ".bullets .bullet-checkbox_on" = list(
    "before" = function(x) {
      paste0(cli::col_red(cli::symbol$checkbox_on), " ")
    },
    "text-exdent" = 2L
  ),
  "span.check_name" = list(
    "before" = "[",
    "after" = "]",
    color = "grey"
  ),
  "h2" = list(
    fmt = function(x) {
      cli::col_magenta(
        paste0(
          cli::symbol$line,
          cli::symbol$line,
          " ",
          cli::style_underline(x),
          " ",
          cli::symbol$line,
          cli::symbol$line,
          cli::symbol$line,
          cli::symbol$line
        )
      )
    }
  )
)

apply_cli_span_class <- function(x, class = "check_name") {
  paste0("{.", class, " ", x, "}")
}

is_check_class <- function(
  x,
  class = c(
    "check_success",
    "check_failure",
    "check_exec_warn",
    "check_error",
    "check_exec_error",
    "check_info"
  )
) {
  class <- rlang::arg_match(class)
  purrr::map_lgl(x, ~ rlang::inherits_any(.x, class))
}

#' Get filenames from hub validation object and it's subclasses
#'
#' @param x A validation object or one of it's subclasses
#' @param unique Logical, whether to return unique filenames only
#' @param ... Additional arguments passed to methods
get_filenames <- function(x, unique = FALSE, ...) {
  UseMethod("get_filenames")
}

#' @export
get_filenames.default <- function(x, unique = FALSE, ...) {
  # This is your original implementation
  filenames <- fs::path_file(purrr::map_chr(x, "where"))
  if (unique) {
    unique(filenames)
  } else {
    filenames
  }
}

#' @export
get_filenames.target_validations <- function(x, unique = FALSE, ...) {
  # Use full path instead of basename for target validations
  filenames <- unname(purrr::map_chr(x, "where"))
  if (unique) {
    unique(filenames)
  } else {
    filenames
  }
}
