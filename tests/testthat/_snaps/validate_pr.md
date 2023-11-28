# validate_pr works on valid PR

    Code
      str(checks)
    Output
      List of 19
       $ valid_config      :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "valid_sb_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
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
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

# validate_pr works on invalid PR

    Code
      str(checks)
    Output
      Classes 'hub_validations', 'list'  hidden list of 12
       $ valid_config      :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "invalid_sb_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/hub-baseline/2022-10-22-hub-baseline.parquet'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2022-10-22-hub-baseline.parquet\" is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 6
        ..$ message       : chr "Column names must be consistent with expected round task IDs and std column names. \n Expected column \"age_gro"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

# validate_pr flags modifications and deletions in PR

    Code
      str(checks)
    Output
      Classes 'hub_validations', 'list'  hidden list of 28
       $ valid_config      :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "mod_del_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $                   :List of 6
        ..$ message       : chr "Previously submitted model output files must not be modified. \n 'model-output/hub-baseline/2022-10-08-hub-base"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr ".f"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...
       $                   :List of 6
        ..$ message       : chr "Previously submitted model output files must not be removed. \n 'model-output/team1-goodmodel/2022-10-15-team1-"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
        ..$ call          : chr ".f"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...
       $                   :List of 6
        ..$ message       : chr "Previously submitted model metadata files must not be removed. \n 'model-metadata/team1-goodmodel.yaml' removed."
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel.yaml"
        ..$ call          : chr ".f"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/hub-baseline/2022-10-08-hub-baseline.csv'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2022-10-08-hub-baseline.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read         :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col:List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id   :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id    :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames          :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types         :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals        :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ rows_unique       :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals          :List of 5
        ..$ message       : chr "Required task ID/output type/output type ID combinations all present.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
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
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc:List of 5
        ..$ message       : chr "Values in `value` column are non-decreasing as output_type_ids increase for all unique task ID\n    value/outpu"| __truncated__
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1    :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ file_exists       :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name         :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location     :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid    :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format       :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists   :List of 6
        ..$ message       : chr "Metadata file does not exist at path 'model-metadata/team1-goodmodel.yml' or\n                                 "| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

