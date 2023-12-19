#' Checks submission is within the valid submission window for a given round.
#'
#' @param ref_date_from whether to get the round ID around which relative submission
#' windows will be determined from the file's `file_path` or the `file` contents
#' themselves. `file` requires that the file can be read.
#' Only applicable when a round is configured to determine the submission
#' windows relative to the value in a date column in model output files.
#'
#' @inherit check_tbl_col_types params return
#'
#' @importFrom lubridate %within%
#' @export
check_submission_time <- function(hub_path, file_path, ref_date_from = c(
                                    "file",
                                    "file_path"
                                  )) {
  submission_window <- get_submission_window(hub_path, file_path, ref_date_from)
  check <- Sys.time() %within% submission_window

  if (check) {
    details <- NULL
  } else {
    details <- cli::format_inline(
      "Current time {.val {Sys.time()}} is outside window {.val {submission_window}}."
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

get_submission_window <- function(hub_path, file_path, ref_date_from = c(
                                    "file",
                                    "file_path"
                                  )) {
  ref_date_from <- rlang::arg_match(ref_date_from)
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  submission_config <- get_file_round_config(file_path, hub_path)[["submissions_due"]]
  hub_tz <- get_hub_timezone(hub_path)

  if (!is.null(submission_config[["relative_to"]])) {
    relative_date <- switch(ref_date_from,
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
  submit_window_end <- lubridate::ymd_hms(paste(end, "23:59:59"),
    tz = hub_tz
  )

  lubridate::interval(
    start = submit_window_start,
    end = submit_window_end
  )
}

file_within_submission_window <- function(hub_path, file_path, ref_date_from = c(
                                            "file",
                                            "file_path"
                                          )) {
  submission_window <- get_submission_window(hub_path, file_path, ref_date_from)
  Sys.time() %within% submission_window
}
