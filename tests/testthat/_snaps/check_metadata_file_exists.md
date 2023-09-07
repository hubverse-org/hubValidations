# check_metadata_file_exists works

    Code
      check_metadata_file_exists(hub_path, "hub-baseline.yml")
    Output
      <message/check_success>
      Message:
      File exists at path 'model-metadata/hub-baseline.yml'.

---

    Code
      check_metadata_file_exists(hub_path = "random_path", "hub-baseline.yml")
    Output
      <error/check_error>
      Error:
      ! File does not exist at path 'model-metadata/hub-baseline.yml'.

---

    Code
      check_metadata_file_exists(hub_path = hub_path, "random_path")
    Output
      <error/check_error>
      Error:
      ! File does not exist at path 'model-metadata/random_path'.

