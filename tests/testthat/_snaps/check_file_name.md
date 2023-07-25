# check_file_name works when file name valid

    Code
      check_file_name("model-output/team1-goodmodel/2022-10-08-team1-goodmodel.csv")
    Output
      [[1]]
      <message/check_success>
      Message:
      File name "2022-10-08-team1-goodmodel.csv" is valid.
      

---

    Code
      check_file_name("model-output/team1-goodmodel/2022-10-08-team1-good_model.csv")
    Output
      [[1]]
      <message/check_success>
      Message:
      File name "2022-10-08-team1-good_model.csv" is valid.
      

---

    Code
      check_file_name("model-output/team1-goodmodel/round_1-team1-goodmodel.parquet")
    Output
      [[1]]
      <message/check_success>
      Message:
      File name "round_1-team1-goodmodel.parquet" is valid.
      

# check_file_name works when file name fails

    Code
      check_file_name("model-output/team1-goodmodel/2022-10-08-team1_goodmodel.csv")
    Output
      [[1]]
      <error/check_error>
      Error:
      ! File name "2022-10-08-team1_goodmodel.csv" must be valid.  Could not correctly parse submission metadata.
      

---

    Code
      check_file_name("model-output/team1-goodmodel/round_1-team1-good-model.parquet")
    Output
      [[1]]
      <error/check_error>
      Error:
      ! File name "round_1-team1-good-model.parquet" must be valid.  Could not correctly parse submission metadata.
      

