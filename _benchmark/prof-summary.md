# Baseline

What validation costs today: the numbers #355–#357 have to beat. `results.csv` and
`peak-results.csv` hold every run; this file is the short version. Only add to it
when a run moves a cost, removes one, or turns up something new.

Machine: Darwin arm64, R 4.5.2.

## Headlines

1. **One file at the size that was reported takes ~29 minutes and ~11 GiB** (size L:
   13M submitted rows, 3.9M valid value combinations grid rows, one model task).
2. **`check_tbl_values_required` accounts for 91% of that time**, and matching rows
   against the valid value grid accounts for 89% of it. Everything else put
   together is under 10%.
3. **Memory grows with the size of the valid value grid, not with how much data was
   submitted.** Hold the submission at 65k rows and triple the grid, and memory
   roughly triples with it: validating 65k rows costs about 10 GB when the grid has
   39M rows.
4. **Working out which model task each row belongs to already costs more when there
   are more of them**: ~3.3x slower going from 1 to 7. So the new approach checking
   rows against each model task in turn is not automatically worse than what we have.
   Keeping a separate marker per row for every model task would be.
5. **`check_tbl_values_required` gets ~2.7x *faster* with 7 model tasks** than with
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

| size | submitted rows | valid value grid rows | time | most memory R held | errors |
|---|---:|---:|---:|---:|---:|
| S | 18,000 | 25,200 | 2.5 s | 188 MB | 0 |
| M | 460,000 | 237,510 | 25.6 s | 735 MB | 0 |
| L | 13,000,000 | 3,887,250 | 1,769 s | 17,751 MB | 0 |

At size L the whole process peaked at 15.4 GiB, and it only ever uses one core. Across
three runs L took between 1,694 and 1,813 s, so treat differences under about 5% as
noise. The memory peak varied more (10.7 to 15.4 GiB), because it depends on when R
happens to tidy up after itself.

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

## Memory as the config grows

The submission is held at 65,000 rows and only the config grows, so anything that
moves here is down to the valid value grid. Figures are the most memory each
check needed at once.

| check | G1 (11.7M grid rows) | G2 (38.9M grid rows) | ratio |
|---|---:|---:|---:|
| `check_tbl_spl_compound_tid` | 7,097 MB | 11,085 MB | 1.56x |
| `check_tbl_spl_non_compound_tid` | 7,336 MB | 10,921 MB | 1.49x |
| `check_tbl_spl_n` | 7,338 MB | 10,657 MB | 1.45x |
| `check_tbl_values_required` | 3,885 MB | 10,397 MB | 2.68x |
| `check_tbl_value_col` | 3,579 MB | 9,925 MB | 2.77x |
| `match_tbl_to_model_task` | 3,568 MB | 9,783 MB | 2.74x |
| `check_tbl_values` | 4,021 MB | 9,607 MB | 2.39x |
| `check_tbl_spl_mt_unique` | 2,545 MB | 8,065 MB | 3.17x |
| `check_tbl_rows_unique` | 284 MB | 282 MB | **0.99x** |
| `check_tbl_value_col_ascending` | 195 MB | 195 MB | **1.00x** |

The valid value grid grows 3.33x between these two sizes, and memory grows 1.5-3.2x
with it. So memory currently tracks the config, not the submission. The
ratios are not precise — peak memory moves ~20% between runs — so read them as
"clearly rising" rather than as exact multiples.

The last two rows are the control. Neither check has to work out which model task a
row belongs to, so neither is affected by the size of the grid, and both read ~1.00x
on the same data that puts every other row above 1.4x. The
ratio column is what to watch as #355-#357 land: every row should end up near
1.00x.

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
