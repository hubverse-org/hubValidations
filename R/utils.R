get_hub_file_formats <- function(hub_path, round_id) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  round_idx <- hubUtils::get_round_idx(config_tasks, round_id)
  file_formats <- config_tasks[["rounds"]][[round_idx]]$file_format
  if (!is.null(file_formats)) {
    return(file_formats)
  }

  config_admin <- hubUtils::read_config(hub_path, "admin")
  config_admin$file_format
}

get_hub_timezone <- function(hub_path) {
  config_admin <- hubUtils::read_config(hub_path, "admin")
  config_admin$timezone
}

get_hub_model_output_dir <- function(hub_path) {
  config_admin <- hubUtils::read_config(hub_path, "admin")
  model_output_dir <- config_admin$model_output_dir
  if (is.null(model_output_dir)) "model-output" else model_output_dir
}

abs_file_path <- function(file_path, hub_path) {
  fs::path(
    hub_path,
    get_hub_model_output_dir(hub_path),
    file_path
  )
}

rel_file_path <- function(file_path, hub_path) {
  fs::path(
    get_hub_model_output_dir(hub_path),
    file_path
  )
}

get_file_round_id <- function(file_path) {
  parse_file_name(file_path)$round_id
}


get_file_round_idx <- function(file_path, hub_path) {
  round_id <- get_file_round_id(file_path)
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  hubUtils::get_round_idx(config_tasks, round_id)
}

get_file_round_config <- function(file_path, hub_path) {
  config_tasks <- hubUtils::read_config(hub_path, "tasks")
  round_idx <- get_file_round_idx(file_path, hub_path)
  config_tasks[["rounds"]][[round_idx]]
}

is_round_id_from_variable <- function(file_path, hub_path) {
  get_file_round_config(file_path, hub_path)[["round_id_from_variable"]]
}


conc_rows <- function(tbl, mask = NULL, sep = "-") {
  if (is.null(mask)) {
    tbl_dim <- dim(tbl)
    rows <- split(
      unlist(tbl, use.names = FALSE),
      rep(1:tbl_dim[1], tbl_dim[2])
    )
    out <- lapply(rows, function(x) {
      paste(x, collapse = sep)
    }) %>%
      unlist(use.names = FALSE)
    return(out)
  } else {
    vec <- as.matrix(tbl)[!mask]
    if (all(rowSums(mask) == ncol(mask) - 1L)) {
      return(vec)
    }
    if (any(rowSums(mask) == ncol(mask))) {
      indx <- which(!mask, arr.ind = TRUE)[, "row"]
      empty_indx <- setdiff(1:nrow(tbl), indx)
      empty_out <- rep("", length(empty_indx))

      rows <- split(vec, indx)
      out <- lapply(rows, function(x) {
        paste(x, collapse = sep)
      }) %>%
        unlist(use.names = FALSE)
      return(
        c(out, empty_out)[order(c(as.integer(names(rows)), empty_indx))]
      )
    }
    indx <- which(!mask, arr.ind = TRUE)[, "row"]
    rows <- split(vec, indx)
    lapply(rows, function(x) {
      paste(x, collapse = sep)
    }) %>%
      unlist(use.names = FALSE)
  }
}
