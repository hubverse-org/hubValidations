# Check that predicted values per location are less than total location population.

Check that predicted values per location are less than total location
population.

## Usage

``` r
opt_check_tbl_counts_lt_popn(
  tbl,
  file_path,
  hub_path,
  targets = NULL,
  popn_file_path = "auxiliary-data/locations.csv",
  popn_col = "population",
  location_col = "location"
)
```

## Arguments

- tbl:

  a tibble/data.frame of the contents of the file being validated.

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

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

- targets:

  Either a single target key list or a list of multiple target key
  lists.

- popn_file_path:

  Character string. Path to population data relative to the hub root.
  Defaults to `auxiliary-data/locations.csv`.

- popn_col:

  Character string. The name of the population size column in the
  population data set.

- location_col:

  Character string. The name of the location column. Used to join
  population data to submission file data. Must be shared by both files.

## Value

Depending on whether validation has succeeded, one of:

- `<message/check_success>` condition class object.

- `<error/check_failure>` condition class object.

Returned object also inherits from subclass `<hub_check>`.

## Details

Should only be applied to rows containing count predictions. Use
argument `targets` to filter `tbl` data to appropriate count target
rows.

Should be deployed as part of `validate_model_data` optional checks.

## Examples

``` r
hub_path <- system.file("testhubs/flusight", package = "hubValidations")
file_path <- "hub-ensemble/2023-05-08-hub-ensemble.parquet"
tbl <- hubValidations::read_model_out_file(file_path, hub_path)
# Single target key list
targets <- list("target" = "wk ahead inc flu hosp")
opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets)
#> <message/check_success>
#> Message:
#> Target counts are less than location population size.
```
