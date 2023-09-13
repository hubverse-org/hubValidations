# check_valid_round_id works

    Code
      check_valid_round_id("2022-10-29", file_path, hub_path)
    Output
      <message/check_success>
      Message:
      `round_id` is valid.

---

    Code
      check_valid_round_id("invalid-round_id", file_path, hub_path)
    Output
      <error/check_error>
      Error:
      ! `round_id` must be valid.  Must be one of "2022-10-01", "2022-10-08", "2022-10-15", "2022-10-22", and "2022-10-29", NOT "invalid-round_id"

