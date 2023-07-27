validate_file <- function(hub_path, file_path) {
    checks <- list()
    class(checks) <- c("hub_validations", "list")

    checks$file_exists <- check_file_exists(file_path, hub_path)
    if (is_error(checks$file_exists)) return(checks)

    checks$file_name <- check_file_name(file_path)
    if (is_error(checks$file_exists)) return(checks)

    checks$file_location <- check_file_location(file_path)

    file_meta <- parse_file_name(file_path)
    round_id <- file_meta$round_id
    config_tasks <- hubUtils::read_config(hub_path, "tasks")

    checks$round_id_valid <- check_valid_round_id(round_id,
                                                  config_tasks,
                                                  file_path)
    if (is_error(checks$file_exists)) return(checks)

    checks$file_format <- check_file_format(file_path,
                                            hub_path,
                                            round_id)
    checks
}
