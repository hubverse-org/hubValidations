# check_metadata_schema_exists works

    Code
      check_metadata_schema_exists(hub_path)
    Output
      <message/check_success>
      Message:
      File exists at path 'hub-config/model-metadata-schema.json'.

---

    Code
      check_metadata_schema_exists(hub_path = "random_path")
    Output
      <error/check_error>
      Error:
      ! File does not exist at path 'hub-config/model-metadata-schema.json'.

