# check_file_location works

    Code
      check_file_location("team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Output
      <message/check_success>
      Message:
      File directory name matches `model_id` metadata in file name.

---

    Code
      check_file_location("team1-goodmodel/2022-10-08-team2-goodmodel.csv")
    Output
      <error/check_failure>
      Error:
      ! File directory name must match `model_id` metadata in file name.  File should be submitted to directory "team2-goodmodel" not "team1-goodmodel"

