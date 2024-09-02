# check_metadata_file_location works

    Code
      check_metadata_file_location("hub-baseline.yml")
    Output
      <message/check_success>
      Message:
      Metadata file directory name matches "model-metadata".

---

    Code
      check_metadata_file_location("random_folder/hub-baseline.yml")
    Output
      <error/check_failure>
      Error:
      ! Metadata file directory name must match "model-metadata".  Metadata files should be submitted to directory "model-metadata", not "model-metadata/random_folder".

