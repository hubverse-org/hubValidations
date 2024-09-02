# validate_model_file works

    Code
      str(validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"))
    Output
      List of 6
       $ file_exists    :List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name      :List of 4
        ..$ message       : chr "File name \"2022-10-08-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location  :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_location"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid :List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_valid_round_id"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format    :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_format"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ metadata_exists:List of 4
        ..$ message       : chr "Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_submission_metadata_file_exists"
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

# validate_model_file print method work [plain]

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Message
      v 2022-10-08-team1-goodmodel.csv: File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'.
      v 2022-10-08-team1-goodmodel.csv: File name "2022-10-08-team1-goodmodel.csv" is valid.
      v 2022-10-08-team1-goodmodel.csv: File directory name matches `model_id` metadata in file name.
      v 2022-10-08-team1-goodmodel.csv: `round_id` is valid.
      v 2022-10-08-team1-goodmodel.csv: File is accepted hub format.
      v 2022-10-08-team1-goodmodel.csv: Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message
      (x) 2022-10-15-team1-goodmodel.csv: File does not exist at path 'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv'.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv")
    Message
      v 2022-10-15-hub-baseline.csv: File exists at path 'model-output/team1-goodmodel/2022-10-15-hub-baseline.csv'.
      v 2022-10-15-hub-baseline.csv: File name "2022-10-15-hub-baseline.csv" is valid.
      x 2022-10-15-hub-baseline.csv: File directory name must match `model_id` metadata in file name.  File should be submitted to directory "hub-baseline" not "team1-goodmodel"
      v 2022-10-15-hub-baseline.csv: `round_id` is valid.
      v 2022-10-15-hub-baseline.csv: File is accepted hub format.
      v 2022-10-15-hub-baseline.csv: Metadata file exists at path 'model-metadata/hub-baseline.yml'.

# validate_model_file print method work [ansi]

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Message
      [1m[22m[32mv[39m 2022-10-08-team1-goodmodel.csv: File exists at path [34mmodel-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv[39m.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: File name [34m"2022-10-08-team1-goodmodel.csv"[39m is valid.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: File directory name matches `model_id` metadata in file name.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: `round_id` is valid.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: File is accepted hub format.
      [32mv[39m 2022-10-08-team1-goodmodel.csv: Metadata file exists at path [34mmodel-metadata/team1-goodmodel.yaml[39m.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message
      [1m[22m[31m(x)[39m 2022-10-15-team1-goodmodel.csv: File does not exist at path [34mmodel-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv[39m.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv")
    Message
      [1m[22m[32mv[39m 2022-10-15-hub-baseline.csv: File exists at path [34mmodel-output/team1-goodmodel/2022-10-15-hub-baseline.csv[39m.
      [32mv[39m 2022-10-15-hub-baseline.csv: File name [34m"2022-10-15-hub-baseline.csv"[39m is valid.
      [31mx[39m 2022-10-15-hub-baseline.csv: File directory name must match `model_id` metadata in file name.  File should be submitted to directory [34m"hub-baseline"[39m not [34m"team1-goodmodel"[39m
      [32mv[39m 2022-10-15-hub-baseline.csv: `round_id` is valid.
      [32mv[39m 2022-10-15-hub-baseline.csv: File is accepted hub format.
      [32mv[39m 2022-10-15-hub-baseline.csv: Metadata file exists at path [34mmodel-metadata/hub-baseline.yml[39m.

# validate_model_file print method work [unicode]

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Message
      ✔ 2022-10-08-team1-goodmodel.csv: File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'.
      ✔ 2022-10-08-team1-goodmodel.csv: File name "2022-10-08-team1-goodmodel.csv" is valid.
      ✔ 2022-10-08-team1-goodmodel.csv: File directory name matches `model_id` metadata in file name.
      ✔ 2022-10-08-team1-goodmodel.csv: `round_id` is valid.
      ✔ 2022-10-08-team1-goodmodel.csv: File is accepted hub format.
      ✔ 2022-10-08-team1-goodmodel.csv: Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message
      ⓧ 2022-10-15-team1-goodmodel.csv: File does not exist at path 'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv'.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv")
    Message
      ✔ 2022-10-15-hub-baseline.csv: File exists at path 'model-output/team1-goodmodel/2022-10-15-hub-baseline.csv'.
      ✔ 2022-10-15-hub-baseline.csv: File name "2022-10-15-hub-baseline.csv" is valid.
      ✖ 2022-10-15-hub-baseline.csv: File directory name must match `model_id` metadata in file name.  File should be submitted to directory "hub-baseline" not "team1-goodmodel"
      ✔ 2022-10-15-hub-baseline.csv: `round_id` is valid.
      ✔ 2022-10-15-hub-baseline.csv: File is accepted hub format.
      ✔ 2022-10-15-hub-baseline.csv: Metadata file exists at path 'model-metadata/hub-baseline.yml'.

# validate_model_file print method work [fancy]

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Message
      [1m[22m[32m✔[39m 2022-10-08-team1-goodmodel.csv: File exists at path [34mmodel-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv[39m.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: File name [34m"2022-10-08-team1-goodmodel.csv"[39m is valid.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: File directory name matches `model_id` metadata in file name.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: `round_id` is valid.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: File is accepted hub format.
      [32m✔[39m 2022-10-08-team1-goodmodel.csv: Metadata file exists at path [34mmodel-metadata/team1-goodmodel.yaml[39m.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message
      [1m[22m[31mⓧ[39m 2022-10-15-team1-goodmodel.csv: File does not exist at path [34mmodel-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv[39m.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv")
    Message
      [1m[22m[32m✔[39m 2022-10-15-hub-baseline.csv: File exists at path [34mmodel-output/team1-goodmodel/2022-10-15-hub-baseline.csv[39m.
      [32m✔[39m 2022-10-15-hub-baseline.csv: File name [34m"2022-10-15-hub-baseline.csv"[39m is valid.
      [31m✖[39m 2022-10-15-hub-baseline.csv: File directory name must match `model_id` metadata in file name.  File should be submitted to directory [34m"hub-baseline"[39m not [34m"team1-goodmodel"[39m
      [32m✔[39m 2022-10-15-hub-baseline.csv: `round_id` is valid.
      [32m✔[39m 2022-10-15-hub-baseline.csv: File is accepted hub format.
      [32m✔[39m 2022-10-15-hub-baseline.csv: Metadata file exists at path [34mmodel-metadata/hub-baseline.yml[39m.

