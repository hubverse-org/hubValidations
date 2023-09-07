# check_metadata_file_ext works

    Code
      check_metadata_file_ext("hub-baseline.yml")
    Output
      <message/check_success>
      Message:
      Metadata file extension is "yml" or "yaml".

---

    Code
      check_metadata_file_ext("hub-baseline.yaml")
    Output
      <message/check_success>
      Message:
      Metadata file extension is "yml" or "yaml".

---

    Code
      check_metadata_file_ext("hub-baseline.txt")
    Output
      <error/check_error>
      Error:
      ! Metadata file extension must be "yml" or "yaml".  However, it was "txt".

