#' Determine whether an R representation of an `output_type_ids` property is from
#' a config using a pre v4 schema standard.
#'
#' The function will return `TRUE` if the input is a list and has the standard
#' structure a `required` and `optional` element.
#' It will return `FALSE` otherwise, i.e.:
#' - if the input is `NULL` (pre v4 sample
#' output types which only have an `output_type_id_params` property)
#' - if the
#' list only contains only a `required` element (post v4 output types).
#'
#' @param output_type_ids an R representation of an `output_type_ids` property.
#'
#' @returns `TRUE` if the input is a pre v4 configuration, `FALSE` otherwise.
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
#' @returns `TRUE` if the output type is detected as required, `FALSE` otherwise.
#' @noRd
is_required_output_type <- function(output_type) {
  # If dealing with a pre v4 configuration, check whether the `required` field
  # is not null
  if (pre_v4_std(output_type[["output_type_id"]])) {
    return(!is.null(output_type[["output_type_id"]][["required"]]))
  }
  # If dealing with a post v4 configuration or pre v4 samples, check the value of
  # the `is_required` property in the appropriate loaction
  isTRUE(output_type[["is_required"]]) ||
    isTRUE(output_type[["output_type_id_params"]][["is_required"]])
}

#' Determine whether an R representation of an `output_type_ids` property conforms
#' to the internal standard output type ID expectation of having `required` and
#' `optional` elements.
#'
#' @param output_type_ids an R representation of an `output_type_ids` property.
#'
#' @returns `TRUE` if the input matches the standard output type id format, `FALSE`
#' otherwise. This includes the situation where the input is `NULL` (in the case of
#' sample output types).
#' @noRd
std_output_type_ids <- function(output_type_ids) {
  # Valid output type id configurations cannot be `NULL` . This is the situation
  # in sample output types which are configured through a output_type_id_params
  # property
  no_output_type_ids <- is.null(output_type_ids)
  if (no_output_type_ids) {
    return(FALSE)
  }
  # pre v4 configs have standard format (i.e. both `required` and `optional` fields.)
  # which is the format we are standardising to
  pre_v4_std(output_type_ids)
}

#' Convert a post v4 output type id configuration to the standard format.
#'
#' In order to be able to use the same infrastructure to process pre v4 output types
#' and task ids (which have the standard configuration format) and post v4 output
#' type IDs (which only have a `required` field while whether they are required is
#' configured via the output type property `is_required`) we need to convert any
#' post v4 configured output type IDs to the standard format of having `required`
#' and `optional` fields. We also need to account for the slightly different standard
#' output type ID format expected for point estimate or sample output types which
#' do not contain values. Instead an `NA` value in one of the `required` or
#' `optional` fields is used to indicate whether the output type is required.
#'
#' This function facilitates the standardisation of post v4 output type IDs to
#' the standard output type format. It can also be used to force all output type
#' IDs in pre v4 output type IDs to be required.
#' @param output_type_ids an R representation of a post v4 `output_type_ids` property.
#' @param is_required Logical. The value of the `is_required` property of the output
#' type.
#'
#' @returns a list with `required` and `optional` fields.
#' @noRd
standardise_output_types_ids <- function(output_type_ids, is_required) {
  # Determine whether we're dealing with a v4 configuration for a point estimate or
  #  a `NULL` output_type_ids object (in the case of pre v4 samples).
  #  The below expression will return `TRUE` in both situations.
  required_null <- is.null(output_type_ids[["required"]])
  if (required_null) {
    # For point estimates and samples, we need to return a list with `NA` in
    # one of the std fields. Which field is determined by the value of `is_required`
    return(null_output_type_ids(is_required))
  }
  # For all other post v4 output type IDs, we convert to standard configuration.
  to_std_output_type_ids(output_type_ids, is_required)
}

# Convert a post v4 output type id configuration to the standard format.
to_std_output_type_ids <- function(output_type_ids, is_required) {
  if (is_required) {
    as_required(output_type_ids)
  } else {
    as_optional(output_type_ids)
  }
}

# Convert a post required v4 output type id configuration (or force all values
# to be required in standard formatted output type IDs) to the standard format
# setting all values to be required.
# This is also used on std formatted output type IDs when `force_output_types`
# is `TRUE` to force all output type IDs to be required.
as_required <- function(output_type_ids) {
  opt_values <- output_type_ids$optional
  req_values <- output_type_ids$required
  values <- c(req_values, opt_values)

  list(required = values, optional = NULL)
}

# Convert a post required v4 output type id configuration to the standard format
# setting all values to be optional. This is not ever deployed on pre v4 output
# type IDs.
as_optional <- function(output_type_ids) {
  opt_values <- output_type_ids$optional
  req_values <- output_type_ids$required
  values <- c(req_values, opt_values)

  list(required = NULL, optional = values)
}

# Create a list of NULL or NA required and optional output type id values depending
# on whether the output type is required or optional. Allows us to use current
# infrastructure to convert `NULL`s to `NA`s in a back-compatible way.
null_output_type_ids <- function(is_required) {
  if (is_required) {
    list(required = NA, optional = NULL)
  } else {
    list(required = NULL, optional = NA)
  }
}

#' Check that a vector of output type names is valid for a given round.
#'
#' @param output_types vector of output type names.
#' @param config_tasks a list represention of the `tasks.json` configuration file.
#' @param round_id character string. The round ID.
#' @param call the calling function. Used for error messaging.
#'
#' @returns If valid, the input `output_types` is returned. Otherwise, an error is
#' thrown.
#' @noRd
validate_output_types <- function(
  output_types,
  config_tasks,
  round_id,
  call = rlang::caller_call()
) {
  checkmate::assert_character(output_types, null.ok = TRUE)
  if (is.null(output_types)) {
    return(NULL)
  }
  round_output_types <- get_round_output_type_names(config_tasks, round_id)
  invalid_output_types <- setdiff(output_types, round_output_types)
  if (length(invalid_output_types) > 0L) {
    cli::cli_abort(
      c(
        "x" = "{.val {invalid_output_types}} {?is/are} not valid output type{?s}.",
        "i" = "{.arg output_types} must be members of: {.val {round_output_types}}"
      ),
      call = call
    )
  }
  output_types
}
