#' Check that a target data file has the correct column types according to
#' target type
#'
#' @param target_tbl A tibble/data.frame of the contents of the target data file
#' being validated.
#' @inherit check_target_tbl_colnames params return
#' @inheritParams hubData::connect_target_timeseries
#' @export
check_target_tbl_coltypes <- function(target_tbl,
                                      target_type = c(
                                        "time-series", "oracle-output"
                                      ),
                                      date_col = NULL,
                                      na = c("NA", ""),
                                      file_path, hub_path) {
  target_type <- rlang::arg_match(target_type)

  schema <- switch (target_type,
                    `time-series` = hubData::create_timeseries_schema(
                      hub_path = hub_path,
                      date_col = date_col,
                      na = na
                    ),
                    `oracle-output` = hubData::create_oracle_output_schema(
                      hub_path = hub_path,
                      na = na
                    )
  )


}
