# check_tbl_value_col_ascending works

    Code
      check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
    Output
      <message/check_success>
      Message:
      Quantile or cdf `value` values increase when ordered by `output_type_id`.

---

    Code
      check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
    Output
      <message/check_success>
      Message:
      Quantile or cdf `value` values increase when ordered by `output_type_id`.

# check_tbl_value_col_ascending works when output type IDs not ordered

    Code
      check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
    Output
      <message/check_success>
      Message:
      Quantile or cdf `value` values increase when ordered by `output_type_id`.

# check_tbl_value_col_ascending errors correctly

    Code
      res
    Output
      <error/check_failure>
      Error:
      ! Quantile or cdf `value` values do not all increase when ordered by `output_type_id`.  See `error_tbl` attribute for details.

# check_tbl_value_col_ascending skips correctly

    Code
      check_tbl_value_col_ascending(tbl, file_path, hub_path, file_meta$round_id)
    Output
      <message/check_info>
      Message:
      No quantile or cdf output types to check for non-descending values. Check skipped.

