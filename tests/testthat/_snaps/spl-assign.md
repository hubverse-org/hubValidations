# the sample checks still validate compound_taskid_set names without building the grid

    Code
      check_tbl_spl_compound_tid(tbl, "2022-10-22",
        "team-model/2022-10-22-team-model.csv", hub_path, compound_taskid_set = list(
          c("target", "locatoin"), c("target", "location")))
    Condition
      Error in `check_tbl_spl_compound_tid()`:
      x "locatoin" is not valid task ID.
      i The `compound_taskid_set` must be a subset of "reference_date", "target", "horizon", and "location".

# the sample checks still validate compound_taskid_set length without building the grid

    Code
      check_tbl_spl_n(tbl, "2022-10-22", "team-model/2022-10-22-team-model.csv",
        hub_path, compound_taskid_set = list(c("target", "location")))
    Condition
      Error in `check_tbl_spl_n()`:
      x `compound_taskid_set` must have one element for each modeling task in the round.
      i The round has 2 modeling tasks but `compound_taskid_set` has 1.

