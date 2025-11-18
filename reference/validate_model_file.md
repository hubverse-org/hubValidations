# Valid file level properties of a submitted model output file.

Valid file level properties of a submitted model output file.

## Usage

``` r
validate_model_file(hub_path, file_path, validations_cfg_path = NULL)
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

- validations_cfg_path:

  Path to `validations.yml` file. If `NULL` defaults to
  `hub-config/validations.yml`.

## Value

An object of class `hub_validations`. Each named element contains a
`hub_check` class object reflecting the result of a given check.
Function will return early if a check returns an error.

For more details on the structure of `<hub_validations>` objects,
including how to access more information on individual checks, see
[article on `<hub_validations>` S3 class
objects](https://hubverse-org.github.io/hubValidations/articles/hub-validations-class.html).

## Details

Details of checks performed by `validate_model_file()`

| Name            | Check                                                                        | Early return | Fail output   | Extra info |
|:----------------|:-----------------------------------------------------------------------------|:-------------|:--------------|:-----------|
| file_exists     | File exists at \`file_path\` provided                                        | TRUE         | check_error   |            |
| file_name       | File name valid                                                              | TRUE         | check_error   |            |
| file_location   | File located in correct team directory                                       | FALSE        | check_failure |            |
| round_id_valid  | File round ID is valid hub round IDs                                         | TRUE         | check_error   |            |
| file_format     | File format is accepted hub/round format                                     | TRUE         | check_error   |            |
| file_n          | Number of submission files per round per team does not exceed allowed number | FALSE        | check_failure |            |
| metadata_exists | Model metadata file exists in expected location                              | FALSE        | check_failure |            |

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")
validate_model_file(hub_path,
  file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
)
#> 
#> ── 2022-10-08-team1-goodmodel.csv ────
#> 
#> ✔ [file_exists]: File exists at path
#>   model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv.
#> ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
#> ✔ [file_location]: File directory name matches `model_id` metadata in file
#>   name.
#> ✔ [round_id_valid]: `round_id` is valid.
#> ✔ [file_format]: File is accepted hub format.
#> ✔ [file_n]: Number of accepted model output files per round met.
#> ✔ [metadata_exists]: Metadata file exists at path
#>   model-metadata/team1-goodmodel.yaml.
validate_model_file(hub_path,
  file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
)
#> 
#> ── 2022-10-15-team1-goodmodel.csv ────
#> 
#> ⓧ [file_exists]: File does not exist at path
#>   model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv.
```
