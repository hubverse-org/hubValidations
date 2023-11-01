# opt_check_tbl_counts_lt_popn works

    Code
      opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets)
    Output
      <message/check_success>
      Message:
      Target counts are less than location population size.

---

    Code
      opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets)
    Output
      <warning/check_failure>
      Warning:
      Target counts must be less than location population size.  Affected rows: 1 and 2.

# opt_check_tbl_counts_lt_popn fails correctly

    Code
      opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, targets = targets)
    Condition
      Error in `assert_target_keys()`:
      ! Target does not match any round target keys.

---

    Code
      opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, popn_file_path = "random/path.csv")
    Condition
      Error in `opt_check_tbl_counts_lt_popn()`:
      ! File not found at 'random/path.csv'

---

    Code
      opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, location_col = "random_col")
    Condition
      Error in `opt_check_tbl_counts_lt_popn()`:
      ! Assertion on 'location_col' failed: Must be element of set {'forecast_date','target_end_date','horizon','target','location','output_type','output_type_id','value'}, but is 'random_col'.

---

    Code
      opt_check_tbl_counts_lt_popn(tbl, file_path, hub_path, popn_col = "random_col")
    Condition
      Error in `opt_check_tbl_counts_lt_popn()`:
      ! Assertion on 'popn_col' failed: Must be element of set {'abbreviation','location','location_name','population','','count_rate1','count_rate2','count_rate2p5','count_rate3','count_rate4','count_rate5'}, but is 'random_col'.

