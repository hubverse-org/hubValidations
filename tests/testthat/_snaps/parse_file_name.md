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
      

---

    Code
      parse_file_name("hub-baseline.yml", file_type = "model_metadata")
    Output
      $round_id
      [1] NA
      
      $team_abbr
      [1] "hub"
      
      $model_abbr
      [1] "baseline"
      
      $model_id
      [1] "hub-baseline"
      
      $ext
      [1] "yml"
      

---

    Code
      parse_file_name("hubBaseline.yml", file_type = "model_metadata")
    Condition
      Error in `parse_file_name()`:
      x File name 'hubBaseline' does not match expected pattern of [team_abbr]-[model_abbr]. Please consult documentation on file name requirements (<https://hubverse.io/en/latest/user-guide/model-metadata.html#directory-structure>) for details.

# parse_file_name fails correctly

    Code
      parse_file_name("model-output/team1-goodmodel/2022-10-08-team1_goodmodel.csv")
    Condition
      Error in `parse_file_name()`:
      x File name '2022-10-08-team1_goodmodel' does not match expected pattern of [round_id]-[team_abbr]-[model_abbr]. Please consult documentation on file name requirements (<https://hubverse.io/en/latest/user-guide/model-output.html#directory-structure>) for details.

---

    Code
      parse_file_name("model-output/team1-goodmodel/2022-10-08-team1_goodmodel .csv")
    Condition
      Error in `parse_file_name()`:
      x File name '2022-10-08-team1_goodmodel ' contains character " " that is not allowed

---

    Code
      parse_file_name("model-output/team1-goodmodel/2022-10-08-team1_goodmodel*.csv")
    Condition
      Error in `parse_file_name()`:
      x File name '2022-10-08-team1_goodmodel*' contains character "*" that is not allowed

# parse_file_name ignores compression extensions

    Code
      parse_file_name(
        "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.gzip.parquet")
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
      [1] "parquet"
      
      $compression_ext
      [1] "gzip"
      

---

    Code
      parse_file_name(
        "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.gz.parquet")
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
      [1] "parquet"
      
      $compression_ext
      [1] "gz"
      

---

    Code
      parse_file_name(
        "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.snappy.parquet")
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
      [1] "parquet"
      
      $compression_ext
      [1] "snappy"
      

---

    Code
      parse_file_name(
        "model-output/team1-goodmodel/2022-10-08-team1-goodmodel.gzipr.parquet")
    Condition
      Error in `parse_file_name()`:
      x Compression extension "gzipr" is not valid. Must be one of "snappy", "gzip", "gz", "brotli", "zstd", "lz4", "lzo", and "bz2". Please consult documentation on file name requirements (<https://hubverse.io/en/latest/user-guide/model-output.html#directory-structure>) for details.

