# Validating Target Data Pull Requests on GitHub

``` r
library(hubValidations)
```

## Running validation checks on a Pull Request with `validate_target_pr()`

The
[`validate_target_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_pr.md)
function is designed to validate target data contributions through Pull
Requests on GitHub.

Target data files are individually validated using
[`validate_target_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_submission.md)
on each file, and the affected target type datasets as a whole are
validated via
[`validate_target_dataset()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_dataset.md).
Hub config files are also validated as part of the checks. Any other
files included in the PR are ignored but flagged in a message.

(*See the end of this article for details of the standard checks
performed on each file. For more information on deploying optional or
custom functions please check the article on [including custom
functions](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.md)
([`vignette("articles/deploying-custom-functions")`](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.md))*).

### Deploying `validate_target_pr()` through a GitHub Action workflow

The most common way to deploy
[`validate_target_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_pr.md)
is through a GitHub Action that triggers when a pull request containing
changes to target data files is opened. The hubverse maintains the
[**`validate-target-data.yaml`**](https://github.com/hubverse-org/hubverse-actions/tree/main/validate-target-data)
GitHub Action workflow template for deploying
[`validate_target_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_pr.md).

The latest release of the workflow can be added to a hub’s GitHub Action
workflows using the `hubCI` package:

``` r
hubCI::use_hub_github_action("validate-target-data")
```

The pertinent section of the workflow is:

``` yaml
      - name: Run validations
        env:
          PR_NUMBER: ${{ github.event.number }}
        run: |
          library("hubValidations")
          v <- hubValidations::validate_target_pr(
              gh_repo = Sys.getenv("GITHUB_REPOSITORY"),
              pr_number = Sys.getenv("PR_NUMBER")
          )
          hubValidations::check_for_errors(v, verbose = TRUE)
        shell: Rscript {0}
```

where
[`validate_target_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_pr.md)
is called on the contents of the current Pull Request, the results (an
S3 `<target_validations>` class object) are stored in `v` and then
[`check_for_errors()`](https://hubverse-org.github.io/hubValidations/reference/check_for_errors.md)
is used to signal whether overall validations have passed or failed and
summarise any validation failures.

### Example: Validating a Pull Request

Here’s an example of validating a PR that adds a valid oracle-output
file:

``` r
tmp_dir <- withr::local_tempdir()
ci_target_hub_path <- fs::path(tmp_dir, "target")
gert::git_clone(
  url = "https://github.com/hubverse-org/ci-testhub-target.git",
  path = ci_target_hub_path
)
gert::git_branch_checkout("add-file-oracle-output", repo = ci_target_hub_path)
#> Creating local branch add-file-oracle-output from origin/add-file-oracle-output
#> <git repository>: /tmp/RtmpjzniJf/file24666eda4e30/target[@add-file-oracle-output]

v <- validate_target_pr(
  hub_path = ci_target_hub_path,
  gh_repo = "hubverse-org/ci-testhub-target",
  pr_number = 1
)
v
#> 
#> ── target ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> 
#> ── oracle-output.csv ────
#> 
#> 
#> 
#> ✔ [target_dataset_exists]: oracle-output dataset detected.
#> ✔ [target_dataset_unique]: target-data directory contains single unique
#>   oracle-output dataset.
#> ✔ [target_dataset_file_ext_unique]: oracle-output dataset files share single
#>   unique file format.
#> ✔ [target_dataset_rows_unique]: oracle-output target dataset rows are unique.
#> ✔ [target_file_exists]: File exists at path target-data/oracle-output.csv.
#> ℹ [target_partition_file_name]: Target file path not hive-partitioned. Check
#>   skipped.
#> ✔ [target_file_ext]: Target data file extension is valid.
#> ✔ [target_file_read]: target file could be read successfully.
#> ✔ [target_tbl_colnames]: Column names are consistent with expected column names
#>   for oracle-output target type data.
#> ✔ [target_tbl_coltypes]: Column data types match oracle-output target schema.
#> ℹ [target_tbl_ts_targets]: Check not applicable to oracle-output target data.
#>   Skipped.
#> ✔ [target_tbl_rows_unique]: oracle-output target data rows are unique.
#> ✔ [target_tbl_values]: `target_tbl_chr` contains valid values/value
#>   combinations.
#> ✔ [target_tbl_output_type_ids]: oracle-output `target_tbl` contains valid
#>   complete output_type_id values.
#> ✔ [target_tbl_oracle_value]: oracle-output `target_tbl` contains valid oracle
#>   values.
```

``` r
check_for_errors(v)
#> ✔ All validation checks have been successful.
```

### Configuring target data validation

For the most robust validation, hubs should include a `target-data.json`
configuration file in their `hub-config` directory. When present, this
config provides deterministic validation by explicitly defining the date
column, column names and types, and observable unit structure.

For hubs without a `target-data.json` config, the **`date_col`**
parameter can be used to specify the name of the column containing
observation dates (e.g., `"target_end_date"`). This is important for
correct schema creation, particularly when the date column is also used
for partitioning. When `target-data.json` exists, any user-provided
`date_col` is ignored in favour of the config value.

### Relaxed date validation for time-series data

By default, date values in time-series target data are validated
strictly against the dates defined in `tasks.json`. However, target data
often contains historical observations with dates beyond the hub’s
configured modeling rounds.

Setting **`allow_extra_dates = TRUE`** relaxes date validation for
time-series data, allowing historical observations while still strictly
validating other task ID values. Oracle-output data always uses strict
date validation regardless of this setting.

``` yaml
      - name: Run validations
        env:
          PR_NUMBER: ${{ github.event.number }}
        run: |
          library("hubValidations")
          v <- hubValidations::validate_target_pr(
              gh_repo = Sys.getenv("GITHUB_REPOSITORY"),
              pr_number = Sys.getenv("PR_NUMBER"),
              allow_extra_dates = TRUE
          )
          hubValidations::check_for_errors(v, verbose = TRUE)
        shell: Rscript {0}
```

### Configuring file modification/deletion checks

By default,
[`validate_target_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_pr.md)
does **not** perform modification or deletion checks on target data
files. This reflects the expectation that target data may be updated or
corrected over time.

This behaviour can be modified through the `file_modification_check`
argument, which controls whether modification/deletion checks are
performed and what is returned if modifications/deletions are detected:

- **`"none"`** (default): No modification/deletion checks performed.
- **`"message"`**: Appends a `<message/check_info>` condition class
  object for each applicable modified/deleted file. Will not result in
  validation workflow failure.
- **`"failure"`**: Appends a `<error/check_failure>` condition class
  object for each applicable modified/deleted file. Will result in
  validation workflow failure.
- **`"error"`**: Appends a `<error/check_error>` condition class object
  for each applicable modified/deleted file. Will result in validation
  workflow failure.

Here’s an example of a PR that deletes some target data files. With
`file_modification_check = "failure"`, this produces a validation
failure:

``` r
gert::git_branch_checkout("delete-target-dir-files", repo = ci_target_hub_path)
#> Creating local branch delete-target-dir-files from origin/delete-target-dir-files
#> <git repository>: /tmp/RtmpjzniJf/file24666eda4e30/target[@delete-target-dir-files]

v_mod <- validate_target_pr(
  hub_path = ci_target_hub_path,
  gh_repo = "hubverse-org/ci-testhub-target",
  pr_number = 5,
  file_modification_check = "failure"
)
v_mod
#> 
#> ── target ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> 
#> ── oracle-output/output_type=sample/part-0.parquet ────
#> 
#> 
#> 
#> ✖ [oracle_output_mod]: Previously submitted oracle output files must not be
#>   removed.  target-data/oracle-output/output_type=sample/part-0.parquet
#>   removed.
#> 
#> 
#> ── oracle-output ────
#> 
#> 
#> 
#> ✔ [target_dataset_exists]: oracle-output dataset detected.
#> ✔ [target_dataset_unique]: target-data directory contains single unique
#>   oracle-output dataset.
#> ✔ [target_dataset_file_ext_unique]: oracle-output dataset files share single
#>   unique file format.
#> ✔ [target_dataset_rows_unique]: oracle-output target dataset rows are unique.

check_for_errors(v_mod)
#> 
#> ── part-0.parquet ────
#> 
#> ✖ [oracle_output_mod]: Previously submitted oracle output files must not be
#>   removed.  target-data/oracle-output/output_type=sample/part-0.parquet
#>   removed.
#> Error in `check_for_errors()`:
#> ! 
#> The validation checks produced some failures/errors reported above.
```

### Allowing deletion of entire target type datasets

By default, deletion of an entire target type dataset (i.e., all files
of a target type) in a PR is not allowed. This can be changed by setting
`allow_target_type_deletion` to `TRUE`.

Here’s an example of a PR that removes the time-series dataset and adds
oracle-output data. With the default settings, this produces an error:

``` r
gert::git_branch_checkout("remove-ts-add-oo", repo = ci_target_hub_path)
#> Creating local branch remove-ts-add-oo from origin/remove-ts-add-oo
#> <git repository>: /tmp/RtmpjzniJf/file24666eda4e30/target[@remove-ts-add-oo]

v_del <- validate_target_pr(
  hub_path = ci_target_hub_path,
  gh_repo = "hubverse-org/ci-testhub-target",
  pr_number = 4
)
v_del
#> 
#> ── target ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> 
#> ── time-series ────
#> 
#> 
#> 
#> ⓧ [target_dataset_exists]: time-series dataset not detected.
#> 
#> 
#> ── oracle-output.csv ────
#> 
#> 
#> 
#> ✔ [target_dataset_exists_1]: oracle-output dataset detected.
#> ✔ [target_dataset_unique]: target-data directory contains single unique
#>   oracle-output dataset.
#> ✔ [target_dataset_file_ext_unique]: oracle-output dataset files share single
#>   unique file format.
#> ✔ [target_dataset_rows_unique]: oracle-output target dataset rows are unique.
#> ✔ [target_file_exists]: File exists at path target-data/oracle-output.csv.
#> ℹ [target_partition_file_name]: Target file path not hive-partitioned. Check
#>   skipped.
#> ✔ [target_file_ext]: Target data file extension is valid.
#> ✔ [target_file_read]: target file could be read successfully.
#> ✔ [target_tbl_colnames]: Column names are consistent with expected column names
#>   for oracle-output target type data.
#> ✔ [target_tbl_coltypes]: Column data types match oracle-output target schema.
#> ℹ [target_tbl_ts_targets]: Check not applicable to oracle-output target data.
#>   Skipped.
#> ✔ [target_tbl_rows_unique]: oracle-output target data rows are unique.
#> ✔ [target_tbl_values]: `target_tbl_chr` contains valid values/value
#>   combinations.
#> ✔ [target_tbl_output_type_ids]: oracle-output `target_tbl` contains valid
#>   complete output_type_id values.
#> ✔ [target_tbl_oracle_value]: oracle-output `target_tbl` contains valid oracle
#>   values.

check_for_errors(v_del)
#> 
#> ── time-series ────
#> 
#> ⓧ [target_dataset_exists]: time-series dataset not detected.
#> Error in `check_for_errors()`:
#> ! 
#> The validation checks produced some failures/errors reported above.
```

Setting `allow_target_type_deletion = TRUE` allows the deletion to pass:

``` r
v_del_allowed <- validate_target_pr(
  hub_path = ci_target_hub_path,
  gh_repo = "hubverse-org/ci-testhub-target",
  pr_number = 4,
  allow_target_type_deletion = TRUE
)
check_for_errors(v_del_allowed)
#> ✔ All validation checks have been successful.
```

## Checking for validation failures with `check_for_errors()`

[`check_for_errors()`](https://hubverse-org.github.io/hubValidations/reference/check_for_errors.md)
is used to inspect a `target_validations` class object, determine
whether overall validations have passed or failed and summarise any
detected errors/failures.

### Validation failure

If any elements of the `target_validations` object contain
`<error/check_error>`, `<warning/check_warning>` or
`<error/check_exec_error>` condition class objects, the function throws
an error and prints the messages from the failing checks.

### Validation success

If all validation checks pass,
[`check_for_errors()`](https://hubverse-org.github.io/hubValidations/reference/check_for_errors.md)
returns `TRUE` silently and prints:

    All validation checks have been successful.

### Verbose output

If printing the results of all checks is preferred instead of just
summarising the results of checks that failed, argument `verbose` can be
set to `TRUE`.

## `validate_target_pr` check details

For details on the structure of `<hub_validations>` objects, including
on how to access more information about specific checks, see
[`vignette("articles/hub-validations-class")`](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.md).

### Checks on target datasets

| Name                           | Check                                                                | Early return | Fail output   | Extra info |
|:-------------------------------|:---------------------------------------------------------------------|:-------------|:--------------|:-----------|
| valid_config                   | Hub config valid                                                     | TRUE         | check_error   |            |
| target_dataset_exists          | Target dataset can be successfully detected for a given target type. | TRUE         | check_error   |            |
| target_dataset_unique          | A single unique target dataset exists for a given target type.       | TRUE         | check_error   |            |
| target_dataset_file_ext_unique | All files of a given target type share a single unique file format.  | TRUE         | check_error   |            |
| target_dataset_rows_unique     | Target dataset rows are all unique.                                  | FALSE        | check_failure |            |

Details of dataset-level checks performed by
[`validate_target_pr()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_pr.md).

### Checks on individual target files

| Name                       | Check                                                                                                                                             | Early return | Fail output   | Extra info |
|:---------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-----------|
| target_file_exists         | File exists at `file_path` provided.                                                                                                              | TRUE         | check_error   |            |
| target_partition_file_name | Hive-style partition file path segments are valid and can be parsed successfully. Skipped if target dataset not hive-partitioned.                 | TRUE         | check_error   |            |
| target_file_ext            | Target data file extension is valid.                                                                                                              | TRUE         | check_error   |            |
| target_file_read           | Target data file can be read successfully.                                                                                                        | TRUE         | check_error   |            |
| target_tbl_colnames        | Target data file has the correct column names according to target type.                                                                           | TRUE         | check_error   |            |
| target_tbl_coltypes        | Target data file has the correct column types according to target type.                                                                           | TRUE         | check_error   |            |
| target_tbl_ts_targets      | Targets in a time-series target data file are valid. Only performed on `time-series` data files.                                                  | TRUE         | check_error   |            |
| target_tbl_rows_unique     | Target data file rows are all unique.                                                                                                             | FALSE        | check_failure |            |
| target_tbl_values          | Task ID columns in a target data file have valid task ID values.                                                                                  | TRUE         | check_error   |            |
| target_tbl_output_type_ids | Output type ID values in a target data file are valid and complete. Only performed when the target data file contains an `output_type_id` column. | TRUE         | check_error   |            |
| target_tbl_oracle_value    | Oracle values in a target data file are valid. Only performed on `oracle output` data files.                                                      | FALSE        | check_failure |            |

Details of file-level checks performed by
[`validate_target_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_submission.md).

#### Custom checks

The standard checks discussed here are the checks deployed by default by
the `validate_target_pr` function. For more information on deploying
optional or custom functions please check the article on [deploying
custom
functions](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.md)
([`vignette("articles/deploying-custom-functions")`](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.md)).
