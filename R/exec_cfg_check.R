exec_cfg_check <- function(check_name, validations_cfg, caller_env, caller_call) {
  fn_cfg <- validations_cfg[[check_name]]
  if (!is.null(fn_cfg[["pkg"]])) {
    fn <- get(fn_cfg[["fn"]],
      envir = getNamespace(fn_cfg[["pkg"]])
    )
  } else if (!is.null(fn_cfg[["source"]])) {
    # TODO Validate source script.
    hub_path <- rlang::env_get(env = caller_env, nm = "hub_path")
    src <- fs::path(hub_path, fn_cfg[["source"]])
    source(src, local = TRUE)
    fn <- get(fn_cfg[["fn"]])
  }

  caller_env_formals <- get_caller_env_formals(
    fn, caller_env,
    cfg_args = fn_cfg[["args"]]
  )
  args <- c(
    caller_env_formals,
    fn_cfg[["args"]]
  )

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

get_caller_env_formals <- function(fn, caller_env, cfg_args) {
  caller_env_fmls <- rlang::fn_fmls_names(fn)[
    rlang::fn_fmls_names(fn) %in% rlang::env_names(caller_env) &
      !rlang::fn_fmls_names(fn) %in% names(cfg_args)
  ]
  rlang::env_get_list(caller_env, nms = caller_env_fmls, default = NULL)
}
