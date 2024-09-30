# file content with default settings matches snapshot

    Code
      create_custom_check("check_default")
    Message
      v Directory 'src/validations/R' created.
      v Custom validation check template function file "check_default.R" created.
      > Edit the function template to add your custom check logic.
      i See the Writing custom check functions article for more information.
      (<https://hubverse-org.github.io/hubValidations/articles/writing-custom-fns.html>)

---

    Code
      cat(file_contents, sep = "\n")
    Output
      check_default <- function(tbl, file_path) {
        # Here you can write your custom check logic
        # Assign the result as `TRUE` or `FALSE` to object called `check`.
        # If `check` is `TRUE`, the check will pass.
      
        check <- condition_to_be_TRUE_for_check_to_pass
      
        if (check) {
          details <- NULL
        } else {
          # You can use details messages to pass on helpful information to users about
          what caused the validation failure and how to locate affected data.
          details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
        }
      
        hubValidations::capture_check_cnd(
          check = check,
          file_path = file_path,
          msg_subject = "{.var round_id}",
          msg_attribute = "valid.",
          details = details
        )
      }

# Fully featured file content matches snapshot

    Code
      cat(file_contents, sep = "\n")
    Output
      check_full <- function(tbl, file_path, extra_arg = NULL) {
        # If provide additional custom arguments, make sure to include input checks
        # at the top of your function. `checkmate` package provides a simple interface
        # for many useful basic checks and is available through hubValidations.
        # The following example checks that `extra_arg` is a single character string.
        checkmate::assert_character(extra_arg, len = 1L, null.ok)
      
        if (!condition) {
          return(
            capture_check_info(
              file_path,
              "Condition for running this check was not met. Skipped."
            )
          )
        }
      
        # Here you can write your custom check logic
        # Assign the result as `TRUE` or `FALSE` to object called `check`.
        # If `check` is `TRUE`, the check will pass.
      
        check <- condition_to_be_TRUE_for_check_to_pass
      
        if (check) {
          details <- NULL
          error_object <- NULL
        } else {
          # You can use details messages and any type of R object to pass on helpful
          # information to users about what caused the validation failure and how to
          # locate affected data.
          error_object <- list(
            invalid_rows = which(tbl$example_task_id == "invalid")
          )
          details <- cli::format_inline("See {.var error_object} attribute for details.")
        }
      
        hubValidations::capture_check_cnd(
          check = check,
          file_path = file_path,
          msg_subject = "{.var round_id}",
          msg_attribute = "valid.",
          error_object = error_object,
          details = details
        )
      }

# file content with non-default locations matches snapshot

    Code
      cat(file_contents, sep = "\n")
    Output
      check_non_default <- function(tbl, file_path, extra_arg = NULL) {
        # If provide additional custom arguments, make sure to include input checks
        # at the top of your function. `checkmate` package provides a simple interface
        # for many useful basic checks and is available through hubValidations.
        # The following example checks that `extra_arg` is a single character string.
        checkmate::assert_character(extra_arg, len = 1L, null.ok)
      
        if (!condition) {
          return(
            capture_check_info(
              file_path,
              "Condition for running this check was not met. Skipped."
            )
          )
        }
      
        # Here you can write your custom check logic
        # Assign the result as `TRUE` or `FALSE` to object called `check`.
        # If `check` is `TRUE`, the check will pass.
      
        check <- condition_to_be_TRUE_for_check_to_pass
      
        if (check) {
          details <- NULL
        } else {
          # You can use details messages to pass on helpful information to users about
          what caused the validation failure and how to locate affected data.
          details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
        }
      
        hubValidations::capture_check_cnd(
          check = check,
          file_path = file_path,
          msg_subject = "{.var round_id}",
          msg_attribute = "valid.",
          details = details
        )
      }

# create_custom_check overwrites when file already exists and overwrite is TRUE

    Code
      cat(readLines("src/validations/R/check_overwite.R"), sep = "\n")
    Output
      check_overwite <- function(tbl, file_path) {
        # Here you can write your custom check logic
        # Assign the result as `TRUE` or `FALSE` to object called `check`.
        # If `check` is `TRUE`, the check will pass.
      
        check <- condition_to_be_TRUE_for_check_to_pass
      
        if (check) {
          details <- NULL
        } else {
          # You can use details messages to pass on helpful information to users about
          what caused the validation failure and how to locate affected data.
          details <- cli::format_inline("{.var round_id} value {.val invalid} is invalid.")
        }
      
        hubValidations::capture_check_cnd(
          check = check,
          file_path = file_path,
          msg_subject = "{.var round_id}",
          msg_attribute = "valid.",
          details = details
        )
      }

