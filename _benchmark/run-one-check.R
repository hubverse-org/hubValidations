# Runs one check in a process of its own, so the caller can ask the operating system
# how much memory it used at its peak.
#
# Not meant to be run by hand: run-benchmark.R's `peak` mode starts it under the
# system's `time` command. Asking from outside is the only reliable way to get that
# figure, for the reasons set out next to reset_memory() in run-benchmark.R.
#
# Usage:
#   Rscript _benchmark/run-one-check.R <hub_path> <file_path> <round_id> <check>
#     [<compound_taskid_set_cache> [<time_limit_seconds>]]
#
# Two names here are not real checks:
#   baseline_load_only_<version>  load the package, read the submission that way,
#                                 and run nothing. Subtracted from the real checks
#                                 so their figures exclude the setup.
#   prepare_compound_taskid_set   work out the compound task ID set and save it, so
#                                 that none of the measured checks has to.

options(scipen = 999)

args <- commandArgs(trailingOnly = TRUE)
if (!length(args) %in% c(4L, 5L, 6L)) {
  stop(
    "Usage: run-one-check.R <hub_path> <file_path> <round_id> <check> ",
    "[<cache> [<time_limit>]]"
  )
}
hub_path <- args[[1]]
file_path <- args[[2]]
round_id <- args[[3]]
check_name <- args[[4]]
cache_path <- if (length(args) >= 5L) args[[5]] else NULL
time_limit <- if (length(args) == 6L) as.numeric(args[[6]]) else Inf

benchmark_dir <- dirname(
  sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
)
pkg_dir <- dirname(benchmark_dir)
pkgload::load_all(pkg_dir, quiet = TRUE)
source(file.path(benchmark_dir, "check-calls.R"))

BASELINE_PREFIX <- "baseline_load_only_"
is_baseline <- startsWith(check_name, BASELINE_PREFIX)
is_prepare <- identical(check_name, "prepare_compound_taskid_set")

# A baseline reads the submission one way and then stops. Subtracting it from a
# check given the submission the same way leaves that check's own cost.
spec <- if (is_baseline) {
  list(name = check_name, tbl = sub(BASELINE_PREFIX, "", check_name))
} else if (is_prepare) {
  list(name = check_name, tbl = "chr")
} else {
  check_spec(check_name)
}

ctx <- check_context(
  hub_path = hub_path,
  file_path = file_path,
  round_id = round_id,
  spec = spec,
  compound_taskid_set_path = cache_path,
  # Only the prepare step is allowed to work the set out. A check that simply uses
  # it has to load the saved copy, because working it out here would do a whole
  # extra job inside the process being measured, and the memory figure would then be
  # whichever of the two was larger — exactly the mix-up the saved copy prevents.
  allow_derive = is_prepare
)

# A best effort, as in the caller: R only notices the limit between steps of its own
# work, so a check stuck inside one long operation in compiled code can run past it.
if (is.finite(time_limit)) {
  setTimeLimit(elapsed = time_limit, transient = TRUE)
}

if (is_baseline) {
  elapsed <- c(elapsed = 0)
  result <- NULL
} else if (is_prepare) {
  elapsed <- system.time(
    result <- read_compound_taskid_set(cache_path, ctx)
  )
} else {
  elapsed <- system.time(result <- check_call(check_name, ctx)())
}

# What the check returned is printed so the caller can record it. A check that fails
# still finishes normally as far as the system is concerned, so without this it
# would land in the CSV as a suspiciously quick success.
cat(sprintf(
  "BENCHMARK_RESULT elapsed_s=%.3f class=%s\n",
  elapsed[["elapsed"]],
  if (is.null(result)) "none" else class(result)[1]
))
