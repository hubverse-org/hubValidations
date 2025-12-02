# Check that a target data file has the correct column names according to target type

Check that a target data file has the correct column names according to
target type

## Usage

``` r
check_target_tbl_colnames(
  target_tbl,
  target_type = c("time-series", "oracle-output"),
  file_path,
  hub_path,
  config_target_data = NULL,
  date_col = NULL
)
```

## Arguments

- target_tbl:

  A tibble/data.frame of the contents of the target data file being
  validated.

- target_type:

  Type of target data to retrieve matching files. One of "time-series"
  or "oracle-output". Defaults to "time-series".

- file_path:

  A character string representing the path to the target data file
  relative to the `target-data` directory.

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

- config_target_data:

  Optional. A `target-data.json` config object. If provided, validation
  uses deterministic schema from config. If `NULL` (default), validation
  uses inference from `tasks.json`.

- date_col:

  Optional. Name of the date column in target data (e.g.,
  `"target_end_date"`) representing the date observations actually
  occurred. Only relevant when it is not a task ID defined in
  `tasks.json`. Enables deterministic validation in inference mode.
  Ignored when `config_target_data` is provided.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_error>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

Column name validation depends on whether a `target-data.json`
configuration file is provided:

**With `target-data.json` config:** Expected columns are determined
directly from the configuration. The target table must contain exactly
the columns defined in the config.

**Without `target-data.json` config (inference mode):** Expected columns
are inferred from the task ID configuration in `tasks.json`, allowed
columns according to the target type, and expectations based on the
detected output types in the target data. Additional optional columns
(e.g., `as_of`) are allowed for time-series data.

**Note on date columns:** Target data always contains a date column
(e.g., `target_end_date`) representing when observations occurred.
However, in horizon-based forecast hubs, task IDs may only define
`origin_date` and `horizon` (with target dates calculated from these).
In such cases, provide `date_col` to enable deterministic validation of
the date column when it is not a valid task ID. Validation of date
column existence and type is performed by
[`check_target_tbl_coltypes()`](https://hubverse-org.github.io/hubValidations/dev/reference/check_target_tbl_coltypes.md).

Inference mode validation for time-series data is limited. For robust
validation, create a `target-data.json` config file. See
[`target-data.json`
schema](https://docs.hubverse.io/en/latest/user-guide/hub-config.html#hub-target-data-configuration-target-data-json-file)
for more information on the json schema scpecifics.
