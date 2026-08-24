# Which checks to time, how to call each one, and what to hand it.
#
# Both run-benchmark.R and run-one-check.R need all three, which is why this is its own
# file. Each entry in CHECKS has:
#
#   name                 the check function
#   tbl                  which version of the submission the check is given: "chr" for
#                        the all-character one, "typed" for real column types, "none" if
#                        it needs no data.
#   compound_taskid_set  TRUE if the check takes a compound task ID set.
#
# check_context() reads only what a check's `tbl` and `compound_taskid_set` say it uses,
# so the memory measured against a check is its own and not the cost of loading data it
# never touched.
CHECKS <- list(
  # Not a check. This is the shared code beneath check_tbl_value_col and
  # check_tbl_value_col_ascending that works out which model task each row belongs
  # to. It is measured on its own because #355 replaces it.
  #
  # Those two callers each ask it about one output type at a time. Here it is asked
  # about all of them at once, which on these test hubs is the same thing, because
  # they only submit samples. On a hub with several output types it would do more
  # work than either caller does, so read the number as an upper bound.
  list(name = "match_tbl_to_model_task", tbl = "chr"),
  list(name = "check_tbl_values", tbl = "chr"),
  list(name = "check_tbl_values_required", tbl = "chr"),
  list(name = "check_tbl_value_col", tbl = "chr"),
  list(name = "check_tbl_value_col_ascending", tbl = "chr"),
  list(name = "check_tbl_rows_unique", tbl = "chr"),
  list(name = "check_tbl_spl_mt_unique", tbl = "chr"),
  list(
    name = "check_tbl_spl_compound_taskid_set",
    tbl = "chr"
  ),
  list(
    name = "check_tbl_spl_compound_tid",
    tbl = "chr",
    compound_taskid_set = TRUE
  ),
  list(
    name = "check_tbl_spl_non_compound_tid",
    tbl = "chr",
    compound_taskid_set = TRUE
  ),
  list(
    name = "check_tbl_spl_n",
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

# validate_model_data() runs more checks than the list above measures. These are the
# ones deliberately left out, and why. Listing them keeps warn_unmeasured_checks()
# below quiet until a genuinely new check turns up.
DELIBERATELY_UNMEASURED <- c(
  # Reading the submission is the benchmark's own setup cost rather than a check's,
  # and the baseline rows already measure it.
  "check_file_read",
  # These look at column names, column types and the round ID, so their work depends
  # on how many columns there are rather than how many rows. Grid-free validation
  # cannot change that, and they are too quick to register at any size.
  "check_valid_round_id_col",
  "check_tbl_unique_round_id",
  "check_tbl_match_round_id",
  "check_tbl_colnames",
  "check_tbl_col_types",
  # These two have nothing to do on these test hubs: there are no derived task IDs
  # for the first to check, and no pmf output type for the second.
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
      "note: validate_model_data() runs checks the benchmark does not measure:\n  ",
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
        ctx$tbl_chr,
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

# Reads the submission the way validate_model_data() reads it. It reads the file
# twice: once with every column as character, and once with real column types. For
# that second read it takes the types from the hub config when the file is csv, and
# from the file itself for any other format.
#
# Every check measured here is handed the character version, because that is what
# validate_model_data() hands them. The typed read is kept because a hub with a
# csv submission still pays for it in a real run, and a check added later may
# want it.
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

# check_tbl_spl_compound_taskid_set() wants the all-character version of the
# submission, so read that here whatever version the calling check asked for.
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
