## --- Hash Table Utils --------------------------------------------------------
# Creates a table of hashes for each sample in the model output data tbl, checking
# the consistency of compound task ID values and non-compound task IDs values
# across samples/compound idxs.
# Performed separately across each modeling task (to allow for differences in
# compound task id sets across modeling tasks). This is achieved by using a full
# join between tbl sample data and the model output data sample grid for each
# modeling task. This means that only valid task id combinations are considered.
spl_hash_tbl <- function(tbl, round_id, config_tasks) {
  tbl <- tbl[tbl$output_type == "sample", names(tbl) != "value"]

  mt_spl_grid <- expand_model_out_grid(
    config_tasks = config_tasks,
    round_id = round_id,
    all_character = TRUE,
    include_sample_ids = TRUE,
    bind_model_tasks = FALSE
  )

  spl_mts <- has_spls_mt_grid(mt_spl_grid)

  mt_ids <- seq_along(mt_spl_grid)[spl_mts]
  mt_spl_grid <- mt_spl_grid[spl_mts] # remove non-sample grids
  mt_compound_taskids <- get_round_compound_task_ids(
    config_tasks,
    round_id
  )[spl_mts]

  purrr::map2(
    mt_spl_grid, mt_compound_taskids,
    ~ get_mt_spl_hash_tbl(
      spl_grid = .x, compound_taskids = .y,
      tbl = tbl,
      round_task_ids = hubUtils::get_round_task_id_names(
        config_tasks,
        round_id
      )
    )
  ) %>%
    purrr::map2(.y = mt_ids, ~ dplyr::mutate(.x, mt_id = .y)) %>% # add mt_id
    purrr::list_rbind()
}

get_mt_spl_hash_tbl <- function(spl_grid, compound_taskids, tbl, round_task_ids) {
  spl_grid <- dplyr::filter(
    spl_grid, .data$output_type == "sample"
  ) %>%
    dplyr::rename(compound_idx = "output_type_id")

  non_compound_taskids <- setdiff(
    round_task_ids,
    compound_taskids
  )

  tbl <- dplyr::inner_join(tbl, spl_grid,
    by = setdiff(
      names(tbl),
      c("output_type_id", "compound_idx")
    )
  ) %>%
    dplyr::group_by(
      .data$output_type_id
    ) %>%
    dplyr::arrange(
      dplyr::pick(dplyr::all_of(non_compound_taskids)),
      .by_group = TRUE
    )

  split(tbl, f = tbl$output_type_id) %>%
    purrr::map(
      function(.x, compound_taskids, non_compound_taskids) {
        tibble::tibble(
          compound_idx = names(sort(table(.x$compound_idx), decreasing = TRUE))[1L],
          n_compound_idx = length(unique(.x$compound_idx)),
          output_type_id = unique(.x$output_type_id),
          hash_non_comp_tid = rlang::hash(.x[, non_compound_taskids])
        )
      },
      non_compound_taskids = non_compound_taskids,
      compound_taskids = compound_taskids
    ) %>%
    purrr::list_rbind()
}
# Get output type IDs associated with a given hash from the sample hash table
get_hash_out_type_ids <- function(hash_tbl, hash, hash_type = "hash_non_comp_tid",
                                  n = NULL) {
  out <- hash_tbl[
    hash_tbl[[hash_type]] %in% hash,
    "output_type_id",
    drop = TRUE
  ]

  if (is.null(n)) {
    out
  } else {
    utils::head(out, n)
  }
}

get_round_compound_task_ids <- function(config_tasks, round_id) {
  round_mt <- hubUtils::get_round_model_tasks(config_tasks, round_id)
  purrr::map(
    round_mt,
    ~ {
      output_type_id_params <- purrr::pluck(
        .x,
        "output_type",
        "sample",
        "output_type_id_params"
      )

      if (is.null(output_type_id_params)) {
        return(NULL)
      } else {
        if (is.null(output_type_id_params$compound_taskid_set)) {
          return(hubUtils::get_round_task_id_names(config_tasks, round_id))
        } else {
          output_type_id_params$compound_taskid_set
        }
      }
    }
  )
}

## --- v3 sample check utils ---------------------------------------------------
has_spls_tbl <- function(tbl) {
  "sample" %in% tbl$output_type
}

has_spls_mt <- function(mt) {
  "sample" %in% names(mt$output_type)
}

has_spls_round <- function(config_tasks, round_id) {
  hubUtils::get_round_model_tasks(config_tasks, round_id) %>%
    purrr::map_lgl(~ has_spls_mt(.x))
}

has_spls_mt_grid <- function(grid_l) {
  purrr::map_lgl(grid_l, ~ has_spls_tbl(.x))
}

skip_v3_spl_check <- function(file_path, call = rlang::caller_call()) {
  capture_check_info(
    file_path = file_path,
    msg = "No v3 samples found in model output data to check. Skipping {.code {call}} check."
  )
}
