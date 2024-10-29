test_custom_checks_caller <- function(
    # nolint start
    hub_path = system.file("testhubs/flusight", package = "hubValidations"),
    file_path = "hub-ensemble/2023-05-08-hub-ensemble.parquet",
    validations_cfg_path = NULL) {
  round_id <- parse_file_name(file_path)$round_id
  tbl <- read_model_out_file(
    file_path = file_path,
    hub_path = hub_path
  )
  # nolint end
  execute_custom_checks(validations_cfg_path = validations_cfg_path)
}

stand_up_custom_check_hub <- function(
    # nolint start
    hub_path = system.file("testhubs/flusight", package = "hubValidations"),
    new_path = NULL,
    check_path = testthat::test_path("testdata/src/R/src_check_works.R"),
    args = list("src_check_works" = list(extra_msg = 'Extra arguments passed'))
    ) {
  if (is.null(new_path)) {
    return()
  }
  fs::dir_copy(hub_path, new_path)
  new_path <- fs::path(new_path, fs::path_file(hub_path))
  script_path <- fs::path(new_path, "src/validations/R/test-check.R")
  fs::dir_create(fs::path_dir(script_path))
  fs::file_copy(check_path, script_path, overwrite = TRUE)
  n <- seq_along(args)
  fun <- lapply(n, function(fn) {
      list(
        fn = names(args)[[fn]],
        source = fs::path_rel(script_path, start = new_path),
        args = args[[fn]]
      )
  })
  names(fun) <- paste0("check_", n)
  yml <- list(
    "default" = list(
      "test_custom_checks_caller" = fun
    )
  )
  # nolint end
  writeLines(yaml::as.yaml(yml), fs::path(new_path, "hub-config", "validations.yml"))
  return(new_path)
}
