get_round_required_output_type_names <- function(config_tasks, round_id) {
  is_required <- get_round_output_types(config_tasks, round_id) |>
    purrr::flatten() |>
    purrr::map_lgl(~ is_required_output_type(.x))

  names(is_required)[is_required] |> unique()
}

get_submission_required_output_types <- function(tbl, config_tasks, round_id) {
  tbl_output_types <- get_tbl_output_types(tbl)
  required_output_types <- get_round_required_output_type_names(
    config_tasks,
    round_id
  )
  unique(c(tbl_output_types, required_output_types))
}

get_tbl_output_types <- function(tbl) {
  unique(tbl[["output_type"]])
}

#' Is an `output_type_id` property in the pre v4 schema format
#'
#' A pre v4 `output_type_id` property has a `required` and an `optional`
#' element. It is `NULL` for pre v4 sample output types, which only have an
#' `output_type_id_params` property, and has only a `required` element from v4
#' on.
#'
#' @param output_type_ids An `output_type_id` property.
#'
#' @returns `TRUE` for a pre v4 `output_type_id` property, `FALSE` otherwise.
#' @noRd
pre_v4_std <- function(output_type_ids) {
  setequal(
    names(output_type_ids),
    c("required", "optional")
  )
}

#' Determine whether an `output_type` is required.
#'
#' @param output_type an R representation of an `output_type` property.
#'
#' @returns `TRUE` if the output type is required, `FALSE` otherwise.
#' @noRd
is_required_output_type <- function(output_type) {
  # If dealing with a pre v4 configuration, check whether the `required` field
  # is not null
  if (pre_v4_std(output_type[["output_type_id"]])) {
    return(!is.null(output_type[["output_type_id"]][["required"]]))
  }
  # If dealing with a post v4 configuration or pre v4 samples, check the
  # `is_required` property where that version holds it
  isTRUE(output_type[["is_required"]]) ||
    isTRUE(output_type[["output_type_id_params"]][["is_required"]])
}
