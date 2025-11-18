# Valid properties of a metadata file.

Valid properties of a metadata file.

## Usage

``` r
validate_model_metadata(
  hub_path,
  file_path,
  round_id = "default",
  validations_cfg_path = NULL
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

- round_id:

  character string. The round identifier. Used primarily to indicate
  whether the "default" or a round specific configuration should be used
  for custom validations.

- validations_cfg_path:

  Path to `validations.yml` file. If `NULL` defaults to
  `hub-config/validations.yml`.

## Value

An object of class `hub_validations`. Each named element contains a
`hub_check` class object reflecting the result of a given check.
Function will return early if a check returns an error.

## Details

Details of checks performed by `validate_model_metadata()`

| Name                    | Check                                                                                                                   | Early return | Fail output   | Extra info |
|:------------------------|:------------------------------------------------------------------------------------------------------------------------|:-------------|:--------------|:-----------|
| metadata_schema_exists  | A model metadata schema file exists in \`hub-config\` directory.                                                        | TRUE         | check_error   |            |
| metadata_file_exists    | A file with name provided to argument \`file_path\` exists at the expected location (the \`model-metadata\` directory). | TRUE         | check_error   |            |
| metadata_file_ext       | The metadata file has correct extension (yaml or yml).                                                                  | TRUE         | check_error   |            |
| metadata_file_location  | The metadata file has been saved to correct location.                                                                   | TRUE         | check_failure |            |
| metadata_matches_schema | The contents of the metadata file match the hub's model metadata schema                                                 | TRUE         | check_error   |            |
| metadata_file_name      | The metadata filename matches the model ID specified in the contents of the file.                                       | TRUE         | check_error   |            |

## Examples

``` r
hub_path <- system.file("testhubs/simple", package = "hubValidations")
validate_model_metadata(hub_path,
  file_path = "hub-baseline.yml"
)
#> 
#> ── model-metadata-schema.json ────
#> 
#> ✔ [metadata_schema_exists]: File exists at path
#>   hub-config/model-metadata-schema.json.
#> 
#> ── hub-baseline.yml ────
#> 
#> ✔ [metadata_file_exists]: File exists at path model-metadata/hub-baseline.yml.
#> ✔ [metadata_file_ext]: Metadata file extension is "yml" or "yaml".
#> ✔ [metadata_file_location]: Metadata file directory name matches
#>   "model-metadata".
#> ✔ [metadata_matches_schema]: Metadata file contents are consistent with schema
#>   specifications.
#> ✔ [metadata_file_name]: Metadata file name matches the `model_id` specified
#>   within the metadata file.
validate_model_metadata(hub_path,
  file_path = "team1-goodmodel.yaml"
)
#> 
#> ── model-metadata-schema.json ────
#> 
#> ✔ [metadata_schema_exists]: File exists at path
#>   hub-config/model-metadata-schema.json.
#> 
#> ── team1-goodmodel.yaml ────
#> 
#> ✔ [metadata_file_exists]: File exists at path
#>   model-metadata/team1-goodmodel.yaml.
#> ✔ [metadata_file_ext]: Metadata file extension is "yml" or "yaml".
#> ✔ [metadata_file_location]: Metadata file directory name matches
#>   "model-metadata".
#> ⓧ [metadata_matches_schema]: Metadata file contents must be consistent with
#>   schema specifications.  - must have required property 'model_details' . -
#>   must NOT have additional properties; saw unexpected property
#>   'models_details'. - must NOT have additional properties; saw unexpected
#>   property 'ensemble_of_hub_models"'. - /include_ensemble must be boolean .
```
