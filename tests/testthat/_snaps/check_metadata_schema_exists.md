# check_metadata_schema_exists works

    Code
      check_metadata_schema_exists(hub_path, file_path)
    Output
      <message/check_success>
      Message:
      Model metadata schema file exists at path 'hub-config/model-metadata-schema.json'.

---

    Code
      check_metadata_schema_exists(hub_path = "random_path", file_path = file_path)
    Output
      <error/check_error>
      Error:
      ! Model metadata schema file does not exist at path 'hub-config/model-metadata-schema.json'.

