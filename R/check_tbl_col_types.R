#' Check model data column data types
#'
#' @inherit check_tbl_colnames params return
#' @export
check_tbl_col_types <- function(tbl, file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  schema <- hubUtils::create_hub_schema(config_tasks,
    partitions = NULL,
    r_schema = TRUE
  )[names(tbl)]

  tbl_types <- purrr::map_chr(tbl, ~ if (class(.x) == "numeric") {
    typeof(.x)
  } else {
    class(.x)
  })
  compare_types <- schema == tbl_types

  check <- all(compare_types)

  if (check) {
    details <- NULL
  } else {
    invalid_cols <- names(compare_types)[!compare_types]
    details <- paste(
      "{.var ", invalid_cols,
      "} should be {.val ", schema[invalid_cols],
      "} not {.val ", tbl_types[invalid_cols], "}"
    ) %>%
      paste(collapse = ", ") %>%
      cli::format_inline()
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Column data types",
    msg_attribute = "hub schema.",
    msg_verbs = c("match", "do not match"),
    details = details
  )
}
