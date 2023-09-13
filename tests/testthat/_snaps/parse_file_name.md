# parse_file_name works

    Code
      parse_file_name("model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Output
      $round_id
      [1] "2022-10-08"
      
      $team_abbr
      [1] "team1"
      
      $model_abbr
      [1] "goodmodel"
      
      $model_id
      [1] "team1-goodmodel"
      
      $ext
      [1] "csv"
      

---

    Code
      parse_file_name("model-output/team1-goodmodel/2022-10-08-team1-good_model.csv")
    Output
      $round_id
      [1] "2022-10-08"
      
      $team_abbr
      [1] "team1"
      
      $model_abbr
      [1] "good_model"
      
      $model_id
      [1] "team1-good_model"
      
      $ext
      [1] "csv"
      

---

    Code
      parse_file_name("model-output/team1-goodmodel/round_1-team1-goodmodel.parquet")
    Output
      $round_id
      [1] "round_1"
      
      $team_abbr
      [1] "team1"
      
      $model_abbr
      [1] "goodmodel"
      
      $model_id
      [1] "team1-goodmodel"
      
      $ext
      [1] "parquet"
      

# parse_file_name fails correctly

    Code
      parse_file_name("model-output/team1-goodmodel/2022-10-08-team1_goodmodel.csv")
    Error <rlang_error>
      Could not parse file name '2022-10-08-team1_goodmodel' for submission metadata. Please consult documentation for file name requirements for correct metadata parsing.

