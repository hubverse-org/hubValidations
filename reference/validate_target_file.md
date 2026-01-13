# Validate file level properties of a target data file.

Validate file level properties of a target data file.

## Usage

``` r
validate_target_file(
  hub_path,
  file_path,
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

- file_path:

  A character string representing the path to the target data file
  relative to the `target-data` directory.

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

Details of checks performed by `validate_target_file()`

| Name                       | Check                                                                                                                             | Early return | Fail output | Extra info |
|:---------------------------|:----------------------------------------------------------------------------------------------------------------------------------|:-------------|:------------|:-----------|
| target_file_exists         | File exists at \`file_path\` provided.                                                                                            | TRUE         | check_error |            |
| target_partition_file_name | Hive-style partition file path segments are valid and can be parsed successfully. Skipped if target dataset not hive-partitioned. | TRUE         | check_error |            |
| target_file_ext            | Target data file extension is valid.                                                                                              | TRUE         | check_error |            |

## Examples

``` r
hub_path <- system.file("testhubs/v5/target_file", package = "hubUtils")
validate_target_file(hub_path,
  file_path = "time-series.csv"
)
#> 
#> ── time-series.csv ────
#> 
#> ✔ [target_file_exists]: File exists at path target-data/time-series.csv.
#> ℹ [target_partition_file_name]: Target file path not hive-partitioned. Check
#>   skipped.
#> ✔ [target_file_ext]: Target data file extension is valid.
validate_target_file(hub_path,
  file_path = "oracle-output.csv"
)
#> 
#> ── oracle-output.csv ────
#> 
#> ✔ [target_file_exists]: File exists at path target-data/oracle-output.csv.
#> ℹ [target_partition_file_name]: Target file path not hive-partitioned. Check
#>   skipped.
#> ✔ [target_file_ext]: Target data file extension is valid.
hub_path <- system.file("testhubs/v5/target_dir", package = "hubUtils")
validate_target_file(hub_path,
  file_path = "time-series/target=flu_hosp_rate/part-0.parquet"
)
#> 
#> ── time-series/target=flu_hosp_rate/part-0.parquet ────
#> 
#> ✔ [target_file_exists]: File exists at path
#>   target-data/time-series/target=flu_hosp_rate/part-0.parquet.
#> ✔ [target_partition_file_name]: Hive-style partition file path segments are
#>   valid.
#> ✔ [target_file_ext]: Hive-partitioned target data file extension is valid.
validate_target_file(hub_path,
  file_path = "oracle-output/output_type=pmf/part-0.parquet"
)
#> 
#> ── oracle-output/output_type=pmf/part-0.parquet ────
#> 
#> ✔ [target_file_exists]: File exists at path
#>   target-data/oracle-output/output_type=pmf/part-0.parquet.
#> ✔ [target_partition_file_name]: Hive-style partition file path segments are
#>   valid.
#> ✔ [target_file_ext]: Hive-partitioned target data file extension is valid.
```
