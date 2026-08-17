# Validation cost

What validation costs, and what each of #355–#357 has taken off it.
`results.csv` and `peak-results.csv` hold every run; this file is the short version.
Only add to it when a run moves a cost, removes one, or turns up something new.

Machine: Darwin arm64, R 4.5.2.

## Where things stand

Every check at G3, the hardest case measured: 65,000 submitted rows against a config
allowing 77.7 million valid value combinations. Peak memory and elapsed time.

| check | baseline | now | changed by |
|---|---:|---:|---|
| `check_tbl_values_required` | 13,280 MB / 3,497 s | 13,570 MB / 3,384 s | #357, not landed |
| `check_tbl_spl_compound_taskid_set` | 13,883 MB / 58 s | 13,330 MB / 57 s | samples, not scoped |
| `check_tbl_spl_compound_tid` | 13,717 MB / 77 s | 13,773 MB / 78 s | samples, not scoped |
| `check_tbl_spl_non_compound_tid` | 14,237 MB / 78 s | 13,374 MB / 77 s | samples, not scoped |
| `check_tbl_spl_n` | 13,787 MB / 76 s | 13,542 MB / 77 s | samples, not scoped |
| `check_tbl_spl_mt_unique` | 13,396 MB / 28 s | 12,913 MB / 29 s | samples, not scoped |
| `check_tbl_values` | 11,474 MB / 76 s | 11,178 MB / 76 s | #356, not landed |
| `check_tbl_value_col` | 13,424 MB / 60 s | **222 MB / 0.08 s** | #355 |
| `match_tbl_to_model_task` | 11,452 MB / 60 s | **211 MB / 0.05 s** | #355 |
| `check_tbl_rows_unique` | 293 MB / 0.2 s | 282 MB / 0.2 s | never built the grid |
| `check_tbl_value_col_ascending` | 193 MB / 0.1 s | 200 MB / 0.03 s | never built the grid |

Only the two marked #355 have moved. The rest differ by up to 1.3 GB either way, which
is the run-to-run variation the memory figures carry at this size and not a change in
what the code does.

From #355 on, `check_tbl_value_col` is measured on the character submission, following
`validate_model_data()`. Its baseline figure is a typed measurement.

## Headlines

1. **One file at the size that was reported takes ~29 minutes, and needs up to ~15 GiB
   of memory** (size L: 13M submitted rows, 3.9M valid value combinations grid rows,
   one model task). Budget on 15 GiB: that is the highest the whole process has been
   observed to reach.
2. **`check_tbl_values_required` accounts for 91% of that time**, and matching rows
   against the valid value grid accounts for 89% of it. Everything else put
   together is under 10%.
3. **Cost grows with the size of the valid value grid, not with how much data was
   submitted.** With the submission fixed at 65k rows, a 6.7x larger grid takes 6.7-8x
   longer. Memory rises too but flattens off, 2.9-3.8x for that same 6.7x, because it
   runs into what the machine will give it: every check converges on 11-14 GB. So time
   is the cleaner measure of the effect, and the memory ceiling is itself a finding:
   65k rows against a 78M-row grid needs ~14 GB, which will not fit a 16 GB runner
   alongside anything else.
4. **Working out which model task each row belongs to already costs more when there
   are more of them**: ~3.3x slower going from 1 to 7. So the new approach checking
   rows against each model task in turn was never automatically worse than what we
   had, and #355 confirms it: the same run costs a little less at every model task
   count. Keeping a separate marker per row for every model task would have been worse.
5. **`check_tbl_values_required` gets ~2.6x *faster* with 7 model tasks** than with
   1, on identical data. Its cost comes from working through the combinations of
   optional values within each model task, so splitting the values between several
   makes each one's job much smaller. Their single model task holding every optional
   value is therefore close to the worst case, and the size L numbers are an upper
   bound rather than a typical one.
6. **~20% of a mid-size run is spent in the sample checks**, falling to ~6% at size L.
   #355 leaves those for later, but they work out which model task a row belongs to
   the same way, so the same new helper would fix them too.

## A whole file, by size

`validate_submission()` on one submission file, from `results.csv`. "Valid value grid
rows" is how many rows that grid has for the round.

| size | submitted rows | valid value grid rows | time | R heap peak | errors |
|---|---:|---:|---:|---:|---:|
| S | 18,000 | 25,200 | 2.5 s | 188 MB | 0 |
| M | 460,000 | 237,510 | 25.6 s | 735 MB | 0 |
| L | 13,000,000 | 3,887,250 | 1,769 s | 17,751 MB | 0 |

**Two different memory numbers, don't compare them.** The `R heap peak` column in the
table above is R's own high-water counter (`gc()` max-used), which read 17.3 GiB at
size L. It is not the number that decides whether a run fits on a machine. That one is
the whole process's resident set, measured with `/usr/bin/time -l`, which read 10.5 GiB
for the same run. R's counter can exceed the resident set because it adds up everything
R ever had allocated at once, while the operating system frees and reuses pages as it
goes, so 17.3 > 10.5 is not a contradiction. **When working out how much memory a
machine needs, use the resident set figure, not this column.**

**Expect noise.** Across four runs, size L took 1,694-1,813 s, so treat time differences
under about 5% as nothing. The process peak varied more, 10.5 to 15.4 GiB, since it
depends on when R happens to tidy up; only believe a memory change larger than about
20%. It only ever uses one core.

Where the time goes at size L, as a percentage of the total:

| | % |
|---|---:|
| `check_tbl_values_required` | 90.7 |
| └─ `join_mutate` / `join_rows` | 90.0 |
| `spl_hash_tbl` (three `spl_` checks) | 3.2 |
| `check_tbl_rows_unique` | 2.8 |

Matching rows against the valid value grid accounts for 88.9% of the time on
its own. At size M that same check is 64% rather than 91%, and the sample checks are
~22% rather than ~6%. So the bigger the hub, the stronger the case for #357.

## Cost as the config grows

The submission is held at 65,000 rows and only the config grows, so anything that moves
here is down to the valid value grid. Each cell gives the peak memory and the elapsed
time for one check at one size.

| check | G1 (11.7M) | G2 (38.9M) | G3 (77.7M) |
|---|---:|---:|---:|
| `check_tbl_values_required` | 3,885 MB / 436 s | 10,397 MB / 1,482 s | 13,280 MB / 3,497 s |
| `check_tbl_spl_non_compound_tid` | 7,336 MB / 20 s | 10,921 MB / 36 s | 14,237 MB / 78 s |
| `check_tbl_spl_compound_taskid_set` | 3,409 MB / 8 s | 9,514 MB / 28 s | 13,883 MB / 58 s |
| `check_tbl_spl_n` | 7,338 MB / 20 s | 10,657 MB / 37 s | 13,787 MB / 76 s |
| `check_tbl_spl_compound_tid` | 7,097 MB / 20 s | 11,085 MB / 36 s | 13,717 MB / 77 s |
| `check_tbl_value_col` | 3,579 MB / 9 s | 9,925 MB / 29 s | 13,424 MB / 60 s |
| `check_tbl_spl_mt_unique` | 2,545 MB / 4 s | 8,065 MB / 14 s | 13,396 MB / 28 s |
| `check_tbl_values` | 4,021 MB / 10 s | 9,607 MB / 34 s | 11,474 MB / 76 s |
| `match_tbl_to_model_task` | 3,568 MB / 9 s | 9,783 MB / 28 s | 11,452 MB / 60 s |
| `check_tbl_rows_unique` | 284 MB / 0.2 s | 282 MB / 0.2 s | 293 MB / 0.2 s |
| `check_tbl_value_col_ascending` | 195 MB / 0.1 s | 195 MB / 0.1 s | 193 MB / 0.1 s |

The grid grows 6.67x from G1 to G3. **Time grows 6.7-8x with it**, i.e. roughly in
proportion. **Memory grows only 2.9-3.8x**, and every affected check lands between 11
and 14 GB at G3 — they are converging on what this machine will hand out rather than on
what the work needs, so read the memory column as a lower bound on what the work would
really use, not a measurement of it.

The last two rows are the control. Neither check has to work out which model task a row
belongs to, so neither is affected by the size of the grid: both sit at ~200-290 MB and
under a second across a grid that grew nearly sevenfold.

What to expect of the other rows once #355-#357 land: they should **drop**, and the gaps
between the G columns should **narrow**, though not all the way down to the controls. A
config
permitting more values still means more values to test each column against, so G3 should
still cost more than G1, just far less than it does today.

A whole `peak` run takes ~9 min at G1, ~29 min at G2 and ~68 min at G3, almost all of it
`check_tbl_values_required`.

## Memory and time as model tasks are added

Both the submission and the valid value grid are held still here (the `mt<N>` split
shares one set of values out between the model tasks), so only the number of model
tasks changes. Size M.

| check | 1 model task | 3 | 7 |
|---|---:|---:|---:|
| `check_tbl_values_required` | 1,149 MB / 15.8 s | 686 / 7.6 | 826 / 6.2 |
| `check_tbl_spl_non_compound_tid` | 652 MB / 2.0 s | 609 / 4.2 | 663 / 6.6 |
| `check_tbl_spl_n` | 599 MB / 2.0 s | 656 / 4.3 | 691 / 6.6 |
| `check_tbl_spl_compound_tid` | 570 MB / 2.0 s | 598 / 4.2 | 737 / 6.5 |
| `match_tbl_to_model_task` | 432 MB / 0.5 s | 499 / 0.7 | 580 / 1.1 |
| `check_tbl_value_col` | 434 MB / 0.7 s | 511 / 0.9 | 622 / 1.2 |
| `check_tbl_values` | 479 MB / 0.8 s | 470 / 0.8 | 539 / 0.9 |
| `check_tbl_rows_unique` | 753 MB / 1.4 s | 747 / 1.5 | 753 / 1.5 |

Setup costs to subtract: ~270 MB when the submission is read as character, ~246 MB
when it is read with real column types.

Time is the clearer signal here, not memory. The sample checks take 3.3x longer with 7
model tasks than with 1, on identical data, while their memory moves by little more
than the run-to-run noise.

## What #355 changed

Working out which model task each row belongs to no longer builds the valid value grid.
Each of the row's values is tested against the set of values the model task allows for
that column, which costs one pass over the submission per column and does not depend on
how many combinations the config allows.

| check | G1 (11.7M) | G2 (38.9M) | G3 (77.7M) |
|---|---:|---:|---:|
| `match_tbl_to_model_task` | 3,568 MB / 8.6 s → 221 MB / 0.05 s | 9,783 MB / 27.7 s → 210 MB / 0.04 s | 11,452 MB / 60.1 s → 211 MB / 0.05 s |
| `check_tbl_value_col` | 3,579 MB / 8.7 s → 228 MB / 0.08 s | 9,925 MB / 28.7 s → 229 MB / 0.08 s | 13,424 MB / 59.6 s → 222 MB / 0.08 s |

Three things worth reading off it.

**The gaps between G1, G2 and G3 closed, rather than narrowing.** The expectation was
that they would narrow but not close, because a config permitting more values still
means more values to test each column against. That is true and it turns out not to
matter. The config is read once into a lookup per column, and the per-row cost does not
touch it again, so what grows is the lookup rather than the work. G1 to G3 multiplies
the combinations by 6.7 while the longest single value list only goes from 365 to 730.

**Both now cost almost nothing beyond the setup.** Loading the package and reading
the submission takes ~190 MB before any check runs, so these two add only a few tens
of MB on top of that. For comparison, `check_tbl_rows_unique`, which never touched the
grid, reads 282 MB at G3.

**More model tasks are no longer more expensive.** At size M, assigning 460,000 rows
took 0.54 s with one model task and 1.07 s with seven; it now takes 0.33 s and 0.71 s.
`check_tbl_value_col` goes the same way, 0.73 s to 0.48 s with one and 1.20 s to 0.80 s
with seven. Testing each row against every model task in turn was the part of this
approach that could have cost more than it saved, and it does not.

Nothing else moved, which is the point: `check_tbl_values` and
`check_tbl_values_required` still build the grid, and the sample checks still work out
model tasks their own way. A whole file at size L takes 1,771 s against a baseline of
1,769 s, because `check_tbl_values_required` is 91% of that run and #357 is what
addresses it.

`check_tbl_value_col` now expects and is given the all-character submission. Given
the typed one instead it still works, but `match()` then has to convert its `Date`
column once for every model task: 3.77 s against 0.80 s, at size M with seven
model tasks.
