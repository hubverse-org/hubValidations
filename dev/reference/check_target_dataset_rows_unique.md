# Check target dataset rows are all unique

Check that there are no duplicate rows in a target dataset. Function
designed to be used as part of overall target data integrity check.

## Usage

``` r
check_target_dataset_rows_unique(
  target_type = c("time-series", "oracle-output"),
  na = c("NA", ""),
  date_col = NULL,
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date"),
  hub_path
)
```

## Arguments

- target_type:

  Type of target data to retrieve matching files. One of "time-series"
  or "oracle-output". Defaults to "time-series".

- na:

  A character vector of strings to interpret as missing values. Only
  applies to CSV files. The default is `c("NA", "")`. Useful when actual
  character string `"NA"` values are used in the data. In such a case,
  use empty cells to indicate missing values in your files and set
  `na = ""`.

- date_col:

  Optional column name to be interpreted as date for dataset connection.
  Useful when the date column does not correspond to a valid task ID
  (e.g., calculated from other task IDs like `origin_date + horizon`),
  particularly when it is also a partitioning column. Ignored when
  `target-data.json` config is provided.

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

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

If datasets are versioned, multiple observations are allowed in
`time-series` target data, so long as they have different `as_of`
values. The `as_of` column is therefore included when determining
duplicates. In `oracle-output` data, there should be only a single
observation, regardless of the `as_of` value so the column it is not be
included when determining duplicates.
