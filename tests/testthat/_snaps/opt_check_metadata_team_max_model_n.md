# opt_check_metadata_team_max_model_n works

    Code
      opt_check_metadata_team_max_model_n(hub_path = hub_path, file_path = "hub-baseline.yml")
    Output
      <message/check_success>
      Message:
      Maximum number of models per team (2) not exceeded.

---

    Code
      opt_check_metadata_team_max_model_n(hub_path = hub_path, file_path = "hub-baseline.yml",
        n_max = 1L)
    Output
      <error/check_failure>
      Error:
      ! Maximum number of models per team (1) exceeded.  Team "hub" has submitted valid metadata for 2 models: "baseline" and "ensemble".

