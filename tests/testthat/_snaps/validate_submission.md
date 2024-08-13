# validate_submission works

    Code
      str(validate_submission(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        skip_submit_window_check = TRUE, skip_check_config = TRUE))
    Output
      List of 18
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2022-10-08-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ missing       : tibble [0 x 6] (S3: tbl_df/tbl/data.frame)
        .. ..$ origin_date   : chr(0) 
        .. ..$ target        : chr(0) 
        .. ..$ horizon       : chr(0) 
        .. ..$ location      : chr(0) 
        .. ..$ output_type   : chr(0) 
        .. ..$ output_type_id: chr(0) 
        ..$ call          : chr "check_tbl_values_required"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_valid   :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(validate_submission(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv",
        skip_submit_window_check = TRUE, skip_check_config = TRUE))
    Output
      Classes 'hub_validations', 'list'  hidden list of 1
       $ file_exists:List of 6
        ..$ message       : chr "File does not exist at path 'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv'. \n "
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

---

    Code
      str(validate_submission(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv",
        skip_submit_window_check = TRUE, skip_check_config = TRUE))
    Output
      Classes 'hub_validations', 'list'  hidden list of 10
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-15-hub-baseline.csv'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2022-10-15-hub-baseline.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name must match `model_id`\n                                           metadata in file name. \n"| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 6
        ..$ message       : chr "All `round_id_col` \"origin_date\" values must match submission `round_id` from file name. \n `round_id` \n    "| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "team1-goodmodel/2022-10-15-hub-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

---

    Code
      str(validate_submission(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        round_id_col = "random_col", skip_submit_window_check = TRUE,
        skip_check_config = TRUE))
    Output
      List of 9
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2022-10-08-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name must be valid. \n Must be one of\n                                      \"origin_date\", \""| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id_col` name must be valid. \n Must be one of\n                                      \"origin_date\", \""| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_warning" "warning" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(validate_submission(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        skip_submit_window_check = TRUE))
    Output
      List of 19
       $ valid_config      :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "simple"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2022-10-08-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ missing       : tibble [0 x 6] (S3: tbl_df/tbl/data.frame)
        .. ..$ origin_date   : chr(0) 
        .. ..$ target        : chr(0) 
        .. ..$ horizon       : chr(0) 
        .. ..$ location      : chr(0) 
        .. ..$ output_type   : chr(0) 
        .. ..$ output_type_id: chr(0) 
        ..$ call          : chr "check_tbl_values_required"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_valid   :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

# validate_submission submission within window works

    Code
      str(validate_submission(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")[[
        "submission_time"]])
    Output
      List of 4
       $ message       : chr "Submission time is within accepted submission window for round. \n "
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ call          : chr "check_submission_time"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

# validate_submission submission outside window fails correctly

    Code
      str(validate_submission(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")[[
        "submission_time"]])
    Output
      List of 4
       $ message       : chr "Submission time must be within accepted submission window for round. \n Current time \"2023-10-08 18:01:00 UTC\"| __truncated__
       $ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
       $ call          : chr "check_submission_time"
       $ use_cli_format: logi TRUE
       - attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_warning" "warning" ...

# validate_submission csv file read in and validated according to schema.

    Code
      str(validate_submission(hub_path = test_path("testdata/hub"), file_path = "hub-baseline/2023-04-24-hub-baseline.csv",
      skip_submit_window_check = TRUE))
    Output
      List of 19
       $ valid_config      :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'forecasts/hub-baseline/2023-04-24-hub-baseline.csv'. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2023-04-24-hub-baseline.csv\" is valid. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"forecast_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"forecast_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ missing       : tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
        .. ..$ forecast_date  : chr(0) 
        .. ..$ target_end_date: chr(0) 
        .. ..$ horizon        : chr(0) 
        .. ..$ target         : chr(0) 
        .. ..$ location       : chr(0) 
        .. ..$ output_type    : chr(0) 
        .. ..$ output_type_id : chr(0) 
        ..$ call          : chr "check_tbl_values_required"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_valid   :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : chr "hub-baseline/2023-04-24-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

# File containing task ID with all null properties validate correctly

    Code
      str(validate_submission(hub_path = test_path("testdata/hub-nul"), file_path = "team-model/2023-11-26-team-model.parquet",
      skip_submit_window_check = TRUE))
    Output
      List of 19
       $ valid_config      :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "hub-nul"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/team-model/2023-11-26-team-model.parquet'. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2023-11-26-team-model.parquet\" is valid. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team-model.yaml'. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ missing       : tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
        .. ..$ origin_date   : chr(0) 
        .. ..$ target        : chr(0) 
        .. ..$ horizon       : chr(0) 
        .. ..$ location      : chr(0) 
        .. ..$ age_group     : chr(0) 
        .. ..$ output_type   : chr(0) 
        .. ..$ output_type_id: chr(0) 
        ..$ call          : chr "check_tbl_values_required"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_valid   :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : chr "team-model/2023-11-26-team-model.parquet"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(validate_submission(hub_path = test_path("testdata/hub-nul"), file_path = "team-model/2023-11-19-team-model.parquet",
      skip_submit_window_check = TRUE))
    Output
      List of 19
       $ valid_config      :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "hub-nul"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/team-model/2023-11-19-team-model.parquet'. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2023-11-19-team-model.parquet\" is valid. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team-model.yaml'. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ missing       : tibble [0 x 7] (S3: tbl_df/tbl/data.frame)
        .. ..$ origin_date   : chr(0) 
        .. ..$ target        : chr(0) 
        .. ..$ horizon       : chr(0) 
        .. ..$ location      : chr(0) 
        .. ..$ age_group     : chr(0) 
        .. ..$ output_type   : chr(0) 
        .. ..$ output_type_id: chr(0) 
        ..$ call          : chr "check_tbl_values_required"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_valid   :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : chr "team-model/2023-11-19-team-model.parquet"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

# validate_submission works with v3 samples.

    Code
      v$spl_compound_taskid_set$compound_taskid_set
    Output
      $`1`
      NULL
      
      $`2`
      [1] "reference_date"  "horizon"         "location"        "variant"        
      [5] "target_end_date"
      

---

    Code
      v_rl$spl_compound_taskid_set$compound_taskid_set
    Output
      $`1`
      NULL
      
      $`2`
      [1] "reference_date" "location"      
      

---

    Code
      v_rh$spl_compound_taskid_set$compound_taskid_set
    Output
      $`1`
      NULL
      
      $`2`
      [1] "reference_date"  "horizon"         "target_end_date"
      

# validate_submission handles overriding output type id data type correctly.

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = "Tm-Md/2023-11-11-Tm-Md.parquet",
      skip_submit_window_check = TRUE)[["col_types"]]
    Output
      <warning/check_failure>
      Warning:
      Column data types do not match hub schema.  `output_type_id` should be "character" not "double".

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = "Tm-Md/2023-11-11-Tm-Md.parquet",
      skip_submit_window_check = TRUE, output_type_id_datatype = "double")[[
        "col_types"]]
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = "Tm-Md/2023-11-11-Tm-Md.parquet",
      skip_submit_window_check = TRUE, output_type_id_datatype = "auto")[[
        "col_types"]]
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = "Tm-Md/2023-11-11-Tm-Md.parquet",
      skip_submit_window_check = TRUE, output_type_id_datatype = "character")[[
        "col_types"]]
    Output
      <warning/check_failure>
      Warning:
      Column data types do not match hub schema.  `output_type_id` should be "character" not "double".

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = "Tm-Md/2023-11-18-Tm-Md.parquet",
      skip_submit_window_check = TRUE)[["col_types"]]
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = "Tm-Md/2023-11-18-Tm-Md.parquet",
      skip_submit_window_check = TRUE, output_type_id_datatype = "double")[[
        "col_types"]]
    Output
      <warning/check_failure>
      Warning:
      Column data types do not match hub schema.  `output_type_id` should be "double" not "character".

---

    Code
      validate_submission(hub_path = test_path("testdata/hub-it"), file_path = "Tm-Md/2023-11-18-Tm-Md.parquet",
      skip_submit_window_check = TRUE, output_type_id_datatype = "character")[[
        "col_types"]]
    Output
      <message/check_success>
      Message:
      Column data types match hub schema.

