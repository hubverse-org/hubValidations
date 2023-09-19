# check_metadata_matches_schema works

    Code
      check_metadata_matches_schema(file_path = "hub-baseline.yml", hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      Metadata file contents are consistent with schema specifications.

---

    Code
      check_metadata_matches_schema(file_path = "team1-goodmodel.yaml", hub_path = hub_path)
    Output
      <error/check_error>
      Error:
      ! Metadata file contents must be consistent with schema specifications.  - must have required property 'model_details' . - must NOT have additional properties; saw unexpected property 'models_details'. - must NOT have additional properties; saw unexpected property 'ensemble_of_hub_models"'. - /include_ensemble must be boolean .

