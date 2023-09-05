#' Check whether a metadata file matches the schema provided by the hub
#' @inheritParams check_valid_round_id
#' @inherit check_valid_round_id return
#'
#' @export
check_metadata_matches_schema <- function(file_path, hub_path = ".") {
  # Adapted from https://github.com/covid19-forecast-hub-europe/HubValidations/blob/main/R/validate_model_metadata.R
  tryCatch(
    {
      metadata <- yaml::read_yaml(file_path)

      # For some reason, jsonvalidate doesn't like it when we don't unbox
      metadata_json <- jsonlite::toJSON(metadata, auto_unbox = TRUE)

      metadata_schema_path <- file.path(hub_path, "hub-config",
                                        "model-metadata-schema.json")
      if (!file.exists(metadata_schema_path)) {
        stop("Metadata schema file (`", metadata_schema_path, "`) does not exist",
             call. = FALSE)
      }

      schema_json <- jsonlite::read_json(metadata_schema_path,
                                         auto_unbox = TRUE)

      valid <- jsonvalidate::json_validate(metadata_json, schema_json,
                                           engine = "ajv", verbose = TRUE,
                                           greedy = TRUE)

      check <- as.logical(unclass(valid))
      if (!valid) {
        msgs <- attr(valid, "errors") %>%
          dplyr::transmute(
            m = ifelse(.data$keyword == "required",
                       paste("-", .data$message),
                       paste("-", .data$instancePath, .data$message))
          ) %>%
          dplyr::pull(.data$m)
      } else {
        msgs <- NULL
      }

      return(
        capture_check_cnd(
          check = check,
          file_path = file_path,
          msg_subject = "Metadata file contents",
          msg_attribute = "consistent with schema specifications",
          msg_verbs = c("matches", "must match"),
          details = paste(msgs, collapse = "\n "),
          error = TRUE))
    },
    error = function(e) {
      # This handler is used when an unrecoverable error is thrown. This can
      # happen when, e.g., the csv file cannot be parsed by read_csv(). In this
      # situation, we want to output all the validations until this point plus
      # this "unrecoverable" error.
      return(
        capture_check_cnd(
          check = FALSE,
          file_path = file_path,
          msg_subject = "Metadata file contents",
          msg_attribute = "consistent with schema specifications",
          msg_verbs = c("matches", "must match"),
          details = conditionMessage(e),
          error = TRUE))
    }
  )
}
