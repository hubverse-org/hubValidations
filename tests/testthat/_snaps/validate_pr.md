# validate_pr works on invalid PR

    Code
      invalid_checks[[file_path]][["colnames"]]
    Output
      <error/check_error>
      Error:
      ! Column names must be consistent with expected round task IDs and std column names.  Expected column "age_group" not present in file.

# validate_pr flags modifications and deletions in PR

    Code
      purrr::map(mod_checks_error[mod_files], "valid_file_status")
    Output
      $`hub-baseline/2022-10-08-hub-baseline.csv`
      <error/check_error>
      Error:
      ! Previously submitted model output files must not be modified.  'model-output/hub-baseline/2022-10-08-hub-baseline.csv' modified.
      
      $`team1-goodmodel/2022-10-15-team1-goodmodel.csv`
      <error/check_error>
      Error:
      ! Previously submitted model output files must not be removed.  'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv' removed.
      
      $`team1-goodmodel.yaml`
      <error/check_error>
      Error:
      ! Previously submitted model metadata files must not be removed.  'model-metadata/team1-goodmodel.yaml' removed.
      

---

    Code
      purrr::map(mod_checks_warn[mod_files], "valid_file_status")
    Output
      $`hub-baseline/2022-10-08-hub-baseline.csv`
      <error/check_failure>
      Error:
      ! Previously submitted model output files must not be modified.  'model-output/hub-baseline/2022-10-08-hub-baseline.csv' modified.
      
      $`team1-goodmodel/2022-10-15-team1-goodmodel.csv`
      <error/check_failure>
      Error:
      ! Previously submitted model output files must not be removed.  'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv' removed.
      
      $`team1-goodmodel.yaml`
      <error/check_failure>
      Error:
      ! Previously submitted model metadata files must not be removed.  'model-metadata/team1-goodmodel.yaml' removed.
      

---

    Code
      purrr::map(mod_checks_message[mod_files], "valid_file_status")
    Output
      $`hub-baseline/2022-10-08-hub-baseline.csv`
      <message/check_info>
      Message:
      Previously submitted model output file 'model-output/hub-baseline/2022-10-08-hub-baseline.csv' modified.
      
      $`team1-goodmodel/2022-10-15-team1-goodmodel.csv`
      <message/check_info>
      Message:
      Previously submitted model output file 'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv' removed.
      
      $`team1-goodmodel.yaml`
      <message/check_info>
      Message:
      Previously submitted model metadata file 'model-metadata/team1-goodmodel.yaml' removed.
      

# validate_pr handles errors in determining submission window & file renaming

    Code
      mod_checks_exec_error[[file_path]][["file_name"]]
    Output
      <error/check_error>
      Error:
      ! File name "2022-10-team1-goodmodel.csv" must be valid.  Could not correctly parse submission metadata.

---

    Code
      mod_checks_exec_error[[file_path]][["valid_file_status"]]
    Output
      <error/check_exec_error>
      Error:
      ! Could not check submission window for file "team1-goodmodel/2022-10-team1-goodmodel.csv". EXEC ERROR: Error in parse_file_name(file_path) : x File name '2022-10-team1-goodmodel' does not match expected pattern of [round_id]-[team_abbr]-[model_abbr]. Please consult documentation on file name requirements (<https://docs.hubverse.io/en/latest/user-guide/model-output.html#directory-structure>) for details.

