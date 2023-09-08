#' Validate a submitted model data file
#'
#' @inheritParams check_tbl_unique_round_id
#' @inherit validate_model_file return
#' @export
#'
#' @examples
#' hub_path <- system.file("testhubs/simple", package = "hubValidations")
#' file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
#' validate_model_data(hub_path, file_path)
validate_model_data <- function(hub_path, file_path, round_id_col = NULL,
                                validations_cfg_path = NULL) {
  checks <- list()
  class(checks) <- c("hub_validations", "list")

  file_meta <- parse_file_name(file_path)
  round_id <- file_meta$round_id

  # -- File parsing checks ----
  checks$file_read <- check_file_read(
    file_path = file_path,
    hub_path = hub_path
  )
  if (is_error(checks$file_read)) {
    return(checks)
  }

  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )

  # -- File round ID checks ----
  # Will be skipped if round config round_id_from_var is FALSE and no round_id_col
  # value is explicitly specified.
  checks$valid_round_id_col <- check_valid_round_id_col(
    tbl,
    round_id_col = round_id_col,
    file_path = file_path,
    hub_path = hub_path
  )

  # check_valid_round_id_col is run at the top of this function and if it does
  # not explicitly succeed (i.e. either fails or is is skipped), the output of
  # check_valid_round_id_col() is returned.
  checks$unique_round_id <- check_tbl_unique_round_id(
    tbl,
    round_id_col = round_id_col,
    file_path = file_path,
    hub_path = hub_path
  )
  if (is_error(checks$unique_round_id)) {
    return(checks)
  }

  # -- Column level checks ----
  checks$colnames <- check_tbl_colnames(
    tbl,
    round_id = round_id,
    file_path = file_path,
    hub_path = hub_path
  )
  if (is_error(checks$colnames)) {
    return(checks)
  }

  checks$col_types <- check_tbl_col_types(
    tbl,
    file_path = file_path,
    hub_path = hub_path
  )

  # -- Row level checks ----
  checks$valid_vals <- check_tbl_values(
    tbl,
    round_id = round_id,
    file_path = file_path,
    hub_path = hub_path
  )

  checks$rows_unique <- check_tbl_rows_unique(
    tbl,
    file_path = file_path,
    hub_path = hub_path
  )

  checks$req_vals <- check_tbl_values_required(
    tbl,
    round_id = round_id,
    file_path = file_path,
    hub_path = hub_path
  )

  # -- Value column checks ----
  checks$value_col_valid <- check_tbl_value_col(
    tbl,
    round_id = round_id,
    file_path = file_path,
    hub_path = hub_path
  )

  checks$value_col_non_desc <- check_tbl_value_col_ascending(
    tbl,
    file_path = file_path
  )

  checks$value_col_sum1 <- check_tbl_value_col_sum1(
    tbl,
    file_path = file_path
  )

  # TODO: Add custom fn & fn requiring additional arguments section.
  custom_checks <- execute_custom_checks(validations_cfg_path = validations_cfg_path)
  checks <- c(checks, custom_checks)
  class(checks) <- c("hub_validations", "list")

  return(checks)
}
