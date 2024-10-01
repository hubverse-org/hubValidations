simple_example_check <- function(file_path = "test/file.csv", check, error) {
  if (error) {
    details <- "Early return"
  } else {
    details <- NULL
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
