#' Validate the contents of a submitted model data file
#'
#' @inheritParams check_tbl_unique_round_id
#' @inheritParams validate_model_file
#' @inheritParams hubData::create_hub_schema
#' @inheritParams expand_model_out_grid
#' @inherit validate_model_file return
#' @export
#' @details
#' Details of checks performed by `validate_model_data()`
#' ```{r, echo = FALSE}
#' arrow::read_csv_arrow(system.file("check_table.csv", package = "hubValidations")) %>%
#' dplyr::filter(.data$`parent fun` == "validate_model_data", !.data$optional) %>%
#'   dplyr::select(-"parent fun", -"check fun", -"optional") %>%
#'   dplyr::mutate("Extra info" = dplyr::case_when(
#'     is.na(.data$`Extra info`) ~ "",
#'     TRUE ~ .data$`Extra info`
#'   )) %>%
#'   knitr::kable() %>%
#'   kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed", "responsive")) %>%
#'   kableExtra::column_spec(1, bold = TRUE)
#' ```
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' validate_model_data(hub_path, file_path)
validate_model_data <- function(hub_path, file_path, round_id_col = NULL,
                                output_type_id_datatype = c(
                                  "from_config", "auto", "character",
                                  "double", "integer",
                                  "logical", "Date"
                                ),
                                validations_cfg_path = NULL,
                                derived_task_ids = NULL) {
  checks <- new_hub_validations()

  file_meta <- parse_file_name(file_path)
  round_id <- file_meta$round_id
  output_type_id_datatype <- rlang::arg_match(output_type_id_datatype)

  # -- File parsing checks ----
  checks$file_read <- try_check(
    check_file_read(
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$file_read)) {
    return(checks)
  }

  # If `csv` file, read in using hub schema. Otherwise use file
  # schema for other file formats.
  if (fs::path_ext(file_path) == "csv") {
    tbl <- read_model_out_file(
      file_path = file_path,
      hub_path = hub_path,
      coerce_types = "hub"
    )
  } else {
    tbl <- read_model_out_file(
      file_path = file_path,
      hub_path = hub_path,
      coerce_types = "none"
    )
  }


  # -- File round ID checks ----
  # Will be skipped if round config round_id_from_var is FALSE and no round_id_col
  # value is explicitly specified.
  checks$valid_round_id_col <- try_check(
    check_valid_round_id_col(
      tbl,
      round_id_col = round_id_col,
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )

  # check_valid_round_id_col is run at the top of this function and if it does
  # not explicitly succeed (i.e. either fails or is is skipped), the output of
  # check_valid_round_id_col() is returned.
  checks$unique_round_id <- try_check(
    check_tbl_unique_round_id(
      tbl,
      round_id_col = round_id_col,
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$unique_round_id)) {
    return(checks)
  }

  checks$match_round_id <- try_check(
    check_tbl_match_round_id(
      tbl,
      round_id_col = round_id_col,
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$match_round_id)) {
    return(checks)
  }

  # -- Column level checks ----
  checks$colnames <- try_check(
    check_tbl_colnames(
      tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )
  if (is_any_error(checks$colnames)) {
    return(checks)
  }

  checks$col_types <- try_check(
    check_tbl_col_types(
      tbl,
      file_path = file_path,
      hub_path = hub_path,
      output_type_id_datatype = output_type_id_datatype
    ), file_path
  )

  # -- Row level checks ----
  tbl_chr <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path,
    coerce_types = "chr"
  )
  checks$valid_vals <- try_check(
    check_tbl_values(
      tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path,
      derived_task_ids = derived_task_ids
    ), file_path
  )
  if (is_any_error(checks$valid_vals)) {
    return(checks)
  }

  checks$rows_unique <- try_check(
    check_tbl_rows_unique(
      tbl_chr,
      file_path = file_path,
      hub_path = hub_path
    ), file_path
  )

  checks$req_vals <- try_check(
    check_tbl_values_required(
      tbl_chr,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path,
      derived_task_ids = derived_task_ids
    ), file_path
  )

  # -- Value column checks ----
  checks$value_col_valid <- try_check(
    check_tbl_value_col(
      tbl,
      round_id = round_id,
      file_path = file_path,
      hub_path = hub_path,
      derived_task_ids = derived_task_ids
    ), file_path
  )

  checks$value_col_non_desc <- try_check(
    check_tbl_value_col_ascending(
      tbl,
      file_path = file_path
    ), file_path
  )

  checks$value_col_sum1 <- try_check(
    check_tbl_value_col_sum1(
      tbl,
      file_path = file_path
    ), file_path
  )

  # -- v3 sample checks ----
  if (hubUtils::is_v3_hub(hub_path)) {
    checks$spl_compound_taskid_set <- try_check(
      check_tbl_spl_compound_taskid_set(
        tbl_chr,
        round_id = round_id,
        file_path = file_path,
        hub_path = hub_path,
        derived_task_ids = derived_task_ids
      ), file_path
    )
    if (is_any_error(checks$spl_compound_taskid_set)) {
      return(checks)
    } else {
      compound_taskid_set <- checks$spl_compound_taskid_set$compound_taskid_set
    }
    checks$spl_compound_tid <- try_check(
      check_tbl_spl_compound_tid(
        tbl_chr,
        round_id = round_id,
        file_path = file_path,
        hub_path = hub_path,
        compound_taskid_set = compound_taskid_set,
        derived_task_ids = derived_task_ids
      ), file_path
    )
    if (is_any_error(checks$spl_compound_tid)) {
      return(checks)
    }
    checks$spl_non_compound_tid <- try_check(
      check_tbl_spl_non_compound_tid(
        tbl_chr,
        round_id = round_id,
        file_path = file_path,
        hub_path = hub_path,
        compound_taskid_set = compound_taskid_set,
        derived_task_ids = derived_task_ids
      ), file_path
    )
    if (is_any_error(checks$spl_non_compound_tid)) {
      return(checks)
    }
    checks$spl_n <- try_check(
      check_tbl_spl_n(
        tbl_chr,
        round_id = round_id,
        file_path = file_path,
        hub_path = hub_path,
        compound_taskid_set = compound_taskid_set,
        derived_task_ids = derived_task_ids
      ), file_path
    )
  }

  custom_checks <- execute_custom_checks(
    validations_cfg_path = validations_cfg_path
  )

  combine(checks, custom_checks)
}
