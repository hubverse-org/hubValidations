# The list of checks the benchmark measures, how validate_model_data() calls each
# one, and what each needs to be given. Used by run-benchmark.R and by
# run-one-check.R, which runs a single check on its own so its memory use can be
# measured cleanly.

# `scope` says whether the grid-free work is expected to change a check, and it is
# the main reason this list exists. These test hubs submit samples, so a fair chunk
# of every run is spent in the sample checks. Without the label, that time would
# make a successful change look disappointing, because it was never going to move.
#
# - `in`        — rewritten by #355-#357.
# - `follow-up` — the sample checks. #355 leaves them out, but they work out which
#   model task a row belongs to in exactly the same way it is replacing: build the
#   valid value grid for each model task, then match the data against it.
#   check_tbl_spl_mt_unique does that directly, and spl_hash_tbl()
#   (utils-samples.R) and get_tbl_compound_taskid_set() (compound_taskid-utils.R)
#   do it too. So their cost can be dealt with by reusing #355's new helper rather
#   than by anything new, which is why they are tracked separately instead of
#   written off.
# - `other`     — neither, e.g. check_tbl_rows_unique.
#
# The labels describe the plan as it stands for #355-#357. Once that work lands they
# describe what it did touch, so they should not be edited in place: rows already
# saved in the CSVs would stop meaning the same thing as new ones with the same
# label.
#
# `tbl` says which version of the submission a check is given, and
# `compound_taskid_set` whether it needs that set. check_context() uses both, so a
# process measuring one check reads only what that check actually uses. Reading the
# other version as well would add all of its memory to the figure being blamed on
# the check.
CHECKS <- list(
  # Not a check itself. It is the shared code underneath check_tbl_value_col and
  # check_tbl_value_col_ascending that works out which model task each row belongs
  # to, measured on its own because #355 replaces it. Its two real callers each
  # name one output type; leaving that unset here covers all of them at once. On
  # these test hubs that is the same thing, since they only use samples, and on a
  # hub with more it is deliberately the worst case.
  list(name = "match_tbl_to_model_task", scope = "in", tbl = "chr"),
  list(name = "check_tbl_values", scope = "in", tbl = "chr"),
  list(name = "check_tbl_values_required", scope = "in", tbl = "chr"),
  list(name = "check_tbl_value_col", scope = "in", tbl = "typed"),
  list(name = "check_tbl_value_col_ascending", scope = "in", tbl = "chr"),
  list(name = "check_tbl_rows_unique", scope = "other", tbl = "chr"),
  list(name = "check_tbl_spl_mt_unique", scope = "follow-up", tbl = "chr"),
  list(
    name = "check_tbl_spl_compound_taskid_set",
    scope = "follow-up",
    tbl = "chr"
  ),
  list(
    name = "check_tbl_spl_compound_tid",
    scope = "follow-up",
    tbl = "chr",
    compound_taskid_set = TRUE
  ),
  list(
    name = "check_tbl_spl_non_compound_tid",
    scope = "follow-up",
    tbl = "chr",
    compound_taskid_set = TRUE
  ),
  list(
    name = "check_tbl_spl_n",
    scope = "follow-up",
    tbl = "chr",
    compound_taskid_set = TRUE
  )
)

check_spec <- function(name) {
  spec <- Filter(\(x) identical(x$name, name), CHECKS)
  if (length(spec) != 1L) {
    stop("No check spec for '", name, "'", call. = FALSE)
  }
  spec[[1]]
}

# Checks that validate_model_data() runs but the benchmark does not time, and why.
# Listed so the note below stays quiet until a genuinely new check turns up.
DELIBERATELY_UNMEASURED <- c(
  # Reading the submission is the benchmark's own setup cost, and it is already
  # measured by the baseline rows.
  "check_file_read",
  # These look at column names, types and the round, so their work depends on the
  # number of columns rather than the number of rows. Grid-free validation cannot
  # change them, and they are too quick to register at any size.
  "check_valid_round_id_col",
  "check_tbl_unique_round_id",
  "check_tbl_match_round_id",
  "check_tbl_colnames",
  "check_tbl_col_types",
  # These do nothing on these test hubs, which have no derived task IDs and no
  # probability-mass output type.
  "check_tbl_derived_task_id_vals",
  "check_tbl_value_col_sum1"
)

# `inst/check_table.csv` is the package's own record of which checks
# validate_model_data() runs, so comparing against it tells us when the list above
# has fallen behind. A check added there but not here would simply never be
# measured, which is exactly the "the rewrite broke something we weren't watching"
# gap this benchmark exists to close. It only prints a note rather than stopping,
# since an unmeasured check is no reason to abandon a run.
warn_unmeasured_checks <- function(pkg_dir) {
  table_path <- file.path(pkg_dir, "inst", "check_table.csv")
  if (!file.exists(table_path)) {
    return(invisible(NULL))
  }
  check_table <- utils::read.csv(table_path)
  expected <- check_table$check.fun[
    check_table$parent.fun == "validate_model_data" & !check_table$optional
  ]
  measured <- vapply(CHECKS, \(x) x$name, character(1))
  missing <- setdiff(expected, c(measured, DELIBERATELY_UNMEASURED))
  if (length(missing) > 0L) {
    cat(
      "note: validate_model_data() runs checks this harness does not measure:\n  ",
      paste(missing, collapse = ", "),
      "\n"
    )
  }
  invisible(missing)
}

# Each check is called the way validate_model_data() calls it, so a timing reflects
# the real thing rather than a convenient approximation. The calls are written out
# one by one, rather than generated from a table of argument names, so they can be
# compared against validate_model_data() by eye, which is this file's whole job.
# The one exception is match_tbl_to_model_task, which validate_model_data() does not
# call directly; see its entry above.
check_call <- function(name, ctx) {
  switch(
    name,
    match_tbl_to_model_task = function() {
      match_tbl_to_model_task(
        ctx$tbl_chr,
        ctx$config,
        ctx$round_id,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_values = function() {
      check_tbl_values(
        ctx$tbl_chr,
        ctx$round_id,
        ctx$file_path,
        ctx$hub_path,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_values_required = function() {
      check_tbl_values_required(
        ctx$tbl_chr,
        ctx$round_id,
        ctx$file_path,
        ctx$hub_path,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_value_col = function() {
      check_tbl_value_col(
        ctx$tbl,
        ctx$round_id,
        ctx$file_path,
        ctx$hub_path,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_value_col_ascending = function() {
      check_tbl_value_col_ascending(
        ctx$tbl_chr,
        ctx$file_path,
        ctx$hub_path,
        ctx$round_id,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_rows_unique = function() {
      check_tbl_rows_unique(ctx$tbl_chr, ctx$file_path, ctx$hub_path)
    },
    check_tbl_spl_mt_unique = function() {
      check_tbl_spl_mt_unique(
        ctx$tbl_chr,
        ctx$round_id,
        ctx$file_path,
        ctx$hub_path,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_spl_compound_taskid_set = function() {
      check_tbl_spl_compound_taskid_set(
        ctx$tbl_chr,
        ctx$round_id,
        ctx$file_path,
        ctx$hub_path,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_spl_compound_tid = function() {
      check_tbl_spl_compound_tid(
        ctx$tbl_chr,
        ctx$round_id,
        ctx$file_path,
        ctx$hub_path,
        compound_taskid_set = ctx$compound_taskid_set,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_spl_non_compound_tid = function() {
      check_tbl_spl_non_compound_tid(
        ctx$tbl_chr,
        ctx$round_id,
        ctx$file_path,
        ctx$hub_path,
        compound_taskid_set = ctx$compound_taskid_set,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    check_tbl_spl_n = function() {
      check_tbl_spl_n(
        ctx$tbl_chr,
        ctx$round_id,
        ctx$file_path,
        ctx$hub_path,
        compound_taskid_set = ctx$compound_taskid_set,
        derived_task_ids = ctx$derived_task_ids
      )
    },
    stop("No call defined for check '", name, "'", call. = FALSE)
  )
}

# validate_model_data() reads the submission twice: once with everything as text,
# and once with proper column types. For that second read it uses the types from
# the hub config for csv files, and the types stored in the file itself otherwise.
# Copying that split matters, because reading a parquet test hub with the config's
# types would measure the value-column check against types it never actually
# receives in practice.
read_tbl_flavour <- function(flavour, file_path, hub_path) {
  switch(
    flavour,
    none = NULL,
    chr = read_model_out_file(file_path, hub_path, coerce_types = "chr"),
    typed = read_model_out_file(
      file_path,
      hub_path,
      coerce_types = if (fs::path_ext(file_path) == "csv") "hub" else "none"
    ),
    stop("Unknown table flavour '", flavour, "'", call. = FALSE)
  )
}

#' Context for one check
#'
#' @param spec the check's entry in `CHECKS`, or `NULL` to read nothing at all,
#'   which is what the baseline rows do.
#' @param compound_taskid_set_path file holding a saved copy of the compound task ID
#'   set. Working that set out means building a valid value grid, and the
#'   memory figure we record is the highest point reached at any moment. So doing it
#'   in the same process as a check that merely *uses* the set would report
#'   whichever of the two was larger, and credit it to the check. Loading the saved
#'   copy instead keeps each measurement to that check's own work.
check_context <- function(
  hub_path,
  file_path,
  round_id,
  spec = NULL,
  compound_taskid_set_path = NULL,
  allow_derive = TRUE
) {
  flavour <- if (is.null(spec)) "none" else spec$tbl
  tbl <- read_tbl_flavour(flavour, file_path, hub_path)
  ctx <- list(
    hub_path = hub_path,
    file_path = file_path,
    round_id = round_id,
    config = hubUtils::read_config(hub_path, "tasks"),
    tbl = if (identical(flavour, "typed")) tbl else NULL,
    tbl_chr = if (identical(flavour, "chr")) tbl else NULL,
    derived_task_ids = get_hub_derived_task_ids(hub_path, round_id)
  )
  if (isTRUE(spec$compound_taskid_set)) {
    ctx$compound_taskid_set <- read_compound_taskid_set(
      compound_taskid_set_path,
      ctx,
      allow_derive = allow_derive
    )
  }
  ctx
}

# check_tbl_spl_compound_taskid_set() wants the all-text version of the submission,
# so read that here whatever version the calling check itself asked for.
derive_compound_taskid_set <- function(ctx) {
  tbl_chr <- ctx$tbl_chr
  if (is.null(tbl_chr)) {
    tbl_chr <- read_tbl_flavour("chr", ctx$file_path, ctx$hub_path)
  }
  check_tbl_spl_compound_taskid_set(
    tbl_chr,
    ctx$round_id,
    ctx$file_path,
    ctx$hub_path,
    derived_task_ids = ctx$derived_task_ids
  )$compound_taskid_set
}

read_compound_taskid_set <- function(path, ctx, allow_derive = TRUE) {
  if (!is.null(path) && file.exists(path)) {
    return(readRDS(path))
  }
  # Stopping here, rather than quietly working the set out, keeps a missing file
  # visible. The prepare step is what creates it, and if that step was killed (on
  # the largest sizes, running out of memory is the likely way), working it out here
  # would fold that whole job into this check's memory figure and report it as the
  # check's own.
  if (!allow_derive) {
    stop(
      "No compound task ID set cache at '",
      path,
      "'; the prepare step must run first.",
      call. = FALSE
    )
  }
  set <- derive_compound_taskid_set(ctx)
  if (!is.null(path)) {
    saveRDS(set, path)
  }
  set
}
