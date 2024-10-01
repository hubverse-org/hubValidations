execute_custom_checks <- function(validations_cfg_path = NULL) {
  caller_env <- rlang::caller_env()
  caller_call <- rlang::caller_call()

  if (!is.null(validations_cfg_path)) {
    if (!fs::file_exists(validations_cfg_path)) {
      cli::cli_abort(
        "Validations .yml file not found at {.path {validations_cfg_path}}",
        call = caller_call
      )
    }
  }

  if (is.null(validations_cfg_path)) {
    default_cfg_path <- fs::path(
      rlang::env_get(env = caller_env, nm = "hub_path"),
      "hub-config", "validations.yml"
    )
    if (!fs::file_exists(default_cfg_path)) {
      return(NULL)
    } else {
      validations_cfg_path <- default_cfg_path
    }
  }

  validations_cfg <- config::get(
    value = rlang::call_name(caller_call),
    config = rlang::env_get(env = caller_env, nm = "round_id"),
    file = validations_cfg_path
  )

  if (is.null(validations_cfg)) {
    return(NULL)
  }

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
