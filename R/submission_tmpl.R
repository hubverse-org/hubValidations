#' Create a model output submission file template
#'
#' @param path Character string. Can be one of:
#' - a path to a local fully configured hub directory
#' - a path to a local `tasks.json` file.
#' - a URL to the repository of a fully configured hub on GitHub.
#' - a URL to the **raw contents** of a `tasks.json` file on GitHub.
#' - a `<SubTreeFileSystem>` class object pointing to the root of an S3 cloud hub.
#' - a `<SubTreeFileSystem>` class object pointing to a `tasks.json` config file in
#' an S3 cloud hub, relative to the hub's root directory.
#'
#' See examples for more details.
#' @param hub_con `r lifecycle::badge("deprecated")` Use `path` instead. A
#' `⁠<hub_connection>⁠` class object.
#' @param config_tasks `r lifecycle::badge("deprecated")` Use `path` instead.
#'  A list version of the content's of a hub's `tasks.json` config file,
#'  accessed through the `"config_tasks"` attribute of a `<hub_connection>`
#'  object or function [read_config()].
#' @inheritParams expand_model_out_grid
#' @param derived_task_ids Character vector of derived task ID names (task IDs whose
#' values depend on other task IDs) to ignore. Columns for such task ids will
#' contain `NA`s.
#' If `NULL`, defaults to extracting derived task IDs from `config_tasks` or
#' the `config_tasks` attribute of `hub_con`. See [get_config_derived_task_ids()]
#' for more details.
#' @param complete_cases_only Logical. If `TRUE` (default) and `required_vals_only = TRUE`,
#' only rows with complete cases of combinations of required values are returned.
#' If `FALSE`, rows with incomplete cases of combinations of required values
#' are included in the output.
#'
#' @return a tibble template containing an expanded grid of valid task ID and
#' output type ID value combinations for a given submission round
#' and output type.
#' If `required_vals_only = TRUE`, values are limited to the combination of required
#' values only.
#'
#' @details
#' For task IDs where all values are optional, by default, columns
#' are created as columns of `NA`s when `required_vals_only = TRUE`.
#' When such columns exist, the function returns a tibble with zero rows, as no
#' complete cases of required value combinations exists.
#' _(Note that determination of complete cases does excludes valid `NA`
#' `output_type_id` values in `"mean"` and `"median"` output types)._
#' To return a template of incomplete required cases, which includes `NA` columns, use
#' `complete_cases_only = FALSE`.
#'
#' To include output types that are optional in the submission template
#' when `required_vals_only = TRUE` and `complete_cases_only = FALSE`, use
#' `force_output_types = TRUE`. Use this in combination with sub-setting for
#'  output types you plan to submit via argument `output_types` to create a
#' submission template customised to your submission plans.
#' _Tip: to ensure you create a template with all required output types, it's
#' a good idea to first run the functions without subsetting or forcing output
#' types and examing the unique values in `output_type` to check which output
#' types are required._
#'
#' When sample output types are included in the output, the `output_type_id`
#' column contains example sample indexes which are useful for identifying the
#' compound task ID structure of multivariate sampling distributions in particular,
#' i.e. which combinations of task ID values represent individual samples.
#'
#' When a round is set to `round_id_from_variable: true`,
#' the value of the task ID from which round IDs are derived (i.e. the task ID
#' specified in `round_id` property of `config_tasks`) is set to the value of the
#' `round_id` argument in the returned output.
#' @export
#' @importFrom lifecycle deprecated
#'
#' @examples
#' hub_path <- system.file("testhubs/flusight", package = "hubUtils")
#' submission_tmpl(hub_path, round_id = "2023-01-02")
#' # Return required values only
#' submission_tmpl(
#'   hub_path,
#'   round_id = "2023-01-02",
#'   required_vals_only = TRUE
#' )
#' submission_tmpl(
#'   hub_path,
#'   round_id = "2023-01-02",
#'   required_vals_only = TRUE,
#'   complete_cases_only = FALSE
#' )
#' # Specify a round in a hub with multiple rounds
#' hub_path <- system.file("testhubs/simple", package = "hubUtils")
#' submission_tmpl(hub_path, round_id = "2022-10-01")
#' submission_tmpl(hub_path, round_id = "2022-10-29")
#' # Subset for a specific output type
#' hub_path <- system.file("testhubs", "samples", package = "hubValidations")
#' submission_tmpl(
#'   hub_path,
#'   round_id = "2022-12-17",
#'   output_types = "sample"
#' )
#' # Create a template from the path to a tasks config file
#' config_path <- system.file("config", "tasks.json",
#'   package = "hubValidations"
#' )
#' submission_tmpl(
#'   config_path,
#'   round_id = "2022-12-26"
#' )
#' # Hub with sample output type and compound task ID structure
#' config_path <- system.file("config", "tasks-comp-tid.json",
#'   package = "hubValidations"
#' )
#' submission_tmpl(
#'   config_path,
#'   round_id = "2022-12-26",
#'   output_types = "sample"
#' )
#' # Override config compound task ID set
#' # Create coarser compound task ID set for the first modeling task which contains
#' # samples
#' submission_tmpl(
#'   config_path,
#'   round_id = "2022-12-26",
#'   output_types = "sample",
#'   compound_taskid_set = list(
#'     c("forecast_date", "target"),
#'     NULL
#'   )
#' )
#' # Derive a template with ignored derived task ID. Useful to avoid creating
#' # a template with invalid derived task ID value combinations.
#' hub_path <- system.file("testhubs", "flusight", package = "hubValidations")
#' submission_tmpl(
#'   hub_path,
#'   round_id = "2022-12-12",
#'   output_types = "pmf",
#'   derived_task_ids = "target_end_date",
#'   complete_cases_only = FALSE
#' )
#' # Force optional output type, in this case "mean".
#' submission_tmpl(
#'   hub_path,
#'   round_id = "2022-12-12",
#'   required_vals_only = TRUE,
#'   output_types = c("pmf", "quantile", "mean"),
#'   force_output_types = TRUE,
#'   derived_task_ids = "target_end_date",
#'   complete_cases_only = FALSE
#' )
#' # Create a template from a URL to fully configured hub repository on GitHub
#' submission_tmpl(
#'   path = "https://github.com/hubverse-org/example-simple-forecast-hub",
#'   round_id = "2022-11-28",
#'   output_types = "quantile"
#' )
#' # Create a template from a URL to the raw contents of a tasks.json file on
#' # GitHub
#' config_raw_url <- paste0(
#'   "https://raw.githubusercontent.com/hubverse-org/",
#'   "example-simple-forecast-hub/refs/heads/main/hub-config/tasks.json"
#' )
#' submission_tmpl(
#'   path = config_raw_url,
#'   round_id = "2022-11-28",
#'   output_types = "quantile"
#' )
#' @examplesIf asNamespace("hubUtils")$not_rcmd_check() && requireNamespace("arrow", quietly = TRUE)
#' # Create submission file using config file from AWS S3 bucket hub
#' # Use `s3_bucket()` to create a path to the hub's root directory
#' s3_hub_path <- arrow::s3_bucket("hubverse/hubutils/testhubs/simple/")
#' submission_tmpl(
#'   path = s3_hub_path,
#'   round_id = "2022-10-01",
#'   output_types = "quantile"
#' )
#' # Use `path()` method to create a path to the tasks.json file relative to the
#' # the S3 cloud hub's root directory
#' s3_config_path <- s3_hub_path$path("hub-config/tasks.json")
#' submission_tmpl(
#'   path = s3_config_path,
#'   round_id = "2022-10-01",
#'   output_types = "quantile"
#' )
submission_tmpl <- function(
  path,
  round_id,
  required_vals_only = FALSE,
  force_output_types = FALSE,
  complete_cases_only = TRUE,
  compound_taskid_set = NULL,
  output_types = NULL,
  derived_task_ids = NULL,
  hub_con = deprecated(),
  config_tasks = deprecated()
) {
  config_tasks <- switch_get_config(hub_con, config_tasks, path)

  if (is.null(derived_task_ids)) {
    derived_task_ids <- get_config_derived_task_ids(
      config_tasks,
      round_id
    )
  } else {
    derived_task_ids <- validate_derived_task_ids(
      derived_task_ids,
      config_tasks,
      round_id
    )
  }
  tmpl_df <- expand_model_out_grid(
    config_tasks,
    round_id = round_id,
    required_vals_only = required_vals_only,
    include_sample_ids = TRUE,
    compound_taskid_set = compound_taskid_set,
    output_types = output_types,
    derived_task_ids = derived_task_ids,
    force_output_types = force_output_types
  )
  if (nrow(tmpl_df) == 0L && !complete_cases_only) {
    # If all output_types are optional, expand_model_out_grid returns
    # a zero row and column data.frame. To attempt to expand required task id
    # values when complete_cases_only = FALSE, we use
    # force_output_types = TRUE to force the output types to be included. We
    # then remove output type related columns  and create a data.frame of
    # required task id vales only.
    tmpl_df <- expand_model_out_grid(
      config_tasks,
      round_id = round_id,
      required_vals_only = required_vals_only,
      include_sample_ids = TRUE,
      compound_taskid_set = compound_taskid_set,
      output_types = output_types,
      derived_task_ids = derived_task_ids,
      force_output_types = TRUE
    )
    output_cols <- hubUtils::std_colnames[c(
      "output_type",
      "output_type_id",
      "value"
    )]
    tmpl_df <- tmpl_df[setdiff(names(tmpl_df), output_cols)] |>
      unique()
  }
  if (nrow(tmpl_df) == 0L) {
    return(tmpl_df)
  }

  tmpl_cols <- c(
    hubUtils::get_round_task_id_names(
      config_tasks,
      round_id
    ),
    hubUtils::std_colnames[names(hubUtils::std_colnames) != "model_id"]
  )
  # Add NA columns for value and all optional cols
  na_cols <- tmpl_cols[!tmpl_cols %in% names(tmpl_df)]
  tmpl_df[, na_cols] <- NA
  tmpl_df <- coerce_to_hub_schema(tmpl_df, config_tasks)[, tmpl_cols]

  if (complete_cases_only) {
    subset_complete_cases(tmpl_df)
  } else {
    # We only need to notify of added `NA` columns when we are not subsetting
    # for complete cases only as `NA`s will only show up when
    # complete_cases_only == FALSE
    if (any(na_cols != hubUtils::std_colnames["value"])) {
      message_opt_tasks(
        na_cols,
        n_model_tasks(config_tasks, round_id)
      )
    }
    tmpl_df
  }
}

n_model_tasks <- function(config_tasks, round_id) {
  length(hubUtils::get_round_model_tasks(config_tasks, round_id))
}

message_opt_tasks <- function(na_cols, n_mt) {
  na_cols <- na_cols[na_cols != "value"]
  msg <- c(
    "!" = "{cli::qty(length(na_cols))}Column{?s} {.val {na_cols}}
           whose values are all optional included as all {.code NA} column{?s}."
  )
  if (n_mt > 1L) {
    msg <- c(
      msg,
      "!" = "Round contains more than one modeling task (n = {.val {n_mt}})"
    )
  }
  msg <- c(
    msg,
    "i" = "See Hub's {.path tasks.json} file for details of optional
    task ID/output_type/output_type ID value combinations."
  )
  cli::cli_bullets(msg)
}

subset_complete_cases <- function(tmpl_df) {
  # get complete cases across all columns except 'value'
  cols <- !names(tmpl_df) %in% hubUtils::std_colnames[c("value", "model_id")]
  compl_cases <- stats::complete.cases(tmpl_df[, cols])

  # As 'mean' and 'median' output types have valid 'NA' entries in 'output_type_id'
  # column when they are required, ovewrite the initial check for
  # complete cases by performing the check again only on rows where output type is
  # mean/median and using all columns except 'value' and 'output_type'.
  na_output_type_idx <- which(
    tmpl_df[[hubUtils::std_colnames["output_type"]]] %in% c("mean", "median")
  )
  cols <- !names(tmpl_df) %in%
    hubUtils::std_colnames[c(
      "output_type_id",
      "value",
      "model_id"
    )]
  compl_cases[na_output_type_idx] <- stats::complete.cases(
    tmpl_df[na_output_type_idx, cols]
  )
  tmpl_df[compl_cases, ]
}

# This function handles issuing deprecation warnings for older arguments
# and returns a config_tasks list according to the input argument.
switch_get_config <- function(hub_con, config_tasks, path) {
  input_arg <- rlang::check_exclusive(
    hub_con,
    config_tasks,
    path,
    .frame = parent.frame()
  )
  switch(
    input_arg,
    hub_con = {
      # Signal the deprecation to the user
      lifecycle::deprecate_warn(
        "0.11.0",
        "hubValidations::submission_tmpl(hub_con = )",
        "hubValidations::submission_tmpl(hub_path = )"
      )
      checkmate::assert_class(hub_con, classes = "hub_connection")
      attr(hub_con, "config_tasks")
    },
    config_tasks = {
      lifecycle::deprecate_warn(
        "0.11.0",
        "hubValidations::submission_tmpl(config_tasks = )",
        "hubValidations::submission_tmpl(hub_path = )"
      )
      checkmate::assert_list(config_tasks)
    },
    path = {
      is_s3_dir <- inherits(path, "SubTreeFileSystem") &&
        hubUtils::is_s3_base_fs(path)

      invalid_github_url <- !inherits(path, "SubTreeFileSystem") &&
        hubUtils::is_github_url(path) &&
        !hubUtils::is_github_repo_url(path)

      if (invalid_github_url) {
        cli::cli_abort(
          c(
            "x" = "GitHub URL {.url {path}} is invalid.",
            "i" = "Please supply either a {.url github.com} URL to the repository
            root directory or a {.url raw.githubusercontent.com} URL to the raw
            contents of a {.path tasks.json} file. See examples for details."
          ),
          call = rlang::caller_env(1)
        )
      }

      is_dir <- is.character(path) && fs::path_ext(path) == ""
      if (is_s3_dir || is_dir) {
        read_config(path)
      } else {
        read_config_file(path)
      }
    }
  )
}
