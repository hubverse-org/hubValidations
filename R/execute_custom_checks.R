execute_custom_checks <- function(validations_cfg_path = NULL) {
  # There is more than one function that will call this function. These two
  # variables help us to pass the variables from that function to the custom
  # functions.
  #
  # Having the calling function's environment gives us access to the variables
  caller_env <- rlang::caller_env()
  # Knowing the calling function's name allows us to select the correct
  # custom validation function.
  caller_call <- rlang::caller_call()

  missing_file <- !is.null(validations_cfg_path) &&
    !fs::file_exists(validations_cfg_path)
  if (missing_file) {
    cli::cli_abort(
      "Validations .yml file not found at {.path {validations_cfg_path}}",
      call = caller_call,
      class = "custom_validation_yml_missing"
    )
  }

  # if the validations_cfg_path is not specified, we check if it exists in
  # the hub.
  if (is.null(validations_cfg_path)) {
    validations_cfg_path <- fs::path(
      rlang::env_get(env = caller_env, nm = "hub_path"),
      "hub-config", "validations.yml"
    )
  }
  # no need to perform checks if there is no config file
  if (!fs::file_exists(validations_cfg_path)) {
    return(NULL)
  }

  # extract the correct function from the config file based on the round ID
  validations_cfg <- config::get(
    value = rlang::call_name(caller_call),
    config = rlang::env_get(env = caller_env, nm = "round_id"),
    file = validations_cfg_path
  )

  # again, no need to perform checks if no checks exist
  if (is.null(validations_cfg)) {
    return(NULL)
  }

  # Create the list to contain the validation output
  out <- vector("list", length(validations_cfg)) |>
    stats::setNames(names(validations_cfg))

  for (check_name in names(out)) {
    out[[check_name]] <- exec_cfg_check(
      check_name,
      validations_cfg,
      caller_env,
      caller_call
    )

    if (is_any_error(out[[check_name]])) {
      break
    }
  }
  purrr::compact(out) |> as_hub_validations()
}
