#' Print results of `validate_...()` function as a bullet list
#'
#' Prints a formatted summary of validation results. Validation-level warnings
#' (attached to the `hub_validations` object) are always displayed prominently
#' in a box at the top. Check-level warnings (attached to individual checks)
#' are only shown when `show_check_warnings = TRUE`.
#'
#' @param x An object of class `hub_validations` or any of its subclasses.
#' @param show_check_warnings Logical. If `TRUE`, prints check-level warnings
#'   inline with their checks. Validation-level warnings are always printed.
#'   Default `FALSE`.
#' @param ... Unused argument present for class consistency
#'
#' @return Returns `x` invisibly.
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' v <- validate_submission(
#'   hub_path,
#'   file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' )
#'
#' # Default print
#' print(v)
#'
#' # Show check-level warnings (if any)
#' print(v, show_check_warnings = TRUE)
#'
#' # Example with validation-level warning
#' v_with_warning <- v
#' attr(v_with_warning, "warnings") <- list(
#'   capture_validation_warning(
#'     msg = "Example validation-level warning message.",
#'     where = "example"
#'   )
#' )
#' print(v_with_warning)
#'
#' @export
print.hub_validations <- function(x, show_check_warnings = FALSE, ...) {
  # Print validation-level warnings prominently at top
  print_validation_warnings(attr(x, "warnings"))

  if (length(x) == 0L) {
    msg <- cli::format_inline("Empty {.cls {class(x)[1]}}")
    cli::cli_inform(msg)
  } else {
    print_file <- function(file_name, x, show_check_warnings) {
      x <- x[get_filenames(x) == file_name]

      cli::cli_div(class = "hub_validations", theme = hub_validation_theme)
      cli::cli_h2(file_name)

      # Print each check with its warnings inline
      for (i in seq_along(x)) {
        check <- x[[i]]
        check_name <- names(x)[i]

        # Determine bullet type
        bullet <- dplyr::case_when(
          inherits(check, "check_success") ~ "v",
          inherits(check, "check_failure") ~ "x",
          inherits(check, "check_exec_warn") ~ "!",
          inherits(check, "check_error") ~ "circle_cross",
          inherits(check, "check_exec_error") ~ "lower_block_8",
          inherits(check, "check_info") ~ "i",
          TRUE ~ "*"
        )

        # Print the check result
        msg <- stats::setNames(
          paste(
            apply_cli_span_class(check_name, class = "check_name"),
            check$message,
            sep = ": "
          ),
          bullet
        )
        cli::cli_inform(msg)

        # Print check-level warnings inline (indented)
        if (
          show_check_warnings &&
            !is.null(check$warnings) &&
            length(check$warnings) > 0
        ) {
          cli::cli_div(
            theme = list(div = list(`margin-left` = 2, color = "silver"))
          )
          for (w in check$warnings) {
            cli::cli_alert_warning(w$message)
          }
          cli::cli_end()
        }
      }

      cli::cli_end()
    }

    purrr::walk(
      .x = get_filenames(x, unique = TRUE),
      .f = function(file_name, x) print_file(file_name, x, show_check_warnings),
      x = x
    )
  }
  invisible(x)
}

# Print validation-level warnings prominently in a box
print_validation_warnings <- function(warnings) {
  if (is.null(warnings) || length(warnings) == 0) {
    return(invisible(NULL))
  }

  warning_messages <- purrr::map_chr(warnings, "message")

  # Format each warning with bullet and indented continuation lines
  format_warning <- function(msg) {
    # Squish whitespace and wrap to console width (minus room for box borders)
    wrap_width <- max(cli::console_width() - 6, 40)
    wrapped <- msg |>
      stringr::str_squish() |>
      stringr::str_wrap(width = wrap_width)

    # Split into lines
    lines <- stringr::str_split(wrapped, "\n")[[1]]

    # Add bullet to first line, indent continuation lines
    lines[1] <- paste0("\u2022 ", lines[1])
    if (length(lines) > 1) {
      lines[-1] <- paste0("  ", lines[-1])
    }
    lines
  }

  # Format all warnings
  warning_lines <- purrr::map(warning_messages, format_warning) |>
    unlist()

  cat(
    cli::boxx(
      c(
        cli::format_inline(
          "{cli::col_yellow(cli::symbol$warning)} {cli::style_bold('Warnings')}"
        ),
        warning_lines
      ),
      border_style = "single",
      padding = c(0, 1, 0, 1),
      border_col = "yellow"
    ),
    sep = "\n"
  )
  cli::cli_text("")
}


# TODO: Code to consider implementing more hierarchical printing of messages.
# Currently not implemented as pr_hub_validations class not implemented.
#' Print results of `validate_pr()` function as a bullet list
#'
#' @param x An object of class `pr_hub_validations`
#' @param ... Unused argument present for class consistency
#'
#' @keywords internal
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
  ".bullets .bullet-lower_block_8" = list(
    "before" = function(x) {
      paste0(cli::col_red(cli::symbol$lower_block_8), " ")
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
#' @noRd
#' @keywords internal
get_filenames <- function(x, unique = FALSE, ...) {
  UseMethod("get_filenames")
}

#' @export
#' @noRd
#' @keywords internal
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
#' @noRd
#' @keywords internal
get_filenames.target_validations <- function(x, unique = FALSE, ...) {
  # Use full path instead of basename for target validations
  filenames <- unname(purrr::map_chr(x, "where"))
  if (unique) {
    unique(filenames)
  } else {
    filenames
  }
}
