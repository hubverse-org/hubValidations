# validate_model_file works

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Message <rlang_message>
      v 2022-10-08-team1-goodmodel.csv: File exists at path '/Users/Anna/Library/R/arm64/4.2/library/hubUtils/testhubs/simple/model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'.
      v 2022-10-08-team1-goodmodel.csv: File name "2022-10-08-team1-goodmodel.csv" is valid.
      v 2022-10-08-team1-goodmodel.csv: File directory name matches `model_id` metadata in file name.
      v 2022-10-08-team1-goodmodel.csv: `round_id` is valid.
      v 2022-10-08-team1-goodmodel.csv: File is accepted hub format.

---

    Code
      str(validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv"))
    Output
      List of 5
       $ file_exists   :List of 4
        ..$ message       : chr "File exists at path '/Users/Anna/Library/R/arm64/4.2/library/hubUtils/testhubs/simple/model-output/team1-goodmo"| __truncated__
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : NULL
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name     :List of 4
        ..$ message       : chr "File name \"2022-10-08-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : NULL
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_location :List of 4
        ..$ message       : chr "File directory name matches `model_id`\n                                           metadata in file name. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : NULL
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ round_id_valid:List of 4
        ..$ message       : chr "`round_id` is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : NULL
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_format   :List of 4
        ..$ message       : chr "File is accepted hub format. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : NULL
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      validate_model_file(hub_path, file_path = "team1-goodmodel/2022-10-15-team1-goodmodel.csv")
    Message <rlang_message>
      x 2022-10-15-team1-goodmodel.csv: File does not exist at path '/Users/Anna/Library/R/arm64/4.2/library/hubUtils/testhubs/simple/model-output/team1-goodmodel/2022-10-15-team1-goodmodel.csv'.

