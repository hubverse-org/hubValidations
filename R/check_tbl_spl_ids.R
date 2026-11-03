#' Check that sample output_type_ids match the configured type and max_length
#' and contain only allowed characters
#'
#' @inherit check_tbl_colnames params
#' @inherit check_tbl_colnames return
#' @inheritParams check_tbl_spl_mt_unique
#' @inheritParams check_tbl_values
#' @details
#' The format required of sample `output_type_id`s depends on the `type` and
#' `max_length` each modeling task sets in `output_type_id_params`:
#' - When `type` is `"integer"`, each sample ID must be a non-negative integer
#'   written with digits only and without leading zeros, such as `"0"` or
#'   `"12"`. `"01"`, `"1.0"` and `"1e3"` fail.
#' - When `type` is `"character"`, each sample ID must have at most
#'   `max_length` characters, and contain only ASCII letters, digits, `_` and
#'   `-`.
#'
#' Every sample row must also have a non-empty `output_type_id`.
#'
#' Output of the check includes an `errors` element, a list with one element
#' for each modeling task failing validation, named by the index of the
#' modeling task in the config. Each element has the following structure:
#' - `type`: the configured sample ID `type`.
#' - `max_length`: the configured `max_length`. Only present when `type` is
#'   `"character"`.
#' - `problems`: a list with one element for each problem found:
#'   - `missing`: the number of sample rows with a missing or empty
#'     `output_type_id`.
#'   - `integer`: the sample IDs that are not non-negative integers.
#'   - `max_length`: the sample IDs longer than `max_length`.
#'   - `characters`: the sample IDs that contain characters other than ASCII
#'     letters, digits, `_` and `-`.
#'
#' See [hubverse documentation on samples](https://docs.hubverse.io/en/latest/user-guide/sample-output-type.html)
#' for more details.
#' @export
check_tbl_spl_ids <- function(
  tbl_chr,
  round_id,
  file_path,
  hub_path,
  derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
) {
  assert_tbl_chr(tbl_chr)
  config_tasks <- read_config(hub_path, "tasks")

  if (
    isFALSE(has_spls_tbl(tbl_chr)) ||
      isFALSE(hubUtils::is_v3_config(config_tasks))
  ) {
    return(skip_v3_spl_check(file_path))
  }

  out_tid <- hubUtils::std_colnames["output_type_id"]
  spl_tbl <- tbl_chr[tbl_chr$output_type == "sample", names(tbl_chr) != "value"]

  mt_row_idx <- assign_spl_tbl_rows(
    spl_tbl,
    config_tasks = config_tasks,
    round_id = round_id,
    derived_task_ids = derived_task_ids
  )
  round_mt <- hubUtils::get_round_model_tasks(config_tasks, round_id)

  errors <- purrr::map2(round_mt, mt_row_idx, function(mt, row_idx) {
    spl_params <- get_mt_sample_params(mt)
    problems <- spl_id_problems(spl_tbl[[out_tid]][row_idx], spl_params)
    if (length(problems) == 0L) {
      return(NULL)
    }
    c(
      spl_params[intersect(c("type", "max_length"), names(spl_params))],
      list(problems = problems)
    )
  }) |>
    purrr::set_names(seq_along(round_mt)) |>
    purrr::compact()

  check <- length(errors) == 0L

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Sample `output_type_id`s",
    msg_attribute = "the required sample ID format.",
    msg_verbs = c("match", "do not match"),
    details = if (!check) compile_spl_ids_details(errors),
    errors = if (!check) errors,
    error = TRUE
  )
}

# The characters a character sample ID may contain.
spl_id_pattern <- "^[A-Za-z0-9_-]+$"
# The canonical form of an integer sample ID.
spl_id_int_pattern <- "^(0|[1-9][0-9]*)$"

# The `problems` of the `output_type_id`s `ids` of one modeling task, given
# its sample `output_type_id_params`, as documented in `check_tbl_spl_ids()`.
spl_id_problems <- function(ids, spl_params) {
  is_missing <- is.na(ids) | ids == ""
  missing <- sum(is_missing)
  ids <- unique(ids[!is_missing])
  # Note that `nchar()` errors on strings that are not valid UTF-8, unless
  # `allowNA = TRUE`, which returns `NA` for them instead. Such IDs fail the
  # byte-wise pattern match and are reported under `characters`.
  problems <- if (identical(spl_params$type, "character")) {
    n_chars <- nchar(ids, allowNA = TRUE)
    list(
      max_length = ids[!is.na(n_chars) & n_chars > spl_params$max_length],
      characters = ids[!grepl(spl_id_pattern, ids, useBytes = TRUE)]
    )
  } else {
    list(integer = ids[!grepl(spl_id_int_pattern, ids, useBytes = TRUE)])
  }
  problems <- c(list(missing = if (missing > 0L) missing), problems)
  problems[lengths(problems) > 0L]
}

compile_spl_ids_details <- function(errors) {
  details <- purrr::imap_chr(errors, function(.x, .y) {
    phrases <- purrr::imap_chr(
      .x$problems,
      \(value, problem) spl_id_problem_phrase(value, problem, .x$max_length)
    )
    paste0("mt ", .y, ": ", cli::ansi_collapse(phrases), ".")
  })
  c(
    details,
    if (any(purrr::map_lgl(errors, \(.x) "integer" %in% names(.x$problems)))) {
      "Integer sample IDs must contain digits only, without leading zeros."
    },
    "See {.var errors} attribute for details."
  ) |>
    paste(collapse = " ")
}

# One clause of the details of `check_tbl_spl_ids()`, describing `value`, an
# element of `problems` named `problem`.
spl_id_problem_phrase <- function(value, problem, max_length) {
  if (problem == "missing") {
    return(cli::format_inline(
      "{value} sample row{?s} ha{?s/ve} no {.var output_type_id}"
    ))
  }
  # cli warns on strings that are not valid UTF-8, so invalid bytes are shown
  # as hex codes, such as "a<ff>".
  spl_ids <- iconv(value, "UTF-8", "UTF-8", sub = "byte") |> # nolint: object_usage_linter
    escape_braces() |>
    cli::cli_vec(style = list(vec_trunc = 10))
  cli::format_inline(
    "{cli::qty(spl_ids)}sample ID{?s} {.val {spl_ids}} ",
    switch(
      problem,
      integer = "{?is not a non-negative integer/are not non-negative integers}",
      max_length = "{?is/are} longer than the {.var max_length} of {max_length}",
      characters = paste(
        "contain{?s/} characters other than ASCII letters, digits,",
        "{.val _} and {.val -}"
      )
    )
  )
}
