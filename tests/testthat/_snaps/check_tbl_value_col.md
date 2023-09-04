# check_tbl_value_col works

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <message/check_success>
      Message:
      Values in column `value` all valid with respect to modeling task config.

---

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Values in column `value` are not all valid with respect to modeling task config.  Values 196.83, 367.89, 244.85, 427.975, 310.9, 499.9, 394.8, 461.85, 629.7, 534.6, 599.75, 727.5, 669.7, 725.562456357284, 801.689162048122, 800.239938093011, 915.5, 949.59, ..., 2775.56600111008, and 2139.07 cannot be coerced to expected data type "integer" for output type "quantile".

# check_tbl_value_col errors correctly

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Values in column `value` are not all valid with respect to modeling task config.  Value "fail" cannot be coerced to expected data type "integer" for output type "quantile".Values in column `value` are not all valid with respect to modeling task config.  Value -6 is smaller than allowed minimum value 0 for output type "quantile".

---

    Code
      check_tbl_value_col(tbl, round_id, file_path, hub_path)
    Output
      <warning/check_failure>
      Warning:
      Values in column `value` are not all valid with respect to modeling task config.  Value "fail" cannot be coerced to expected data type "integer" for output type "quantile".Values in column `value` are not all valid with respect to modeling task config.  Values "196.83", "244.85", "310.9", "499.9", "394.8", "461.85", "629.7", "534.6", "599.75", "727.5", "669.7", "725.562456357284", "801.689162048122", "800.239938093011", "915.5", "949.59", "938.67", "962.03", ..., "2775.56600111008", and "2139.07" cannot be coerced to expected data type "integer" for output type "quantile".Values in column `value` are not all valid with respect to modeling task config.  Value -6 is smaller than allowed minimum value 0 for output type "quantile".

