# Validation benchmark

Measures how long hub validation takes and how much memory it needs, so the
grid-free rewrite in
[#355](https://github.com/hubverse-org/hubValidations/issues/355),
[#356](https://github.com/hubverse-org/hubValidations/issues/356) and
[#357](https://github.com/hubverse-org/hubValidations/issues/357) can be judged on
numbers. Current results: [`prof-summary.md`](prof-summary.md).

Not part of the package; `_benchmark/` is in `.Rbuildignore`.

## Quick start

```sh
# time validating a whole file, at two sizes
HUBVALIDATIONS_BENCHMARK_SIZES=S,M HUBVALIDATIONS_BENCHMARK_MODE=submission \
  Rscript _benchmark/run-benchmark.R

# time and memory for each check separately
HUBVALIDATIONS_BENCHMARK_SIZES=M HUBVALIDATIONS_BENCHMARK_MODE=peak \
  Rscript _benchmark/run-benchmark.R
```

Test hubs are built under `_benchmark/hubs/` the first time they are needed and
reused after. Results are appended to the CSVs.

## What it measures

| mode | what it does | writes to |
|---|---|---|
| `submission` | validates one whole file and profiles where the time went | `results.csv` |
| `peak` | runs each check on its own, recording time and memory | `peak-results.csv` |
| `all` | both | both |

`peak` runs each check in a separate process and asks the operating system how much
memory it used, because R's own counter cannot see memory that Arrow sets aside
outside it.

## The test hubs

All generated from one real hub config, shared by a user (ruarai) on
[#295](https://github.com/hubverse-org/hubValidations/issues/295#issuecomment-5029770516)
because validating their submissions was slow. Same config and same random seed
every time, so the hubs come out identical.

Two things vary independently.

### Size

How much data is submitted, and how many rows the config's valid value combinations
grid has. Called the **valid value grid** from here on.

| size | submitted rows | valid value grid rows |
|---|---:|---:|
| S | 18,000 | 25,200 |
| M | 460,000 | 237,510 |
| L | 13,000,000 | 3,887,250 |
| G1 | 65,000 | 11,661,750 |
| G2 | 65,000 | 38,872,500 |
| G3 | 65,000 | 77,745,000 |

- **S, M, L** grow both together, like a real hub. L is ruarai's hub exactly.
- **G1, G2, G3** hold the submitted data still and grow only the config, so any
  change in memory has to be caused by the config rather than by the data.

### Shape

How many model tasks the config is split into, set with
`HUBVALIDATIONS_BENCHMARK_VARIANTS`.

| shape | model tasks |
|---|---|
| `acefa` | 1, as in ruarai's config |
| `mt3`, `mt7`, … | 3, 7, … |

Splitting shares the same set of values out between the model tasks, so the number
of valid value grid rows stays the same and only the number of model tasks changes.

## The two questions it answers

**Is validation faster?** Run `submission` mode at size L and compare
`elapsed_s` against the baseline in `prof-summary.md`.

**Does memory still depend on the config rather than the data?** Run `peak` mode
across G1, G2 and G3, which all submit ~65,000 rows while the config allows 11.7M,
38.9M and 77.7M valid value grid rows. Then read one check's `peak_rss_mb` across the
three:

- rising with the grid rows means memory still depends on the config.
  `check_tbl_values_required` currently reads 3,885 MB then 10,397 MB.
- staying level means it now depends only on the submitted data, which is what the
  rewrite is for. `check_tbl_rows_unique` already does this, reading ~283 MB at both.

Peak memory moves by around 20% between runs, so only believe a change larger than
that.

## Settings

| variable | default | meaning |
|---|---|---|
| `HUBVALIDATIONS_BENCHMARK_SIZES` | `S` | comma-separated sizes to run |
| `HUBVALIDATIONS_BENCHMARK_VARIANTS` | `acefa` | comma-separated shapes |
| `HUBVALIDATIONS_BENCHMARK_MODE` | `all` | `peak`, `submission` or `all` |
| `HUBVALIDATIONS_BENCHMARK_TIMEOUT` | `1800` | seconds allowed per measurement |
| `HUBVALIDATIONS_BENCHMARK_LABEL` | the code version | a name for the run |
| `HUBVALIDATIONS_BENCHMARK_HUBS` | `_benchmark/hubs` | where test hubs are built |

To get the most memory a whole run needed, wrap the command:

```sh
HUBVALIDATIONS_BENCHMARK_SIZES=L /usr/bin/time -l Rscript _benchmark/run-benchmark.R
```

## Reading the results

| column | meaning |
|---|---|
| `elapsed_s` | how long it took |
| `peak_rss_mb` | the most memory needed at once |
| `r_peak_mb` | the most memory R itself held (whole-file rows) |
| `grid_rows` | how many valid value grid rows the config allows for the round |
| `data_rows` | how many rows were submitted |
| `scope` | whether the rewrite should change this check: see below |
| `result_class` | what the check returned, so a failure is not read as a fast pass |
| `status` | `ok`, `error`, `oom` or `timeout` |

Some rows in `peak-results.csv` are setup rather than checks.
`baseline_load_only_*` loads the package and reads the submission but runs no
check, so subtract it from a check that read the submission the same way.
`prepare_compound_taskid_set` works out a value the sample checks need, once, so
none of them is charged for it.

`scope` says whether a check is expected to move:

- **`in`** — rewritten by #355–#357.
- **`follow-up`** — the sample checks. #355 leaves them out, but they decide which
  model task a row belongs to the same way it is replacing, so the same fix applies
  later. Tracked separately because these hubs submit samples, so a fair share of
  every run is spent here and it would otherwise look like the rewrite
  underdelivered.
- **`other`** — neither.

Every row also records `label`, `hubvalidations`, `hubutils`, `hubdata`, `sysname`,
`machine` and `r_version`. Numbers are only comparable on the same machine.

The code version is `branch@sha`, with `-dirty` added when there are uncommitted
changes **under `R/`** — only `R/`, because that is the code being measured, so
editing the benchmark itself does not mark a run dirty. A `-dirty` run cannot be
reproduced from the commit alone, so give it a name via
`HUBVALIDATIONS_BENCHMARK_LABEL`.

## Files

| file | |
|---|---|
| `run-benchmark.R` | the entry point |
| `make-hub.R` | builds the test hubs |
| `check-calls.R` | the list of checks and how each is called |
| `run-one-check.R` | runs a single check in its own process, for `peak` mode |
| `acefa-tasks.json` | ruarai's config, unchanged |
| `results.csv`, `peak-results.csv` | committed results |
| `prof-summary.md` | the short summary of where time and memory go |

Generated hubs, logs and profile files are not committed.

---

# Appendix

Detail that is only needed when changing the benchmark or interpreting an odd
result.

## Why this config is slow to validate

Every task ID value in it is optional, and `origin_date` lists all 365 days of the
year, because it records the last day of reliable data and that differs by location
and disease. Multiply the value lists together and one round has ~3.9 million
valid value combinations grid rows. Validation currently builds that whole grid and
matches the submission against it. The submission is 13 million rows but uses only
25 of the 10,950 date/location/disease combinations allowed — a small, uneven corner
of a very large space. Exploiting that gap is what the rewrite is for, which is why
sizes S to L grow the config and the submission together: a test hub without the gap
would make the new code look better than it is.

Their example submission file is not used as-is, because its round is not one the
config lists — the two attachments came from different points in time, and
validating one against the other stops at the round ID check before reaching
anything slow.

## How close the generated data is to theirs

- **25 units**, each a date, location and disease, spread unevenly as theirs are: 1
  or 2 dates per location, 1 to 3 diseases per date, dates spread with gaps across
  roughly the 11 days before the round. A neat set covering every combination would
  be the easy case.
- **130 rows per sample per unit**: two targets that forecast ahead across 64
  horizons, plus two that do not (peak size and peak timing).
- `hospital_incidence` and the 7 earliest horizons are allowed but never submitted,
  as in their file. Values that are allowed but not sent are what the "was
  everything required actually sent?" checks have to work out.
- Column types match their file. Sample ids start again at 1 in every unit.
- The values themselves are random numbers, as in the file they shared. Only the
  shape is realistic.

Size L is their config exactly, which `assert_faithful_to_acefa()` confirms on every
run: if a scaling rule or the config file changes, generation stops rather than
quietly measuring a different hub.

## An oddity in the sample ids

All four submitted targets use the same set of sample ids, so one sample is one
simulation across every target and horizon. That is what sharing ids is for, and it
is why the hub has one model task: an id cannot appear in more than one.

But the config does not say which task IDs a sample is shared across
(`compound_taskid_set`), and when that is missing the package assumes every task ID.
Because the ids start again at 1 in every unit, what the data implies is the
opposite extreme: that sample 1 is one continuous simulation spanning every
location, disease, target and horizon in the round. Almost certainly not intended.
It passes only because a submission may share samples more widely than the config
says.

Copied rather than corrected, since the hub's job is to be the case that was
reported. It does mean the sample checks run against the broadest possible sharing,
so a hub that spells the sharing out would take a different path through
`spl_hash_tbl()`.

## Constraints on splitting into model tasks

The `mt<N>` shapes share the locations out between N−1 model tasks, each covering
all diseases but one, with the last model task taking the remaining disease across
every location. Two consequences worth knowing:

- **No single column can tell the model tasks apart.** Disease cannot separate the
  location groups from each other, and location cannot separate any of them from the
  last model task, so both are needed. This is what makes the new code search for a
  combination of columns rather than getting away with one, and it is a shape real
  hubs have, where different places report on different diseases.
- **The split columns must hold one value throughout a unit.** Splitting by target
  looks reasonable in the config but is not: within a unit the same sample ids are
  used for every target, so it would put one sample id in two model tasks and
  `check_tbl_spl_mt_unique` rejects that. For the same reason each model task gets
  its own range of sample ids, the one place these shapes have to differ from
  ruarai's file.

N is limited by how many locations a size has (N ≤ locations + 1), and says so:
`mt10 needs between 3 and 7 modeling tasks for this size's 6 locations`.

Every size and shape passes validation cleanly (26 checks, no errors). A hub where a
check failed early would measure validation stopping rather than doing its work.

## What is not covered

No shape includes quantile output, because ruarai's hub submits only samples. So the
ascending-quantiles check is skipped, and model tasks that can only be told apart by
`output_type_id` — which #355 and #356 both flag as the hard case — are not
exercised here. That is a question of correctness rather than speed, so it belongs
in the old-versus-new comparison tests those issues describe.

The valid value grid is not measured on its own. It is not being made faster,
it is being made unnecessary, and each check's memory figure already includes
whatever table it builds. `grid_rows` is recorded as a column, worked out from the
config without building anything.
