# validate_model_file works

    Code
      str(validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"))
    Output
      List of 5
       $ file_exists   :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name     :List of 4
        ..$ message       : chr "File name \"2022-10-08-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid:List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format   :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv"))
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

