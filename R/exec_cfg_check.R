#' Execute a check function from the validations configuration file
#'
#' @param check_name [character] the name of the check function
#' @param validations_cfg [list] the the parsed `validaitons.yml` file
#' @param caller_env [environment] the environment of the calling function.
#'   This is usually generated from `rlang::caller_env()`
#' @param caller_call [call] the call of the calling function.
#'   This is usually generated from `rlang::caller_call()`
#' @noRd
exec_cfg_check <- function(check_name, validations_cfg, caller_env, caller_call) {
  fn_cfg <- validations_cfg[[check_name]]
  from_pkg <- !is.null(fn_cfg[["pkg"]])
  from_src <- !is.null(fn_cfg[["source"]])
  if (from_pkg) {
    # if the function is from a package, assume the package is installed and
    # extract it from that package.
    fn <- get(fn_cfg[["fn"]],
      envir = getNamespace(fn_cfg[["pkg"]])
    )
  } else if (from_src) {
    # TODO: Validate source script.
    # if it's a source script, we need to run the script locally to extract
    # the function.
    hub_path <- rlang::env_get(env = caller_env, nm = "hub_path")
    src <- fs::path(hub_path, fn_cfg[["source"]])
    source(src, local = TRUE)
    fn <- get(fn_cfg[["fn"]])
  } else {
    path <- rlang::env_get(env = caller_env, nm = "validations_cfg_path") # nolint
    msg <- c("Custom validation function {.var {check_name}}",
      "must specify either a {.arg pkg} or {.arg script} in {.path {path}}")
    cli::cli_abort(paste(msg, collapse = " "),
      call = caller_call,
      class = "custom_validation_cfg_malformed"
    )
  }

  # get the arguments from the caller environment
  caller_env_formals <- get_caller_env_formals(
    fn,
    caller_env,
    cfg_args = fn_cfg[["args"]]
  )
  # combine the arguments from the caller environment and the config
  args <- c(caller_env_formals, fn_cfg[["args"]])

  res <- try(rlang::exec(fn, !!!args), silent = TRUE)

  if (inherits(res, "try-error")) {
    return(
      capture_exec_error(
        file_path = caller_env_formals$file_path,
        msg = clean_msg(attr(res, "condition")$message),
        call = check_name
      )
    )
  }
  res
}

#' Get non-overridden variables from the calling environment
#'
#' When executing custom functions, we need to extract variables from the
#' validation function calling it, but we need to ensure two things:
#'
#' 1. match the variables with the arguments of the custom function
#' 2. respect the variables overridden from the config file
#'
#' @param fn [function] the custom function
#' @param caller_env [environment] the environment of the calling function.
#'   This is usually generated from `rlang::caller_env()`
#' @param caller_call [call] the call of the calling function.
#'   This is usually generated from `rlang::caller_call()`
#' @noRd
get_caller_env_formals <- function(fn, caller_env, cfg_args) {
  # find the arguments of the custom function
  fn_arg_names <- rlang::fn_fmls_names(fn)

  # variables available from the calling environment (e.g. hub_path, tbl, etc..)
  available_vars <- rlang::env_names(caller_env)

  # match the arguments from the calling environment,
  # discarding the ones not needed
  args_from_vars <- fn_arg_names %in% available_vars

  # do not include arguments that are specified in the config.
  not_config_args <- !fn_arg_names %in% names(cfg_args)
  caller_env_fmls <- fn_arg_names[args_from_vars & not_config_args]

  # extract these values from the calling environment,
  # replacing with `NULL` if they are missing.
  rlang::env_get_list(caller_env, nms = caller_env_fmls, default = NULL)
}
