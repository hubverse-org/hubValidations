# Baseline

What validation costs today: the numbers #355–#357 have to beat. `results.csv` and
`peak-results.csv` hold every run; this file is the short version. Only add to it
when a run moves a cost, removes one, or turns up something new.

Machine: Darwin arm64, R 4.5.2.

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
   rows against each model task in turn is not automatically worse than what we have.
   Keeping a separate marker per row for every model task would be.
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

**Two different memory numbers, don't compare them.** The table's "R heap peak" is R's
own high-water counter (`gc()` max-used), which read 17.3 GiB at size L. The number that
decides whether a run fits on a machine is the whole process's resident set, from
`/usr/bin/time -l`, which read 10.5 GiB for this run. R's counter can exceed the
resident set because it tracks everything R ever had allocated at once, while pages get
freed and reused, so 17.3 > 10.5 is not a contradiction. Budget on the process figure.

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
here is down to the valid value grid. Peak memory and elapsed time per check.

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
what the work needs, so read the memory column as a floor on the real appetite, not a
measurement of it.

The last two rows are the control. Neither check has to work out which model task a row
belongs to, so neither is affected by the size of the grid: both sit at ~200-290 MB and
under a second across a grid that grew nearly sevenfold. That is what every other row
should look like once #355-#357 land, and the ratio between the G columns is what to
watch.

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

Setup costs to subtract: ~270 MB when the submission is read as text, ~246 MB when it
is read with proper column types.

Time is the clearer signal here, not memory. The sample checks take 3.3x longer with 7
model tasks than with 1, on identical data, while their memory moves by little more
than the run-to-run noise.
