simple_example_check <- function(
  file_path = "test/file.csv",
  check,
  error,
  exec_error = FALSE
) {
  if (error) {
    details <- "Early return"
  } else {
    details <- NULL
  }
  if (exec_error) {
    stop("Stop! Early return because of exec error.")
  }
  hubValidations::capture_check_cnd(
    check = check,
    file_path = file_path,
    error = error,
    msg_subject = "Check",
    msg_verbs = c("passed", "failed"),
    msg_attribute = "!",
    details = details
  )
}
