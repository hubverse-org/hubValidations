# Validate dataset level properties of a given target type

Validate dataset level properties of a given target type

## Usage

``` r
validate_target_dataset(
  hub_path,
  target_type = c("time-series", "oracle-output"),
  validations_cfg_path = NULL,
  round_id = "default"
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

- target_type:

  Type of target data to retrieve matching files. One of "time-series"
  or "oracle-output". Defaults to "time-series".

- validations_cfg_path:

  Path to YAML file configuring custom validation checks. If `NULL`
  defaults to standard `hub-config/validations.yml` path. For more
  details see [article on custom validation
  checks](https://hubverse-org.github.io/hubValidations/articles/deploying-custom-functions.html).

- round_id:

  Character string. Not generally relevant to target datasets but can be
  used to specify a specific block of custom validation checks.
  Otherwise best set to `"default"` which will deploy the default custom
  validation checks.

## Value

An object of class `hub_validations`. Each named element contains a
`hub_check` class object reflecting the result of a given check.
Function will return early if a check returns an error.

For more details on the structure of `<hub_validations>` objects,
including how to access more information on individual checks, see
[article on `<hub_validations>` S3 class
objects](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).

## Details

Details of checks performed by `validate_target_dataset()`

| Name                           | Check                                                                | Early return | Fail output   | Extra info |
|:-------------------------------|:---------------------------------------------------------------------|:-------------|:--------------|:-----------|
| target_dataset_exists          | Target dataset can be successfully detected for a given target type. | TRUE         | check_error   |            |
| target_dataset_unique          | A single unique target dataset exists for a given target type.       | TRUE         | check_error   |            |
| target_dataset_file_ext_unique | All files of a given target type share a single unique file format.  | TRUE         | check_error   |            |
| target_dataset_rows_unique     | Target dataset rows are all unique.                                  | FALSE        | check_failure |            |

## Examples

``` r
# Validate single file target datasets
hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
validate_target_dataset(hub_path,
  target_type = "time-series"
)
#> 
#> ── time-series.csv ────
#> 
#> ✔ [target_dataset_exists]: time-series dataset detected.
#> ✔ [target_dataset_unique]: target-data directory contains single unique
#>   time-series dataset.
#> ✔ [target_dataset_file_ext_unique]: time-series dataset files share single
#>   unique file format.
#> ✔ [target_dataset_rows_unique]: time-series target dataset rows are unique.
validate_target_dataset(hub_path,
  target_type = "oracle-output"
)
#> 
#> ── oracle-output.csv ────
#> 
#> ✔ [target_dataset_exists]: oracle-output dataset detected.
#> ✔ [target_dataset_unique]: target-data directory contains single unique
#>   oracle-output dataset.
#> ✔ [target_dataset_file_ext_unique]: oracle-output dataset files share single
#>   unique file format.
#> ✔ [target_dataset_rows_unique]: oracle-output target dataset rows are unique.
# Validate multi-file partitioned target datasets
hub_path <- system.file("testhubs/v5/target_dir", package = "hubUtils")
validate_target_dataset(hub_path,
  target_type = "time-series"
)
#> 
#> ── time-series ────
#> 
#> ✔ [target_dataset_exists]: time-series dataset detected.
#> ✔ [target_dataset_unique]: target-data directory contains single unique
#>   time-series dataset.
#> ✔ [target_dataset_file_ext_unique]: time-series dataset files share single
#>   unique file format.
#> ✔ [target_dataset_rows_unique]: time-series target dataset rows are unique.
validate_target_dataset(hub_path,
  target_type = "oracle-output"
)
#> 
#> ── oracle-output ────
#> 
#> ✔ [target_dataset_exists]: oracle-output dataset detected.
#> ✔ [target_dataset_unique]: target-data directory contains single unique
#>   oracle-output dataset.
#> ✔ [target_dataset_file_ext_unique]: oracle-output dataset files share single
#>   unique file format.
#> ✔ [target_dataset_rows_unique]: oracle-output target dataset rows are unique.
```
