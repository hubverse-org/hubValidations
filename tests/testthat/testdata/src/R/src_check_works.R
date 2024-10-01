src_check_works <- function(file_path, extra_msg = "Default message") {
  hubValidations::capture_check_info(
    file_path,
    msg = cli::format_inline(
      "Sourcing custom functions {.field WORKS}! Also {.val {extra_msg}}!!"
    )
  )
}
