#' Check model data column data types
#'
#' Check that model output data column datatypes conform to those define in the
#' hub config.
#' @inherit check_tbl_colnames params
#' @inheritParams hubData::create_hub_schema
#' @return
#' Depending on whether validation has succeeded, one of:
#' - `<message/check_success>` condition class object.
#' - `<error/check_failure>` condition class object.
#'
#' Returned object also inherits from subclass `<hub_check>`.
#' @export
check_tbl_col_types <- function(tbl, file_path, hub_path,
                                output_type_id_datatype = c(
                                  "from_config", "auto", "character",
                                  "double", "integer",
                                  "logical", "Date"
                                )) {
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)
  config_tasks <- hubUtils::read_config(hub_path, "tasks")

  schema <- hubData::create_hub_schema(config_tasks,
    partitions = NULL,
    r_schema = TRUE,
    output_type_id_datatype = output_type_id_datatype
  )[names(tbl)]

  tbl_types <- purrr::map_chr(tbl, ~ if (inherits(.x, "numeric")) {
    typeof(.x)
  } else {
    paste(class(.x), collapse = "/")
  })
  compare_types <- schema == tbl_types

  check <- all(compare_types)

  if (check) {
    details <- NULL
  } else {
    invalid_cols <- names(compare_types)[!compare_types]
    details <- paste0(
      "{.var ", invalid_cols,
      "} should be {.val ", schema[invalid_cols],
      "} not {.val ", tbl_types[invalid_cols], "}"
    ) %>%
      paste(collapse = ", ") %>%
      paste0(".") %>%
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
