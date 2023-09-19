# validate_model_metadata works

    Code
      str(validate_model_metadata(hub_path, file_path))
    Output
      Classes 'hub_validations', 'list'  hidden list of 5
       $ metadata_schema_exists :List of 4
        ..$ message       : chr "File exists at path 'hub-config/model-metadata-schema.json'. \n "
        ..$ where         : chr "model-metadata-schema.json"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_exists   :List of 4
        ..$ message       : chr "File exists at path 'model-metadata/team1-goodmodel.yaml'. \n "
        ..$ where         : chr "team1-goodmodel.yaml"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_ext      :List of 4
        ..$ message       : chr "Metadata file extension is \"yml\" or \"yaml\". \n "
        ..$ where         : chr "team1-goodmodel.yaml"
        ..$ call          : chr "check_metadata_file_ext"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_location :List of 4
        ..$ message       : chr "Metadata file directory name matches \"model-metadata\". \n "
        ..$ where         : chr "team1-goodmodel.yaml"
        ..$ call          : chr "check_metadata_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_matches_schema:List of 6
        ..$ message       : chr "Metadata file contents must be consistent with schema specifications. \n - must have required property 'model_d"| __truncated__
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "team1-goodmodel.yaml"
        ..$ call          : chr "check_metadata_matches_schema"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

---

    Code
      str(validate_model_metadata(hub_path, file_path))
    Output
      List of 6
       $ metadata_schema_exists :List of 4
        ..$ message       : chr "File exists at path 'hub-config/model-metadata-schema.json'. \n "
        ..$ where         : chr "model-metadata-schema.json"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_exists   :List of 4
        ..$ message       : chr "File exists at path 'model-metadata/hub-baseline.yml'. \n "
        ..$ where         : chr "hub-baseline.yml"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_ext      :List of 4
        ..$ message       : chr "Metadata file extension is \"yml\" or \"yaml\". \n "
        ..$ where         : chr "hub-baseline.yml"
        ..$ call          : chr "check_metadata_file_ext"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_location :List of 4
        ..$ message       : chr "Metadata file directory name matches \"model-metadata\". \n "
        ..$ where         : chr "hub-baseline.yml"
        ..$ call          : chr "check_metadata_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_matches_schema:List of 4
        ..$ message       : chr "Metadata file contents are consistent with schema specifications. \n "
        ..$ where         : chr "hub-baseline.yml"
        ..$ call          : chr "check_metadata_matches_schema"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_name     :List of 4
        ..$ message       : chr "Metadata file name matches the `model_id` specified within the metadata file. \n "
        ..$ where         : chr "hub-baseline.yml"
        ..$ call          : chr "check_metadata_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(validate_model_metadata(hub_path, file_path))
    Output
      Classes 'hub_validations', 'list'  hidden list of 5
       $ metadata_schema_exists :List of 4
        ..$ message       : chr "File exists at path 'hub-config/model-metadata-schema.json'. \n "
        ..$ where         : chr "model-metadata-schema.json"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_exists   :List of 4
        ..$ message       : chr "File exists at path 'model-metadata/hub-baseline-no-abbrs-or-model_id.yml'. \n "
        ..$ where         : chr "hub-baseline-no-abbrs-or-model_id.yml"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_ext      :List of 4
        ..$ message       : chr "Metadata file extension is \"yml\" or \"yaml\". \n "
        ..$ where         : chr "hub-baseline-no-abbrs-or-model_id.yml"
        ..$ call          : chr "check_metadata_file_ext"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_location :List of 4
        ..$ message       : chr "Metadata file directory name matches \"model-metadata\". \n "
        ..$ where         : chr "hub-baseline-no-abbrs-or-model_id.yml"
        ..$ call          : chr "check_metadata_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_matches_schema:List of 6
        ..$ message       : chr "Metadata file contents must be consistent with schema specifications. \n - must have required property 'model_abbr' ."
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "hub-baseline-no-abbrs-or-model_id.yml"
        ..$ call          : chr "check_metadata_matches_schema"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

---

    Code
      str(validate_model_metadata(hub_path, file_path))
    Output
      Classes 'hub_validations', 'list'  hidden list of 2
       $ metadata_schema_exists:List of 4
        ..$ message       : chr "File exists at path 'hub-config/model-metadata-schema.json'. \n "
        ..$ where         : chr "model-metadata-schema.json"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_file_exists  :List of 6
        ..$ message       : chr "File does not exist at path 'model-metadata/2020-10-06-random-path.csv'. \n "
        ..$ trace         : NULL
        ..$ parent        : NULL
        ..$ where         : chr "2020-10-06-random-path.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_error" "hub_check" "rlang_error" "error" ...

