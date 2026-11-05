# check_tbl_spl_ids fails sample IDs that are not non-negative integers (#406)

    Code
      result
    Output
      <error/check_error>
      Error:
      ! Sample `output_type_id`s do not match the required sample ID format.  mt 2: sample IDs "s1", "1.5", "1.0", "1e3", "+1", " 1", "01", "-1", and "s{id1}" are not non-negative integers. Integer sample IDs must contain digits only, without leading zeros. See `errors` attribute for details.

# check_tbl_spl_ids fails character sample IDs that are too long or contain disallowed characters (#406)

    Code
      result
    Output
      <error/check_error>
      Error:
      ! Sample `output_type_id`s do not match the required sample ID format.  mt 1: sample IDs "AL01_run-sample1" and "CA03:run-sample1" are longer than the `max_length` of 15 and sample IDs "CA02{x}" and "CA03:run-sample1" contain characters other than ASCII letters, digits, "_", "-" and ".". See `errors` attribute for details.

# check_tbl_spl_ids fails sample rows with a missing or empty output_type_id (#406)

    Code
      result
    Output
      <error/check_error>
      Error:
      ! Sample `output_type_id`s do not match the required sample ID format.  mt 2: 6 sample rows have no `output_type_id` and sample ID "s3" is not a non-negative integer. Integer sample IDs must contain digits only, without leading zeros. See `errors` attribute for details.

