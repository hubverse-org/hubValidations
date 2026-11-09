# validate_model_metadata works

    Code
      res$metadata_matches_schema
    Output
      <error/check_error>
      Error:
      ! Metadata file contents must be consistent with schema specifications.  - must have required property 'model_details' . - must NOT have additional properties; saw unexpected property 'models_details'. - must NOT have additional properties; saw unexpected property 'ensemble_of_hub_models"'. - /include_ensemble must be boolean .

---

    Code
      res$metadata_matches_schema
    Output
      <error/check_error>
      Error:
      ! Metadata file contents must be consistent with schema specifications.  - must have required property 'model_abbr' .

---

    Code
      res$metadata_file_exists
    Output
      <error/check_error>
      Error:
      ! File does not exist at path 'model-metadata/2020-10-06-random-path.csv'.

