# Times and measures the memory of validation against the test hubs, so the
# grid-free work in #355 / #356 / #357 can be judged on numbers rather than hope.
#
# Usage:
#   HUBVALIDATIONS_BENCHMARK_SIZES=S,M Rscript _benchmark/run-benchmark.R
#
# To get the most memory the whole run ever used, which is what decides whether a
# change still fits on a machine, wrap it:
#   HUBVALIDATIONS_BENCHMARK_SIZES=L /usr/bin/time -l Rscript _benchmark/run-benchmark.R
#
# See README.md for the settings and what each mode reports.

# Row counts run into the tens of millions, and without this R writes them to the
# CSVs as 1.3e+07.
options(scipen = 999)

benchmark_dir <- dirname(
  sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
)
pkg_dir <- dirname(benchmark_dir)
source(file.path(benchmark_dir, "make-hub.R"))
source(file.path(benchmark_dir, "check-calls.R"))

env_default <- function(var, default) {
  value <- Sys.getenv(var)
  if (value == "") default else value
}

sizes <- strsplit(env_default("HUBVALIDATIONS_BENCHMARK_SIZES", "S"), ",")[[1]]
sizes <- trimws(sizes)
unknown <- setdiff(sizes, names(BENCHMARK_SIZES))
if (length(unknown) > 0) {
  stop(
    "Unknown size(s): ",
    paste(unknown, collapse = ", "),
    ". Available: ",
    paste(names(BENCHMARK_SIZES), collapse = ", "),
    call. = FALSE
  )
}
mode <- match.arg(
  env_default("HUBVALIDATIONS_BENCHMARK_MODE", "all"),
  c("all", "peak", "submission")
)
# "acefa" is ruarai's config as they sent it, with one model task. "mt<N>" splits
# it into N, so that deciding which model task a row belongs to (#355) actually has
# a decision to make.
variants <- trimws(
  strsplit(env_default("HUBVALIDATIONS_BENCHMARK_VARIANTS", "acefa"), ",")[[1]]
)
hubs_dir <- env_default(
  "HUBVALIDATIONS_BENCHMARK_HUBS",
  file.path(benchmark_dir, "hubs")
)
# A best effort rather than a guarantee. R only notices the limit between steps of
# its own work, so a check stuck inside one long operation in compiled code (a big
# join, which is what the large sizes risk) will run past it. Wrap the whole thing
# in `timeout` if you need a hard stop.
time_limit <- as.numeric(
  env_default("HUBVALIDATIONS_BENCHMARK_TIMEOUT", "1800")
)

# Identifies which version of the code ran: branch@sha, with -dirty added when there
# are uncommitted changes under R/.
#
# Only R/ counts, because that is the code being measured. Uncommitted changes to
# the benchmark itself do not make a measurement of the package unreproducible, and
# while the benchmark is being built they would mark every run dirty, which would
# make the marker useless.
git_id <- function(dir) {
  branch <- system2(
    "git",
    c("-C", dir, "rev-parse", "--abbrev-ref", "HEAD"),
    stdout = TRUE
  )
  sha <- system2(
    "git",
    c("-C", dir, "rev-parse", "--short", "HEAD"),
    stdout = TRUE
  )
  dirty <- length(
    system2("git", c("-C", dir, "status", "--porcelain", "R"), stdout = TRUE)
  ) >
    0
  paste0(branch, "@", sha, if (dirty) "-dirty" else "")
}

pkg_id <- git_id(pkg_dir)
# `label` is a free-text name for whatever is being tested. `pkg_id` always records
# the code version, so naming a run something memorable does not lose track of
# which version produced it.
label <- env_default("HUBVALIDATIONS_BENCHMARK_LABEL", pkg_id)

pkgload::load_all(pkg_dir, quiet = TRUE)

# Recorded but never changed by the benchmark. If hubUtils or hubData is upgraded
# without anyone noticing, these columns explain a jump in the numbers that would
# otherwise look mysterious.
hubutils_id <- as.character(utils::packageVersion("hubUtils"))
hubdata_id <- as.character(utils::packageVersion("hubData"))

sys_cols <- list(
  sysname = Sys.info()[["sysname"]],
  machine = Sys.info()[["machine"]],
  r_version = paste0(R.version$major, ".", R.version$minor)
)

# The "which run was this" columns are added here rather than by each caller, so
# every CSV carries the same ones without anybody having to remember. The header row
# is only written when the file does not exist yet, so the column order has to stay
# put: the measurements go between the identifying columns at the front and the
# version columns at the back.
append_row <- function(metrics, file, size, variant) {
  row <- cbind(
    data.frame(
      label = label,
      size = size,
      variant = variant,
      stringsAsFactors = FALSE
    ),
    metrics,
    data.frame(
      hubvalidations = pkg_id,
      hubutils = hubutils_id,
      hubdata = hubdata_id,
      sysname = sys_cols$sysname,
      machine = sys_cols$machine,
      r_version = sys_cols$r_version,
      stringsAsFactors = FALSE
    )
  )
  path <- file.path(benchmark_dir, file)
  utils::write.table(
    row,
    path,
    sep = ",",
    row.names = FALSE,
    qmethod = "double",
    col.names = !file.exists(path),
    append = file.exists(path)
  )
  invisible(row)
}

# One shared set of words for how a measurement ended, so the CSVs agree on what to
# call running out of memory. It lives in one place because the two modes had
# already drifted apart, with only one of them recognising "oom".
error_status <- function(message) {
  if (grepl("cannot allocate|memory exhausted", message)) {
    "oom"
  } else if (grepl("time limit", message)) {
    "timeout"
  } else {
    "error"
  }
}

# Memory ----------------------------------------------------------------------

# The most memory R itself held at once, used for the whole-file row. The per-check
# numbers do not come from here, because R's own counter cannot see memory that
# Arrow sets aside outside it. That is why `peak` mode asks the operating system for
# the figure instead.
reset_memory <- function() {
  invisible(gc(reset = TRUE))
}
r_peak_mb <- function() {
  sum(gc()[, "max used"] * c(56, 8)) / 1024^2
}

# How big the valid value grid is ----------------------------------------

# How many rows expand_model_out_grid() would build for one round. For each model
# task, multiply together how many values each of its task IDs allows, then
# multiply by how many output type IDs it has. Samples count as 1 there, because
# the table holds one row per combination of task IDs rather than one row per
# sample.
#
# Worked out from the config rather than by actually building the table, since on
# the larger sizes building it just to measure it would cost as much as the run
# itself.
config_grid_rows <- function(config, round_id) {
  # These test hubs always have a single round, so there is no need to look one up.
  # A config with several would need get_round_config(); writing that here would be
  # code that has never once run.
  round <- config$rounds[[1]]
  # A derived task ID is left blank in the table rather than given every possible
  # value, so counting its values would overstate the number that every measurement
  # gets compared against.
  derived <- get_config_derived_task_ids(config, round_id)
  dropped <- c(round$round_id, derived)
  sum(vapply(
    round$model_tasks,
    function(mt) {
      task_ids <- mt$task_ids[!names(mt$task_ids) %in% dropped]
      n_vals <- vapply(
        task_ids,
        \(x) length(unique(c(unlist(x$required), unlist(x$optional)))),
        numeric(1)
      )
      n_otid <- sum(vapply(
        mt$output_type,
        function(ot) {
          ids <- unique(c(
            unlist(ot$output_type_id$required),
            unlist(ot$output_type_id$optional)
          ))
          max(length(ids), 1)
        },
        numeric(1)
      ))
      prod(n_vals) * n_otid
    },
    numeric(1)
  ))
}

# Peak memory per check --------------------------------------------------------

# The measurement that still means something after the rewrite. The promise being
# made is that memory depends on how much data was submitted, not on how many rows
# the valid value grid has.
#
# The G sizes are how to test it: they all submit about 65k rows, and only the
# number of valid value grid rows changes between them. Compare one check's figure across G1,
# G2 and G3. Today it rises as the grid rows rise. If the promise holds it should
# stay about the same. That works whether or not the new code ever builds such a
# table.
#
# Each check gets a fresh process and the figure comes from the operating system,
# because that is the only one that counts everything the process is holding (see
# reset_memory() above).
peak_rss_command <- function() {
  if (Sys.info()[["sysname"]] == "Darwin") {
    list(args = "-l", pattern = "maximum resident set size", scale = 1 / 1024^2)
  } else {
    # On Linux, `time -v` reports the figure in kilobytes rather than bytes.
    list(
      args = "-v",
      pattern = "Maximum resident set size",
      scale = 1024 / 1024^2
    )
  }
}

parse_peak_mb <- function(output, spec) {
  line <- grep(spec$pattern, output, value = TRUE, ignore.case = TRUE)
  if (length(line) == 0L) {
    return(NA_real_)
  }
  value <- as.numeric(gsub("[^0-9]", "", line[[1]]))
  value * spec$scale
}

PEAK_RSS <- peak_rss_command()

# Rscript is taken from this R's own installation rather than from the PATH, so the
# check really runs under the R version the row says it did.
peak_subprocess <- function(check_name, hub, cache_path) {
  suppressWarnings(system2(
    "/usr/bin/time",
    c(
      PEAK_RSS$args,
      shQuote(file.path(R.home("bin"), "Rscript")),
      shQuote(file.path(benchmark_dir, "run-one-check.R")),
      shQuote(hub$path),
      shQuote(hub$file_path),
      shQuote(hub$round_id),
      shQuote(check_name),
      shQuote(cache_path),
      # The limit is passed down and applied by the process doing the work, since
      # that is the only place R can act on it, and macOS has no `timeout` command
      # by default.
      time_limit
    ),
    stdout = TRUE,
    stderr = TRUE
  ))
}

benchmark_peak <- function(check_name, scope, size, hub, cache_path) {
  output <- peak_subprocess(check_name, hub, cache_path)
  status <- attr(output, "status")
  peak_mb <- parse_peak_mb(output, PEAK_RSS)
  result_line <- grep("^BENCHMARK_RESULT", output, value = TRUE)
  parse_field <- function(field, default) {
    if (length(result_line) != 1L) {
      return(default)
    }
    sub(paste0(".*", field, "=([^ ]+).*"), "\\1", result_line)
  }
  elapsed_s <- as.numeric(parse_field("elapsed_s", NA_character_))
  # A check that fails is still a successful run of the script, so the exit code
  # alone cannot tell us. Recording what the check returned means a check that
  # stopped passing on a new size shows up, instead of looking like a suspiciously
  # quick success.
  result_class <- parse_field("class", NA_character_)
  ok <- is.null(status) || identical(status, 0L)
  if (!ok) {
    cat("    exit", status, ":", utils::tail(output, 3), "\n")
  }

  row <- append_row(
    data.frame(
      check = check_name,
      scope = scope,
      data_rows = hub$n_rows,
      grid_rows = hub$grid_rows,
      n_model_tasks = hub$n_model_tasks,
      peak_rss_mb = round(peak_mb),
      elapsed_s = round(elapsed_s, 2),
      result_class = result_class,
      # Worked out from what the process printed, so running out of memory or
      # overrunning the time limit can be told apart from any other failure. Those
      # are the most likely ways the largest sizes fail.
      status = if (ok) "ok" else error_status(paste(output, collapse = " ")),
      stringsAsFactors = FALSE
    ),
    "peak-results.csv",
    size,
    hub$variant
  )
  cat(sprintf(
    "  %-34s %-9s %8.0f MB peak RSS  %8.2f s  %-14s %s\n",
    check_name,
    scope,
    peak_mb,
    elapsed_s,
    result_class,
    row$status
  ))
  invisible(row)
}

# End-to-end ------------------------------------------------------------------

# Pulls every check result out of whatever structure validate_submission() returned.
# It gives back a flat list most of the time, but a nested one when a hub-config
# check stops it early, and this handles both by treating anything of class
# `hub_check` as a result to collect. Using unlist() instead would take each result
# apart into its own fields and lose the class we need to look at.
flatten_checks <- function(x) {
  if (inherits(x, "hub_check")) {
    return(list(x))
  }
  if (!is.list(x)) {
    return(list())
  }
  unlist(lapply(unname(x), flatten_checks), recursive = FALSE)
}

# A check can fail in two ways: it can report a problem with the data, or it can
# fall over itself. The last two classes here are the second kind, which is the
# likely outcome on the largest sizes. Leaving them out would record a run where
# every expensive check crashed as having no errors at all, i.e. as a clean
# baseline.
FAILING_CHECK_CLASSES <- c(
  "check_error",
  "check_failure",
  "check_exec_error",
  "check_exec_warn"
)

count_errors <- function(result) {
  sum(vapply(
    flatten_checks(result),
    \(x) inherits(x, FAILING_CHECK_CLASSES, which = FALSE),
    logical(1)
  ))
}

benchmark_submission <- function(size, hub) {
  prof_path <- file.path(
    benchmark_dir,
    sprintf("Rprof-%s-%s.out", size, hub$variant)
  )
  reset_memory()
  setTimeLimit(elapsed = time_limit, transient = TRUE)
  Rprof(prof_path, interval = 0.02, memory.profiling = FALSE)
  outcome <- tryCatch(
    {
      elapsed <- system.time(
        result <- validate_submission(
          hub_path = hub$path,
          file_path = hub$file_path,
          skip_submit_window_check = TRUE
        )
      )
      list(
        status = "ok",
        elapsed_s = elapsed[["elapsed"]],
        n_errors = count_errors(result)
      )
    },
    error = function(e) {
      list(
        status = error_status(conditionMessage(e)),
        elapsed_s = NA_real_,
        n_errors = NA_integer_,
        message = conditionMessage(e)
      )
    }
  )
  Rprof(NULL)
  setTimeLimit()

  if (!is.null(outcome$message)) {
    cat("  ", outcome$status, ": ", outcome$message, "\n", sep = "")
  }
  row <- append_row(
    data.frame(
      data_rows = hub$n_rows,
      grid_rows = hub$grid_rows,
      n_model_tasks = hub$n_model_tasks,
      elapsed_s = round(outcome$elapsed_s, 1),
      r_peak_mb = round(r_peak_mb()),
      status = outcome$status,
      n_errors = outcome$n_errors,
      stringsAsFactors = FALSE
    ),
    "results.csv",
    size,
    hub$variant
  )

  cat(sprintf(
    "  validate_submission           %8.1f s  %6.0f MB R peak  %s (%s errors)\n",
    outcome$elapsed_s,
    row$r_peak_mb,
    outcome$status,
    outcome$n_errors
  ))

  # The profile says *where* the time went, which is what distinguishes a real
  # improvement from a wash. The by-total view is filtered down to this package's
  # own functions, because unfiltered its top entries are all the error-handling
  # wrappers around every check, which tell you nothing about cost.
  if (file.exists(prof_path)) {
    summary <- summaryRprof(prof_path)

    self <- summary$by.self
    self <- self[self$self.pct >= 1, c("self.time", "self.pct", "total.pct")]
    cat("\n  self time (>=1%)\n")
    print(utils::head(self, 15))

    total <- summary$by.total
    ours <- grepl(
      "^\"(check_|expand_|match_|join_|get_|spl_|validate_|read_model_out)",
      rownames(total)
    )
    total <- total[ours, c("total.time", "total.pct", "self.pct")]
    cat("\n  hubValidations functions by total time (>=1%)\n")
    print(utils::head(total[total$total.pct >= 1, ], 25))
  }
  invisible(row)
}

# Run -------------------------------------------------------------------------

warn_unmeasured_checks(pkg_dir)

cat("label:      ", label, "\n")
cat("sizes:      ", paste(sizes, collapse = ", "), "\n")
cat("variants:   ", paste(variants, collapse = ", "), "\n")
cat("mode:       ", mode, "\n")
cat("hubUtils:   ", hubutils_id, "\n")
cat("hubData:    ", hubdata_id, "\n")

for (variant in variants) {
  for (size in sizes) {
    cat("\n=== size", size, "/ variant", variant, "===\n")
    hub <- make_benchmark_hub(
      size,
      variant = variant,
      hubs_dir = hubs_dir,
      benchmark_dir = benchmark_dir
    )
    config <- hubUtils::read_config(hub$path, "tasks")
    hub$grid_rows <- config_grid_rows(config, hub$round_id)
    cat(sprintf(
      "hub: %s\n%d submitted rows, %.0f grid rows for the round, %d model task(s)\n", # nolint: line_length_linter
      hub$path,
      hub$n_rows,
      hub$grid_rows,
      hub$n_model_tasks
    ))

    if (mode %in% c("all", "peak")) {
      cache_path <- file.path(
        tempdir(),
        paste0(
          "compound-taskid-set-",
          size,
          "-",
          variant,
          ".rds"
        )
      )
      unlink(cache_path)
      # One baseline for each way of reading the submission that is in use, because
      # the fixed cost being subtracted is loading the package *and* reading the
      # data that way. Subtracting a baseline that read nothing from a check that
      # read 13 million rows would blame the check for the reading.
      for (flavour in unique(vapply(CHECKS, \(x) x$tbl, character(1)))) {
        benchmark_peak(
          paste0("baseline_load_only_", flavour),
          "baseline",
          size,
          hub,
          cache_path
        )
      }
      # Works out the compound task ID set once and saves it, so none of the checks
      # being measured has to pay for it. Its own cost gets its own row rather than
      # being hidden inside another check's.
      if (any(vapply(CHECKS, \(x) isTRUE(x$compound_taskid_set), NA))) {
        benchmark_peak(
          "prepare_compound_taskid_set",
          "prep",
          size,
          hub,
          cache_path
        )
      }
      for (spec in CHECKS) {
        benchmark_peak(spec$name, spec$scope, size, hub, cache_path)
      }
    }
    if (mode %in% c("all", "submission")) {
      benchmark_submission(size, hub)
    }
  }
}

cat(
  "\nAppended to",
  benchmark_dir,
  "{results,peak-results}.csv\n"
)
