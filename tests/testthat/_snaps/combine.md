# combine works

    Code
      str(combine(new_hub_validations(), new_hub_validations(), NULL))
    Output
       list()
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(combine(new_hub_validations(), new_hub_validations(file_exists = check_file_exists(
        file_path, hub_path), file_name = check_file_name(file_path), NULL)))
    Output
      List of 2
       $ file_exists:List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name  :List of 4
        ..$ message       : chr "File name \"2022-10-08-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

---

    Code
      str(combine(new_hub_validations(file_exists = check_file_exists(file_path,
        hub_path)), new_hub_validations(file_name = check_file_name(file_path), NULL)))
    Output
      List of 2
       $ file_exists:List of 4
        ..$ message       : chr "File exists at path 'model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv'. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_exists"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       $ file_name  :List of 4
        ..$ message       : chr "File name \"2022-10-08-team1-goodmodel.csv\" is valid. \n "
        ..$ where         : chr "team1-goodmodel/2022-10-08-team1-goodmodel.csv"
        ..$ call          : chr "check_file_name"
        ..$ use_cli_format: logi TRUE
        ..- attr(*, "class")= chr [1:5] "check_success" "hub_check" "rlang_message" "message" ...
       - attr(*, "class")= chr [1:2] "hub_validations" "list"

# combine errors correctly

    Code
      combine(new_hub_validations(), new_hub_validations(), a = 1)
    Condition
      Error in `validate_internal_class()`:
      ! All elements must inherit from class <hub_validations>.
      x Element with index 1 does not.

---

    Code
      combine(new_hub_validations(file_exists = check_file_exists(file_path, hub_path),
      file_name = check_file_name(file_path), a = 10))
    Condition
      Error in `validate_internal_class()`:
      ! All elements must inherit from class <hub_check>.
      x Element with index 3 does not.

