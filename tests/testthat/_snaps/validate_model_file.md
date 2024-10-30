# validate_model_file works

    Code
      str(validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"))
    Output
      List of 7
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
       $ file_n         :List of 4
        ..$ message       : chr "Number of accepted model output files per round met.  \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_n"
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
      
      -- 2022-10-08-team1-goodmodel.csv ----
      
      v [file_exists]: File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'.
      v [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
      v [file_location]: File directory name matches `model_id` metadata in file name.
      v [round_id_valid]: `round_id` is valid.
      v [file_format]: File is accepted hub format.
      v [file_n]: Number of accepted model output files per round met.
      v [metadata_exists]: Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message
      
      -- 2022-10-15-team1-goodmodel.csv ----
      
      (x) [file_exists]: File does not exist at path 'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv'.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv")
    Message
      
      -- 2022-10-15-hub-baseline.csv ----
      
      v [file_exists]: File exists at path 'model-output/team1-goodmodel/2022-10-15-hub-baseline.csv'.
      v [file_name]: File name "2022-10-15-hub-baseline.csv" is valid.
      x [file_location]: File directory name must match `model_id` metadata in file name.  File should be submitted to directory "hub-baseline" not "team1-goodmodel"
      v [round_id_valid]: `round_id` is valid.
      v [file_format]: File is accepted hub format.
      v [file_n]: Number of accepted model output files per round met.
      v [metadata_exists]: Metadata file exists at path 'model-metadata/hub-baseline.yml'.

# validate_model_file print method work [ansi]

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Message
      
      [35m-- [4m[1m2022-10-08-team1-goodmodel.csv[22m[24m ----[39m
      
      [1m[22m[32mv[39m [90m[file_exists][39m: File exists at path [34mmodel-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv[39m.
      [32mv[39m [90m[file_name][39m: File name [34m"2022-10-08-team1-goodmodel.csv"[39m is valid.
      [32mv[39m [90m[file_location][39m: File directory name matches `model_id` metadata in file name.
      [32mv[39m [90m[round_id_valid][39m: `round_id` is valid.
      [32mv[39m [90m[file_format][39m: File is accepted hub format.
      [32mv[39m [90m[file_n][39m: Number of accepted model output files per round met.
      [32mv[39m [90m[metadata_exists][39m: Metadata file exists at path [34mmodel-metadata/team1-goodmodel.yaml[39m.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message
      
      [35m-- [4m[1m2022-10-15-team1-goodmodel.csv[22m[24m ----[39m
      
      [1m[22m[31m(x)[39m [90m[file_exists][39m: File does not exist at path [34mmodel-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv[39m.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv")
    Message
      
      [35m-- [4m[1m2022-10-15-hub-baseline.csv[22m[24m ----[39m
      
      [1m[22m[32mv[39m [90m[file_exists][39m: File exists at path [34mmodel-output/team1-goodmodel/2022-10-15-hub-baseline.csv[39m.
      [32mv[39m [90m[file_name][39m: File name [34m"2022-10-15-hub-baseline.csv"[39m is valid.
      [31mx[39m [90m[file_location][39m: File directory name must match `model_id` metadata in file name.  File should be submitted to directory [34m"hub-baseline"[39m not [34m"team1-goodmodel"[39m
      [32mv[39m [90m[round_id_valid][39m: `round_id` is valid.
      [32mv[39m [90m[file_format][39m: File is accepted hub format.
      [32mv[39m [90m[file_n][39m: Number of accepted model output files per round met.
      [32mv[39m [90m[metadata_exists][39m: Metadata file exists at path [34mmodel-metadata/hub-baseline.yml[39m.

# validate_model_file print method work [unicode]

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Message
      
      ── 2022-10-08-team1-goodmodel.csv ────
      
      ✔ [file_exists]: File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'.
      ✔ [file_name]: File name "2022-10-08-team1-goodmodel.csv" is valid.
      ✔ [file_location]: File directory name matches `model_id` metadata in file name.
      ✔ [round_id_valid]: `round_id` is valid.
      ✔ [file_format]: File is accepted hub format.
      ✔ [file_n]: Number of accepted model output files per round met.
      ✔ [metadata_exists]: Metadata file exists at path 'model-metadata/team1-goodmodel.yaml'.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message
      
      ── 2022-10-15-team1-goodmodel.csv ────
      
      ⓧ [file_exists]: File does not exist at path 'model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv'.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv")
    Message
      
      ── 2022-10-15-hub-baseline.csv ────
      
      ✔ [file_exists]: File exists at path 'model-output/team1-goodmodel/2022-10-15-hub-baseline.csv'.
      ✔ [file_name]: File name "2022-10-15-hub-baseline.csv" is valid.
      ✖ [file_location]: File directory name must match `model_id` metadata in file name.  File should be submitted to directory "hub-baseline" not "team1-goodmodel"
      ✔ [round_id_valid]: `round_id` is valid.
      ✔ [file_format]: File is accepted hub format.
      ✔ [file_n]: Number of accepted model output files per round met.
      ✔ [metadata_exists]: Metadata file exists at path 'model-metadata/hub-baseline.yml'.

# validate_model_file print method work [fancy]

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Message
      
      [35m── [4m[1m2022-10-08-team1-goodmodel.csv[22m[24m ────[39m
      
      [1m[22m[32m✔[39m [90m[file_exists][39m: File exists at path [34mmodel-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv[39m.
      [32m✔[39m [90m[file_name][39m: File name [34m"2022-10-08-team1-goodmodel.csv"[39m is valid.
      [32m✔[39m [90m[file_location][39m: File directory name matches `model_id` metadata in file name.
      [32m✔[39m [90m[round_id_valid][39m: `round_id` is valid.
      [32m✔[39m [90m[file_format][39m: File is accepted hub format.
      [32m✔[39m [90m[file_n][39m: Number of accepted model output files per round met.
      [32m✔[39m [90m[metadata_exists][39m: Metadata file exists at path [34mmodel-metadata/team1-goodmodel.yaml[39m.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message
      
      [35m── [4m[1m2022-10-15-team1-goodmodel.csv[22m[24m ────[39m
      
      [1m[22m[31mⓧ[39m [90m[file_exists][39m: File does not exist at path [34mmodel-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv[39m.

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-hub-baseline.csv")
    Message
      
      [35m── [4m[1m2022-10-15-hub-baseline.csv[22m[24m ────[39m
      
      [1m[22m[32m✔[39m [90m[file_exists][39m: File exists at path [34mmodel-output/team1-goodmodel/2022-10-15-hub-baseline.csv[39m.
      [32m✔[39m [90m[file_name][39m: File name [34m"2022-10-15-hub-baseline.csv"[39m is valid.
      [31m✖[39m [90m[file_location][39m: File directory name must match `model_id` metadata in file name.  File should be submitted to directory [34m"hub-baseline"[39m not [34m"team1-goodmodel"[39m
      [32m✔[39m [90m[round_id_valid][39m: `round_id` is valid.
      [32m✔[39m [90m[file_format][39m: File is accepted hub format.
      [32m✔[39m [90m[file_n][39m: Number of accepted model output files per round met.
      [32m✔[39m [90m[metadata_exists][39m: Metadata file exists at path [34mmodel-metadata/hub-baseline.yml[39m.

