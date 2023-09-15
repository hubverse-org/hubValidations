# check_metadata_file_exists works

    Code
      check_submission_metadata_file_exists(hub_path = hub_path, file_path = "hub-baseline/2022-10-01-hub-baseline.csv")
    Output
      <message/check_success>
      Message:
      Metadata file exists at path 'model-metadata/hub-baseline.yml'.

---

    Code
      check_submission_metadata_file_exists(hub_path = hub_path, file_path = "random-model/2022-10-01-random-model.csv")
    Output
      <error/check_error>
      Error:
      ! Metadata file does not exist at path 'model-metadata/random-model.yml' or 'model-metadata/random-model.yaml'.

