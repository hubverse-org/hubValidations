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

**Three things drive what validation costs**, and the test hubs vary them
independently:

1. the size of the submitted data
2. the size of the config's valid value combinations grid
3. the number of model tasks

The first two are set by **size**, the third by **shape**. Nothing else about a config
changes any of them, which is why one config is enough. The tables below count rows,
since the column count is the same across all of these hubs.

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

All N model tasks sit in the same round, and one submission file covers all of them.
Splitting shares the same set of values out between them, so the number of valid value
grid rows stays the same and only the number of model tasks changes.

This matters because validation builds the grid as one sub-grid per model task and maps
over them, so more model tasks means more passes through the same build-and-join work.
It maps over output type too, which is why it helps that these hubs submit a single
output type: every pass is then the same shape, so changing the model task count changes
how many passes there are and nothing else.

## The two questions it answers

**Is validation faster?** Run `submission` mode at size L and compare
`elapsed_s` against the baseline in `prof-summary.md`.

**How much does the size of the valid value grid still cost?** This is what the G sizes
are for. All three submit ~65,000 rows, and the only difference between them is that the
config permits 11.7M, 38.9M and 77.7M valid value grid rows. Run `peak` mode across them
and read one check's `elapsed_s` and `peak_rss_mb` at each.

Today the cost climbs steeply with the grid, because validation builds it and matches
the submission against it. `check_tbl_values_required` reads 3,885 MB / 436 s, then
10,397 MB / 1,482 s, then 13,280 MB / 3,497 s.

The rewrite removes the need to build the grid at all, so these are the numbers to watch
as it lands. Two things should happen to them:

- **they should drop**, and substantially — that is the point of the work, not a side
  effect of it;
- **the gaps between G1, G2 and G3 should narrow.** They should not close completely: a
  config permitting more values still means more values to test each column against, so
  G3 should still cost more than G1 — just far less than it does today.

For a check that never touches the grid, `check_tbl_rows_unique` shows what the floor
looks like: ~290 MB and under a second at all three sizes.

Read `elapsed_s` alongside `peak_rss_mb`, and prefer it. Across those three the grid
grows 6.7x and the times grow with it, but the memory figures flatten as they approach
what the machine will give. Everything affected lands between 11 and 14 GB at G3, so
memory understates the effect at the top end. Peak memory also moves by around 20%
between runs, so only believe a memory change larger than that.

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
| `result_class` | what the check returned, so a failure is not read as a fast pass |
| `status` | `ok`, `error`, `oom` or `timeout` |

Some rows in `peak-results.csv` are setup rather than checks.
`baseline_load_only_*` loads the package and reads the submission but runs no
check, so subtract it from a check that read the submission the same way.
`prepare_compound_taskid_set` works out a value the sample checks need, once, so
none of them is charged for it.

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

## What the sample indices say

Sample index `1` appears on 3,250 rows of the submission, covering 6 origin dates,
4 targets, 64 horizons, 9 locations and 3 diseases. Only `round_id` is constant, and
the same holds for each of the 4,000 indices.

Since indices are meant to be unique across a whole model output file, that states
that all of those rows are one jointly sampled set: one compound modeling task
spanning everything except the round. The config says the opposite: it declares no
`compound_taskid_set`, and when that is absent every task ID is treated as compound,
i.e. no joint sampling at all. The submission passes because samples are allowed to be
coarser than the config declares.

Which of the two is intended is a question for the hub's authors, asked on #295. It
is reproduced here rather than resolved, because the test hub's job is to be the case
that was reported. Two consequences for the benchmark: the sample checks run against
the broadest possible joint sampling, so a hub declaring a narrower
`compound_taskid_set` would take a different path through `spl_hash_tbl()`; and the
single model task is required either way, since an index cannot appear in more than
one.

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

Every shape submits a single output type, samples. That is deliberate: it keeps each pass
through validation the same shape, so the model task count can be varied on its own.

The consequence is that `check_tbl_value_col_ascending`, which only applies to quantile
and cdf output, doesn't run. Its expensive half is covered regardless, since it works out
which model task a row belongs to by calling `match_tbl_to_model_task()`, which is
measured separately. Model tasks that can only be told apart by `output_type_id` aren't
exercised either — that's a correctness question, and the test suite's job.

The valid value grid is not measured on its own. It is not being made faster,
it is being made unnecessary, and each check's memory figure already includes
whatever table it builds. `grid_rows` is recorded as a column, worked out from the
config without building anything.
