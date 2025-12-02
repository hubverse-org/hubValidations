# Validate a submitted target data file.

Checks both file level properties like file name, extension, location
etc as well as target data, i.e. the contents of the file.

## Usage

``` r
validate_target_submission(
  hub_path,
  file_path,
  target_type = c("time-series", "oracle-output"),
  date_col = NULL,
  round_id = "default",
  na = c("NA", ""),
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date"),
  validations_cfg_path = NULL,
  skip_check_config = FALSE
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

- file_path:

  A character string representing the path to the target data file
  relative to the `target-data` directory.

- target_type:

  Type of target data to retrieve matching files. One of "time-series"
  or "oracle-output". Defaults to "time-series".

- date_col:

  Optional name of the column containing the date observations actually
  occurred (e.g., `"target_end_date"`) to be interpreted as date. Useful
  when this column does not correspond to a valid task ID (e.g.,
  calculated from other task IDs like `origin_date + horizon`) for: (1)
  correct schema creation, particularly when it's also a partitioning
  column, and (2) more robust column name validation when
  `target-data.json` config does not exist. Ignored when
  `target-data.json` exists.

- round_id:

  Character string. Not generally relevant to target datasets but can be
  used to specify a specific block of custom validation checks.
  Otherwise best set to `"default"` which will deploy the default custom
  validation checks.

- na:

  A character vector of strings to interpret as missing values. Only
  applies to CSV files. The default is `c("NA", "")`. Useful when actual
  character string `"NA"` values are used in the data. In such a case,
  use empty cells to indicate missing values in your files and set
  `na = ""`.

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

- validations_cfg_path:

  Path to YAML file configuring custom validation checks. If `NULL`
  defaults to standard `hub-config/validations.yml` path. For more
  details see [article on custom validation
  checks](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.html).

- skip_check_config:

  Logical. Whether to skip the hub config validation check.

## Value

An object of class `hub_validations`. Each named element contains a
`hub_check` class object reflecting the result of a given check.
Function will return early if a check returns an error.

For more details on the structure of `<hub_validations>` objects,
including how to access more information on individual checks, see
[article on `<hub_validations>` S3 class
objects](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).

## Details

Details of checks performed by `validate_target_submission()`

| Name                       | Check                                                                                                                                               | Early return | Fail output   | Extra info |
|:---------------------------|:----------------------------------------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-----------|
| valid_config               | Hub config valid                                                                                                                                    | TRUE         | check_error   |            |
| target_file_exists         | File exists at \`file_path\` provided.                                                                                                              | TRUE         | check_error   |            |
| target_partition_file_name | Hive-style partition file path segments are valid and can be parsed successfully. Skipped if target dataset not hive-partitioned.                   | TRUE         | check_error   |            |
| target_file_ext            | Target data file extension is valid.                                                                                                                | TRUE         | check_error   |            |
| target_file_read           | Target data file can be read successfully.                                                                                                          | TRUE         | check_error   |            |
| target_tbl_colnames        | Target data file has the correct column names according to target type.                                                                             | TRUE         | check_error   |            |
| target_tbl_coltypes        | Target data file has the correct column types according to target type.                                                                             | TRUE         | check_error   |            |
| target_tbl_ts_targets      | Targets in a time-series target data file are valid. Only performed on \`time-series\` data files.                                                  | TRUE         | check_error   |            |
| target_tbl_rows_unique     | Target data file rows are all unique.                                                                                                               | FALSE        | check_failure |            |
| target_tbl_values          | Task ID columns in a target data file have valid task ID values.                                                                                    | TRUE         | check_error   |            |
| target_tbl_output_type_ids | Output type ID values in a target data file are valid and complete. Only performed when the target data file contains an \`output_type_id\` column. | TRUE         | check_error   |            |
| target_tbl_oracle_value    | Oracle values in a target data file are valid. Only performed on \`oracle output\` data files.                                                      | FALSE        | check_failure |            |

## Examples

``` r
hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
validate_target_submission(
  hub_path,
  file_path = "time-series.csv",
  target_type = "time-series"
)
#> 
#> ── target_file ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── time-series.csv ────
#> 
#> ✔ [target_file_exists]: File exists at path target-data/time-series.csv.
#> ℹ [target_partition_file_name]: Target file path not hive-partitioned. Check
#>   skipped.
#> ✔ [target_file_ext]: Target data file extension is valid.
#> ✔ [target_file_read]: target file could be read successfully.
#> ✔ [target_tbl_colnames]: Column names are consistent with expected column names
#>   for time-series target type data.  Column name validation for time-series
#>   data in inference mode is limited. For robust validation, create a
#>   target-data.json config file. See `target-data.json` documentation
#>   (<https://docs.hubverse.io/en/latest/user-guide/hub-config.html#hub-target-data-configuration-target-data-json-file>)
#> ✔ [target_tbl_coltypes]: Column data types match time-series target schema.
#> ✔ [target_tbl_ts_targets]: time-series targets are all valid.
#> ✔ [target_tbl_rows_unique]: time-series target data rows are unique.
#> ✔ [target_tbl_values]: `target_tbl_chr` contains valid values/value
#>   combinations.
#> ℹ [target_tbl_output_type_ids]: Check not applicable to time-series target
#>   data. Skipped.
#> ℹ [target_tbl_oracle_value]: Check not applicable to time-series target data.
#>   Skipped.
# Example with partitioned data
hub_path <- system.file("testhubs/v5/target_dir", package = "hubUtils")
validate_target_submission(
  hub_path,
  file_path = "time-series/target=wk%20flu%20hosp%20rate/part-0.parquet",
  target_type = "time-series"
)
#> 
#> ── target_dir ────
#> 
#> ✔ [valid_config]: All hub config files are valid.
#> 
#> ── time-series/target=wk%20flu%20hosp%20rate/part-0.parquet ────
#> 
#> ✔ [target_file_exists]: File exists at path
#>   target-data/time-series/target=wk%20flu%20hosp%20rate/part-0.parquet.
#> ✔ [target_partition_file_name]: Hive-style partition file path segments are
#>   valid.
#> ✔ [target_file_ext]: Hive-partitioned target data file extension is valid.
#> ✔ [target_file_read]: target file could be read successfully.
#> ✔ [target_tbl_colnames]: Column names are consistent with expected column names
#>   for time-series target type data.  Column name validation for time-series
#>   data in inference mode is limited. For robust validation, create a
#>   target-data.json config file. See `target-data.json` documentation
#>   (<https://docs.hubverse.io/en/latest/user-guide/hub-config.html#hub-target-data-configuration-target-data-json-file>)
#> ✔ [target_tbl_coltypes]: Column data types match time-series target schema.
#> ✔ [target_tbl_ts_targets]: time-series targets are all valid.
#> ✔ [target_tbl_rows_unique]: time-series target data rows are unique.
#> ✔ [target_tbl_values]: `target_tbl_chr` contains valid values/value
#>   combinations.
#> ℹ [target_tbl_output_type_ids]: Check not applicable to time-series target
#>   data. Skipped.
#> ℹ [target_tbl_oracle_value]: Check not applicable to time-series target data.
#>   Skipped.
```
