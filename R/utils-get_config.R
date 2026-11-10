#' Read the values each modeling task allows in each column
#'
#' Reads a round's config into one list per modeling task, each holding the
#' values that modeling task allows in each of its columns:
#'
#' ```
#' [[1]]
#'   $task_ids
#'     $target   "wk flu hosp rate category"
#'     $horizon  "0" "1" "2" "3"
#'     $location "US" "01" "02" ...
#'   $output_type_ids
#'     $pmf      "low" "moderate" "high" ...
#' ```
#'
#' A row is valid for a modeling task when every column holds one of the values
#' listed for it. [expand_model_out_grid()] builds one row for every valid
#' combination of those values. These lists hold the same information per
#' column, unexpanded.
#'
#' The sets come from [hubUtils::get_round_value_sets_config()], which
#' [expand_model_out_grid()] also uses, so a grid and these value sets cannot
#' disagree about the values a config allows. Note that each modeling task holds
#' every task ID in the round. A task ID that other modeling tasks use but this
#' one does not, whether listed as `null` or left out, comes back as `NA`,
#' which is what the column holds in this modeling task's rows.
#'
#' @inheritParams expand_model_out_grid
#' @param call The environment of the calling function. Errors and warnings
#'   from reading the config are attributed to it.
#'
#' @returns A list with one element per modeling task in the round, each a list
#' of `task_ids` and `output_type_ids` as above. Values come back as character,
#' whatever the config holds them as, because the only thing they are ever
#' compared against is the all-character copy of a submission.
#' @noRd
get_config_mt_value_sets <- function(
  config_tasks,
  round_id,
  output_types = NULL,
  derived_task_ids = NULL,
  call = rlang::caller_env()
) {
  hubUtils::get_round_value_sets_config(
    config_tasks,
    round_id,
    output_types = output_types,
    derived_task_ids = derived_task_ids,
    call = call
  ) |>
    purrr::map(\(value_sets) {
      task_ids <- flatten_values(value_sets[["task_ids"]])
      task_ids[lengths(task_ids) == 0L] <- list(NA)
      output_type_ids <- flatten_values(value_sets[["output_type_ids"]]) |>
        purrr::compact()
      list(
        task_ids = config_values_to_character(task_ids),
        output_type_ids = config_values_to_character(output_type_ids)
      )
    })
}

# Convert a modeling task's value sets to character.
#
# These values are only ever compared against an all-character copy of a
# submission, so they need to be character. Converting them here does it once,
# rather than leaving `%in%` to redo it for every column of every modeling task.
#
# Cast through arrow, as `hubData::coerce_to_character()` casts a submission, so
# that the two renderings cannot disagree. `as.character()` would differ on more
# than one count: it renders a large number in scientific notation, where
# `"1e+05"` would not match a `"100000"` in the data, and it writes a logical as
# `"TRUE"` where arrow writes `"true"`.
config_values_to_character <- function(x) {
  purrr::map(
    x,
    \(values) as.vector(arrow::Array$create(values)$cast(arrow::string()))
  )
}

# Make each element of a list of config values a vector.
#
# A config written with `jsonlite::toJSON()` stores a `null` property as `{}`,
# which reads back as an empty list. `c()` of an empty list and a vector is a
# list, so values from such a config can come back as a list of scalars, or as
# an empty list where both properties are `{}`. Each of those becomes a vector,
# or `NULL` when empty, so callers treat it like a `null` property.
flatten_values <- function(x) {
  purrr::map(x, \(values) unlist(values, use.names = FALSE))
}
