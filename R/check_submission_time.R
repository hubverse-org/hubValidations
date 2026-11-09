#' Checks submission is within the valid submission window for a given round.
#'
#' @param ref_date_from whether to get the reference date around
#' which relative submission windows will be determined from the file's
#' `file_path` round ID or the `file` contents themselves.
#' `file` requires that the file can be read.
#' Only applicable when a round is configured to determine the submission
#' windows relative to the value in a date column in model output files.
#' Not applicable when explicit submission window start and end dates are
#' provided in the hub's config.
#'
#' @inherit check_tbl_col_types params return
#'
#' @importFrom lubridate %within%
#' @export
check_submission_time <- function(
  hub_path,
  file_path,
  ref_date_from = c(
    "file", # nolint
    "file_path"
  )
) {
  submission_window <- get_submission_window(hub_path, file_path, ref_date_from)
  check <- Sys.time() %within% submission_window

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "Current time {.val {format(Sys.time(),
      format = '%Y-%m-%d %H:%M:%S',
      usetz = TRUE)}} is outside window {.val {submission_window}}."
    )
  }

  capture_check_cnd(
    check = check,
    file_path = file_path,
    msg_subject = "Submission time",
    msg_attribute = "within accepted submission window for round.",
    details = details
  )
}

get_submission_window <- function(
  hub_path,
  file_path,
  ref_date_from = c(
    "file", # nolint
    "file_path"
  ),
  call = rlang::caller_env()
) {
  ref_date_from <- rlang::arg_match(ref_date_from)
  submission_config <- get_file_round_config(file_path, hub_path)[[
    "submissions_due"
  ]]
  hub_tz <- resolve_hub_timezone(get_hub_timezone(hub_path), call = call)

  if (!is.null(submission_config[["relative_to"]])) {
    relative_date <- switch(
      ref_date_from,
      file_path = {
        as.Date(get_file_round_id(file_path))
      },
      file = {
        tbl <- read_model_out_file(
          file_path = file_path,
          hub_path = hub_path
        )
        as.Date(
          unique(tbl[[submission_config[["relative_to"]]]])
        )
      }
    )
    start <- relative_date + submission_config[["start"]]
    end <- relative_date + submission_config[["end"]]
  } else {
    start <- submission_config[["start"]]
    end <- submission_config[["end"]]
  }

  submit_window_start <- lubridate::ymd(start, tz = hub_tz)
  submit_window_end <- lubridate::ymd_hms(paste(end, "23:59:59"), tz = hub_tz)

  lubridate::interval(
    start = submit_window_start,
    end = submit_window_end
  )
}

file_within_submission_window <- function(
  hub_path,
  file_path,
  ref_date_from = c(
    "file", # nolint
    "file_path"
  )
) {
  submission_window <- get_submission_window(hub_path, file_path, ref_date_from)
  Sys.time() %within% submission_window
}

#' Resolve a hub's timezone to a name this system recognises
#'
#' Hubs often set a legacy timezone name, such as `US/Eastern`, in `admin.json`.
#' Some systems, such as Ubuntu 26.04 without the `tzdata-legacy` package, do
#' not recognise legacy names. On those systems a legacy name is replaced with
#' the canonical name it links to, such as `America/New_York`, which follows
#' the same rules.
#'
#' @param tz A timezone name.
#' @param call The execution environment of the calling function, used in the
#'   error message.
#'
#' @returns `tz` if this system recognises it, otherwise the canonical name it
#'   links to. Errors if neither is recognised.
#' @noRd
resolve_hub_timezone <- function(tz, call = rlang::caller_env()) {
  if (tz_recognised(tz)) {
    return(tz)
  }
  canonical <- unname(tz_legacy_links[tz])
  if (!is.na(canonical) && tz_recognised(canonical)) {
    return(canonical)
  }
  # Suggest the canonical name for a legacy name, otherwise an example.
  if (is.na(canonical)) {
    canonical <- "America/New_York"
  }
  cli::cli_abort(
    c(
      "Hub timezone {.val {tz}} is not recognised on this system.",
      "i" = "Check that {.field timezone} in {.path hub-config/admin.json}
             is a valid tz database name, such as {.val {canonical}}, and
             that the system has a timezone database (tzdata) installed."
    ),
    call = call
  )
}

# Whether the date library recognises a timezone name. Tried directly, as
# get_submission_window() uses it, because R's list of timezone names can come
# from a different tz database than the one the date library reads.
tz_recognised <- function(tz) {
  !inherits(
    try(lubridate::ymd("2000-01-01", tz = tz), silent = TRUE),
    "try-error"
  )
}
