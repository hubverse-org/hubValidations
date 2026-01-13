# Validate Target Data Pull Request

Validates target data files in a Pull Request.

## Usage

``` r
validate_target_pr(
  hub_path = ".",
  gh_repo,
  pr_number,
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date"),
  date_col = NULL,
  allow_extra_dates = FALSE,
  na = c("NA", ""),
  round_id = "default",
  validations_cfg_path = NULL,
  file_modification_check = c("none", "message", "failure", "error"),
  allow_target_type_deletion = FALSE
)
```

## Arguments

- hub_path:

  Either a character string path to a local Modeling Hub directory or an
  object of class `<SubTreeFileSystem>` created using functions
  [`s3_bucket()`](https://arrow.apache.org/docs/r/reference/s3_bucket.html)
  or
  [`gs_bucket()`](https://arrow.apache.org/docs/r/reference/gs_bucket.html)
  by providing a string S3 or GCS bucket name or path to a Modeling Hub
  directory stored in the cloud. For more details consult the [Using
  cloud storage (S3,
  GCS)](https://arrow.apache.org/docs/r/articles/fs.html) in the `arrow`
  package. The hub must be fully configured with valid `admin.json` and
  `tasks.json` files within the `hub-config` directory.

- gh_repo:

  GitHub repository address in the format `username/repo`

- pr_number:

  Number of the pull request to validate

- output_type_id_datatype:

  character string. One of `"from_config"`, `"auto"`, `"character"`,
  `"double"`, `"integer"`, `"logical"`, `"Date"`. Defaults to
  `"from_config"` which uses the setting in the
  `output_type_id_datatype` property in the `tasks.json` config file if
  available. If the property is not set in the config, the argument
  falls back to `"auto"` which determines the `output_type_id` data type
  automatically from the `tasks.json` config file as the simplest data
  type required to represent all output type ID values across all output
  types in the hub. When only point estimate output types (where
  `output_type_id`s are `NA`,) are being collected by a hub, the
  `output_type_id` column is assigned a `character` data type when
  auto-determined. Other data type values can be used to override
  automatic determination. Note that attempting to coerce
  `output_type_id` to a data type that is not valid for the data (e.g.
  trying to coerce`"character"` values to `"double"`) will likely result
  in an error or potentially unexpected behaviour so use with care.

- date_col:

  Optional name of the column containing the date observations actually
  occurred (e.g., `"target_end_date"`) to be interpreted as date. Useful
  when this column does not correspond to a valid task ID (e.g.,
  calculated from other task IDs like `origin_date + horizon`) for: (1)
  correct schema creation, particularly when it's also a partitioning
  column, and (2) more robust column name validation when
  `target-data.json` config does not exist. Ignored when
  `target-data.json` exists.

- allow_extra_dates:

  Logical. If TRUE and target_type is "time-series", allows date values
  not in tasks.json. Other task ID columns are still strictly validated.
  Ignored for oracle-output (always strict).

- na:

  A character vector of strings to interpret as missing values. Only
  applies to CSV files. The default is `c("NA", "")`. Useful when actual
  character string `"NA"` values are used in the data. In such a case,
  use empty cells to indicate missing values in your files and set
  `na = ""`.

- round_id:

  Character string. Not generally relevant to target datasets but can be
  used to specify a specific block of custom validation checks.
  Otherwise best set to `"default"` which will deploy the default custom
  validation checks.

- validations_cfg_path:

  Path to YAML file configuring custom validation checks. If `NULL`
  defaults to standard `hub-config/validations.yml` path. For more
  details see [article on custom validation
  checks](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.html).

- file_modification_check:

  Character string. Whether to perform check and what to return when
  modification/deletion of a previously submitted target data file is
  detected in PR:

  - `"none"`: No modification/deletion checks performed.

  - `"message"`: Appends a `<message/check_info>` condition class object
    for each applicable modified/deleted file.

  - `"failure"`: Appends a `<error/check_failure>` condition class
    object for each applicable modified/deleted file.

  - `"error"`: Appends a `<error/check_error>` condition class object
    for each applicable modified/deleted file.

  Defaults to `"none`".

- allow_target_type_deletion:

  Logical. Whether to allow deletion of an entire target type dataset
  (i.e. all files of a target type) in the PR. Defaults to `FALSE`.

## Value

An object of class `target_validations`.

## Details

Only target data files are individually validated using
[`validate_target_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_submission.md)
although as part of checks, hub config files and any affected target
type datasets as a whole are also validated via
[`validate_target_dataset()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_dataset.md).
Any other files included in the PR are ignored but flagged in a message.

By default, modifications (which include renaming) and deletions of
previously submitted target data files are allowed. This behaviour can
be modified through arguments `file_modification_check`, which controls
whether modification/deletion checks are performed and what is returned
if modifications/deletions are detected.

### Checks on target dataset

Details of checks performed by
[`validate_target_dataset()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_dataset.md)

| Name                           | Check                                                                | Early return | Fail output   | Extra info |
|:-------------------------------|:---------------------------------------------------------------------|:-------------|:--------------|:-----------|
| valid_config                   | Hub config valid                                                     | TRUE         | check_error   |            |
| target_dataset_exists          | Target dataset can be successfully detected for a given target type. | TRUE         | check_error   |            |
| target_dataset_unique          | A single unique target dataset exists for a given target type.       | TRUE         | check_error   |            |
| target_dataset_file_ext_unique | All files of a given target type share a single unique file format.  | TRUE         | check_error   |            |
| target_dataset_rows_unique     | Target dataset rows are all unique.                                  | FALSE        | check_failure |            |

### Checks on individual target files

Details of checks performed by
[`validate_target_submission()`](https://hubverse-org.github.io/hubValidations/reference/validate_target_submission.md)

| Name                       | Check                                                                                                                                               | Early return | Fail output   | Extra info | optional |
|:---------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-----------|:---------|
| target_file_exists         | File exists at \`file_path\` provided.                                                                                                              | TRUE         | check_error   |            | FALSE    |
| target_partition_file_name | Hive-style partition file path segments are valid and can be parsed successfully. Skipped if target dataset not hive-partitioned.                   | TRUE         | check_error   |            | FALSE    |
| target_file_ext            | Target data file extension is valid.                                                                                                                | TRUE         | check_error   |            | FALSE    |
| target_file_read           | Target data file can be read successfully.                                                                                                          | TRUE         | check_error   |            | FALSE    |
| target_tbl_colnames        | Target data file has the correct column names according to target type.                                                                             | TRUE         | check_error   |            | FALSE    |
| target_tbl_coltypes        | Target data file has the correct column types according to target type.                                                                             | TRUE         | check_error   |            | FALSE    |
| target_tbl_ts_targets      | Targets in a time-series target data file are valid. Only performed on \`time-series\` data files.                                                  | TRUE         | check_error   |            | FALSE    |
| target_tbl_rows_unique     | Target data file rows are all unique.                                                                                                               | FALSE        | check_failure |            | FALSE    |
| target_tbl_values          | Task ID columns in a target data file have valid task ID values.                                                                                    | TRUE         | check_error   |            | FALSE    |
| target_tbl_output_type_ids | Output type ID values in a target data file are valid and complete. Only performed when the target data file contains an \`output_type_id\` column. | TRUE         | check_error   |            | FALSE    |
| target_tbl_oracle_value    | Oracle values in a target data file are valid. Only performed on \`oracle output\` data files.                                                      | FALSE        | check_failure |            | FALSE    |

## Examples

``` r
if (FALSE) { # \dontrun{
tmp_dir <- withr::local_tempdir()
ci_target_hub_path <- fs::path(tmp_dir, "target")
gert::git_clone(
  url = "https://github.com/hubverse-org/ci-testhub-target.git",
  path = ci_target_hub_path
)
# Validate addition of single file in single file target dataset
gert::git_branch_checkout(
  "add-file-oracle-output",
  repo = ci_target_hub_path
)
validate_target_pr(
  hub_path = ci_target_hub_path,
  gh_repo = "hubverse-org/ci-testhub-target",
  pr_number = 1
)
# Validate addition of multiple files in partitioned target dataset
gert::git_branch_checkout(
  "add-target-dir-files-v5",
  repo = ci_target_hub_path
)
validate_target_pr(
  hub_path = ci_target_hub_path,
  gh_repo = "hubverse-org/ci-testhub-target",
  pr_number = 2
)
} # }
```
