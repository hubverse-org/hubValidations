# Validate a submitted model data file submission time.

Validate a submitted model data file submission time.

## Usage

``` r
validate_submission_time(
  hub_path,
  file_path,
  ref_date_from = c("file_path", "file")
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

  character string. Path to the file being validated relative to the
  hub's model-output directory.

- ref_date_from:

  whether to get the reference date around which relative submission
  windows will be determined from the file's `file_path` round ID or the
  `file` contents themselves. `file` requires that the file can be read.
  Only applicable when a round is configured to determine the submission
  windows relative to the value in a date column in model output files.
  Not applicable when explicit submission window start and end dates are
  provided in the hub's config.

## Value

An object of class `hub_validations`. Each named element contains a
`hub_check` class object reflecting the result of a given check.
Function will return early if a check returns an error.

For more details on the structure of `<hub_validations>` objects,
including how to access more information on individual checks, see
[article on `<hub_validations>` S3 class
objects](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")
file_path <- "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
validate_submission_time(hub_path, file_path)
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
#> 
#> ✖ [submission_time]: Submission time must be within accepted submission window
#>   for round.  Current time "2025-11-18 16:05:51 UTC" is outside window
#>   2022-10-02 EDT--2022-10-09 23:59:59 EDT.
```
