# check_metadata_file_name works

    Code
      check_metadata_file_name(file_path = "hub-baseline.yml", hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      Metadata file name matches the `model_id` specified within the metadata file.

---

    Code
      check_metadata_file_name(file_path = "hub-baseline-with-model_id.yml",
        hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      Metadata file name matches the `model_id` specified within the metadata file.

---

    Code
      check_metadata_file_name(file_path = "hub-baseline-with-wrong-model_id.yml",
        hub_path = hub_path)
    Output
      <error/check_error>
      Error:
      ! Metadata file name must match the `model_id` specified within the metadata file.  File name was "hub-baseline-with-wrong-model_id.yml", but `model_id` was "wrong-model_id".

---

    Code
      check_metadata_file_name(file_path = "hub-baseline-no-abbrs-or-model_id.yml",
        hub_path = hub_path)
    Output
      <error/check_error>
      Error:
      ! Metadata file must contain either a `model_id` or both a `team_abbr` and `model_abbr`.  There is an error in the set up of the hub's "model-metadata-schema.json" config file.

---

    Code
      check_metadata_file_name(file_path = "team1-goodmodel.yaml", hub_path = hub_path)
    Output
      <message/check_success>
      Message:
      Metadata file name matches the `model_id` specified within the metadata file.

