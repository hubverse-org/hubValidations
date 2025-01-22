# validate_pr works on valid PR

    Code
      str(checks)
    Output
      List of 25
       $ valid_config           :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "valid_sb_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists            :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name              :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location          :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid         :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format            :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n                 :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists        :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read              :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col     :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id        :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id         :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames               :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types              :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals             :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals   :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique            :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals               :List of 5
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
       $ value_col_valid        :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc     :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1         :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set:List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid       :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid   :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n                  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

# validate_pr works on invalid PR

    Code
      str(invalid_checks)
    Output
      Classes 'hub_validations', 'list'  hidden list of 13
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
       $ file_n            :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-22-hub-baseline.parquet"
        ..$ call          : chr "check_file_n"
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
      str(mod_checks_error)
    Output
      List of 52
       $ valid_config             :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "mod_del_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ model_output_mod         :List of 6
        ..$ message       : chr "Previously submitted model output files must not be modified. \n 'model-output/hub-baseline/2022-10-08-hub-base"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...
       $ model_output_mod_1       :List of 6
        ..$ message       : chr "Previously submitted model output files must not be removed. \n 'model-output/team1-goodmodel/2022-10-15-team1-"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...
       $ model_metadata_mod       :List of 6
        ..$ message       : chr "Previously submitted model metadata files must not be removed. \n 'model-metadata/team1-goodmodel.yaml' removed."
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel.yaml"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...
       $ file_exists              :List of 4
        ..$ message       : chr "File exists at path 'model-output/hub-baseline/2022-10-08-hub-baseline.csv'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name                :List of 4
        ..$ message       : chr "File name \"2022-10-08-hub-baseline.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location            :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid           :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format              :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n                   :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists          :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read                :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col       :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id          :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id           :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames                 :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types                :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals               :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals     :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique              :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals                 :List of 5
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
       $ value_col_valid          :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc       :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1           :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid         :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid     :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n                    :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ file_exists_1            :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name_1              :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location_1          :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid_1         :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format_1            :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n_1                 :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists_1        :List of 6
        ..$ message       : chr "Metadata file does not exist at path 'model-metadata/team1-goodmodel.yml' or\n                                 "| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ file_read_1              :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col_1     :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id_1        :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id_1         :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames_1               :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types_1              :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals_1             :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals_1   :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique_1            :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals_1               :List of 5
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
       $ value_col_valid_1        :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc_1     :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1_1         :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set_1:List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid_1       :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid_1   :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n_1                  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(mod_checks_warn)
    Output
      List of 52
       $ valid_config             :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "mod_del_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ model_output_mod         :List of 6
        ..$ message       : chr "Previously submitted model output files must not be modified. \n 'model-output/hub-baseline/2022-10-08-hub-base"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ model_output_mod_1       :List of 6
        ..$ message       : chr "Previously submitted model output files must not be removed. \n 'model-output/team1-goodmodel/2022-10-15-team1-"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ model_metadata_mod       :List of 6
        ..$ message       : chr "Previously submitted model metadata files must not be removed. \n 'model-metadata/team1-goodmodel.yaml' removed."
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel.yaml"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ file_exists              :List of 4
        ..$ message       : chr "File exists at path 'model-output/hub-baseline/2022-10-08-hub-baseline.csv'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name                :List of 4
        ..$ message       : chr "File name \"2022-10-08-hub-baseline.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location            :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid           :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format              :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n                   :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists          :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read                :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col       :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id          :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id           :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames                 :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types                :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals               :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals     :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique              :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals                 :List of 5
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
       $ value_col_valid          :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc       :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1           :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid         :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid     :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n                    :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ file_exists_1            :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name_1              :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location_1          :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid_1         :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format_1            :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n_1                 :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists_1        :List of 6
        ..$ message       : chr "Metadata file does not exist at path 'model-metadata/team1-goodmodel.yml' or\n                                 "| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ file_read_1              :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col_1     :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id_1        :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id_1         :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames_1               :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types_1              :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals_1             :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals_1   :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique_1            :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals_1               :List of 5
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
       $ value_col_valid_1        :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc_1     :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1_1         :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set_1:List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid_1       :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid_1   :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n_1                  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(mod_checks_message)
    Output
      List of 52
       $ valid_config             :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "mod_del_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ model_output_mod         :List of 4
        ..$ message       : chr "Previously submitted model output file\n          'model-output/hub-baseline/2022-10-08-hub-baseline.csv' modified."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ model_output_mod_1       :List of 4
        ..$ message       : chr "Previously submitted model output file\n          'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv' removed."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ model_metadata_mod       :List of 4
        ..$ message       : chr "Previously submitted model metadata file\n          'model-metadata/team1-goodmodel.yaml' removed."
        ..$ where         : 'fs_path' chr "team1-goodmodel.yaml"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ file_exists              :List of 4
        ..$ message       : chr "File exists at path 'model-output/hub-baseline/2022-10-08-hub-baseline.csv'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name                :List of 4
        ..$ message       : chr "File name \"2022-10-08-hub-baseline.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location            :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid           :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format              :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n                   :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists          :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read                :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col       :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id          :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id           :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames                 :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types                :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals               :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals     :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique              :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals                 :List of 5
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
       $ value_col_valid          :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc       :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1           :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid         :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid     :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n                    :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ file_exists_1            :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name_1              :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location_1          :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid_1         :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format_1            :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n_1                 :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists_1        :List of 6
        ..$ message       : chr "Metadata file does not exist at path 'model-metadata/team1-goodmodel.yml' or\n                                 "| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ file_read_1              :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col_1     :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id_1        :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id_1         :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames_1               :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types_1              :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals_1             :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals_1   :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique_1            :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals_1               :List of 5
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
       $ value_col_valid_1        :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc_1     :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1_1         :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set_1:List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid_1       :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid_1   :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n_1                  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(mod_checks_none)
    Output
      List of 49
       $ valid_config             :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "mod_del_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists              :List of 4
        ..$ message       : chr "File exists at path 'model-output/hub-baseline/2022-10-08-hub-baseline.csv'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name                :List of 4
        ..$ message       : chr "File name \"2022-10-08-hub-baseline.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location            :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid           :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format              :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n                   :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists          :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read                :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col       :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id          :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id           :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames                 :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types                :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals               :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals     :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique              :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals                 :List of 5
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
       $ value_col_valid          :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc       :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1           :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid         :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid     :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n                    :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ file_exists_1            :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name_1              :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location_1          :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid_1         :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format_1            :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n_1                 :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists_1        :List of 6
        ..$ message       : chr "Metadata file does not exist at path 'model-metadata/team1-goodmodel.yml' or\n                                 "| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ file_read_1              :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col_1     :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id_1        :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id_1         :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames_1               :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types_1              :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals_1             :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals_1   :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique_1            :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals_1               :List of 5
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
       $ value_col_valid_1        :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc_1     :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1_1         :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set_1:List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid_1       :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid_1   :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n_1                  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(mod_checks_in_window)
    Output
      List of 51
       $ valid_config             :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "mod_del_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ model_output_mod         :List of 6
        ..$ message       : chr "Previously submitted model output files must not be removed. \n 'model-output/team1-goodmodel/2022-10-15-team1-"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-15-team1-goodmodel.csv"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...
       $ model_metadata_mod       :List of 6
        ..$ message       : chr "Previously submitted model metadata files must not be removed. \n 'model-metadata/team1-goodmodel.yaml' removed."
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel.yaml"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...
       $ file_exists              :List of 4
        ..$ message       : chr "File exists at path 'model-output/hub-baseline/2022-10-08-hub-baseline.csv'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name                :List of 4
        ..$ message       : chr "File name \"2022-10-08-hub-baseline.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location            :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid           :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format              :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n                   :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists          :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read                :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col       :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id          :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id           :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames                 :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types                :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals               :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals     :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique              :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals                 :List of 5
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
       $ value_col_valid          :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc       :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1           :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid         :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid     :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n                    :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "hub-baseline/2022-10-08-hub-baseline.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ file_exists_1            :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name_1              :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location_1          :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid_1         :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format_1            :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n_1                 :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists_1        :List of 6
        ..$ message       : chr "Metadata file does not exist at path 'model-metadata/team1-goodmodel.yml' or\n                                 "| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_failure" "hub_check" "rlang_error" "error" ...
       $ file_read_1              :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col_1     :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id_1        :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id_1         :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames_1               :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types_1              :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals_1             :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals_1   :List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique_1            :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals_1               :List of 5
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
       $ value_col_valid_1        :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc_1     :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1_1         :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_taskid_set_1:List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_taskid_set` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_taskid_set"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_compound_tid_1       :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_non_compound_tid_1   :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_non_compound_tid` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_non_compound_tid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ spl_n_1                  :List of 4
        ..$ message       : chr "No v3 samples found in model output data to check. Skipping `check_tbl_spl_n` check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_spl_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

# validate_pr handles errors in determining submission window & file renaming

    Code
      str(mod_checks_exec_error[1:5])
    Output
      List of 5
       $ valid_config    :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "mod_exec_error_hub"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ model_output_mod:List of 6
        ..$ message       : chr "Could not check submission window for file \"team1-goodmodel/2022-10-team1-goodmodel.csv\". EXEC ERROR: Error i"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-team1-goodmodel.csv"
        ..$ call          : chr "check_pr_modf_del_file"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_exec_error" "hub_check" "rlang_error" "error" ...
       $ file_exists     :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name       :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location   :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...

# validate_pr works on valid PR using v2.0.0 schema and old orgname

    Code
      str(checks)
    Output
      List of 21
       $ valid_config        :List of 4
        ..$ message       : chr "All hub config files are valid. \n "
        ..$ where         : chr "valid_sb_hub-old"
        ..$ call          : chr "check_config_hub_valid"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_exists         :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-22-team1-goodmodel.csv'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name           :List of 4
        ..$ message       : chr "File name \"2022-10-22-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location       :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid      :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format         :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_n              :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_n"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists     :List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_read           :List of 4
        ..$ message       : chr "File could be read successfully. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_file_read"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_round_id_col  :List of 4
        ..$ message       : chr "`round_id_col` name is valid. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ unique_round_id     :List of 4
        ..$ message       : chr "`round_id` column \"origin_date\" contains a single, unique round ID value. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_unique_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ match_round_id      :List of 4
        ..$ message       : chr "All `round_id_col` \"origin_date\" values match submission `round_id` from file name. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_match_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ colnames            :List of 4
        ..$ message       : chr "Column names are consistent with expected round task IDs and std column names. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_colnames"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ col_types           :List of 4
        ..$ message       : chr "Column data types match hub schema. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_col_types"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ valid_vals          :List of 5
        ..$ message       : chr "`tbl` contains valid values/value combinations.  \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_values"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ derived_task_id_vals:List of 4
        ..$ message       : chr "No derived task IDs to check. Skipping derived task ID value check."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_derived_task_id_vals"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       $ rows_unique         :List of 4
        ..$ message       : chr "All combinations of task ID column/`output_type`/`output_type_id` values are unique. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_rows_unique"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ req_vals            :List of 5
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
       $ value_col_valid     :List of 4
        ..$ message       : chr "Values in column `value` all valid with respect to modeling task config. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_non_desc  :List of 5
        ..$ message       : chr "Quantile or cdf `value` values increase when ordered by `output_type_id`. \n "
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ error_tbl     : NULL
        ..$ call          : chr "check_tbl_value_col_ascending"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ value_col_sum1      :List of 4
        ..$ message       : chr "No pmf output types to check for sum of 1. Check skipped."
        ..$ where         : 'fs_path' chr "team1-goodmodel/2022-10-22-team1-goodmodel.csv"
        ..$ call          : chr "check_tbl_value_col_sum1"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_info" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

