# Function to create a valid sample submission for the testdata/hub-spl hub
create_spl_file <- function(
  round_id,
  compound_taskid_set = NULL,
  hub_path = test_path("testdata/hub-spl"),
  write = TRUE,
  ext = "parquet",
  out_datatype = c("schema", "chr"),
  n_samples = 10L
) {
  out_datatype <- match.arg(out_datatype)
  file_path <- create_file_path(round_id = round_id, ext = ext)
  config_tasks <- read_config(hub_path)

  tbl <- submission_tmpl(
    hub_path,
    round_id = round_id,
    compound_taskid_set = compound_taskid_set
  ) |>
    dplyr::filter(.data$output_type == "sample") |>
    dplyr::filter(
      reference_date + lubridate::weeks(horizon) == target_end_date
    ) |>
    dplyr::mutate(value = sample.int(n = 1000, size = length(value))) |>
    coerce_to_hub_schema(config_tasks)

  uniq_spl_ids <- unique(tbl$output_type_id)
  recode_spl_ids <- seq_along(uniq_spl_ids) |> as.character()

  tbl <- dplyr::mutate(
    tbl,
    output_type_id = dplyr::recode(
      output_type_id,
      !!!setNames(recode_spl_ids, uniq_spl_ids)
    )
  )

  if (n_samples > 1L) {
    rows_spl <- tbl |>
      dplyr::group_by(output_type_id) |>
      dplyr::count() |>
      dplyr::pull(n) |>
      unique()
    n <- nrow(tbl) / rows_spl

    tbl <- purrr::map(
      seq(0, (n_samples - 1) * n, by = n),
      function(.x) {
        tbl$output_type_id <- as.character(
          as.integer(tbl$output_type_id) + .x
        )
        tbl
      }
    ) |>
      purrr::list_rbind()
  }
  if (write) {
    out_path <- fs::path(hub_path, "model-output", file_path)
    switch(
      ext,
      csv = readr::write_csv(tbl, out_path),
      parquet = arrow::write_parquet(tbl, out_path)
    )
  }
  if (out_datatype == "chr") {
    tbl <- hubData::coerce_to_character(tbl)
  }
  tbl
}

create_file_path <- function(round_id, model_id = "flu-base", ext = "parquet") {
  fs::path(model_id, paste0(round_id, "-", model_id), ext = ext)
}

# A hub whose config declares a `compound_taskid_set` of `[]`, i.e. that nothing is a
# compound task ID and every task ID is sampled jointly.
empty_cts_hub <- function(env = parent.frame()) {
  hub_path <- withr::local_tempdir(.local_envir = env)
  fs::dir_copy(
    system.file("testhubs/samples", package = "hubValidations"),
    hub_path,
    overwrite = TRUE
  )
  fs::file_copy(
    test_path("testdata/configs/tasks-samples-empty-cts.json"),
    fs::path(hub_path, "hub-config", "tasks.json"),
    overwrite = TRUE
  )
  hub_path
}
