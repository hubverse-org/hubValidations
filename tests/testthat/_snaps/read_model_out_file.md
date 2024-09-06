# read_model_out_file works

    Code
      str(read_model_out_file(file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        hub_path = system.file("testhubs/simple", package = "hubValidations")))
    Output
      tibble [47 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:47], format: "2022-10-08" "2022-10-08" ...
       $ target        : chr [1:47] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:47] 1 1 1 1 1 1 1 1 1 1 ...
       $ location      : chr [1:47] "US" "US" "US" "US" ...
       $ output_type   : chr [1:47] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:47] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:47] 135 137 139 140 141 141 142 143 144 145 ...

---

    Code
      str(read_model_out_file(file_path = "team1-goodmodel/2022-10-08-team1-goodmodel.csv",
        hub_path = system.file("testhubs/simple", package = "hubValidations")))
    Output
      tibble [47 x 7] (S3: tbl_df/tbl/data.frame)
       $ origin_date   : Date[1:47], format: "2022-10-08" "2022-10-08" ...
       $ target        : chr [1:47] "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" "wk inc flu hosp" ...
       $ horizon       : int [1:47] 1 1 1 1 1 1 1 1 1 1 ...
       $ location      : chr [1:47] "US" "US" "US" "US" ...
       $ output_type   : chr [1:47] "quantile" "quantile" "quantile" "quantile" ...
       $ output_type_id: num [1:47] 0.01 0.025 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 ...
       $ value         : int [1:47] 135 137 139 140 141 141 142 143 144 145 ...

# read_model_out_file correctly uses hub schema to read character cols in csvs

    Code
      str(read_model_out_file(hub_path = test_path("testdata/hub"),
      "hub-baseline/2023-04-24-hub-baseline.csv"))
    Output
      tibble [48 x 8] (S3: tbl_df/tbl/data.frame)
       $ forecast_date  : Date[1:48], format: "2023-04-24" "2023-04-24" ...
       $ target_end_date: Date[1:48], format: "2023-05-01" "2023-05-08" ...
       $ horizon        : int [1:48] 1 2 1 1 1 1 1 1 1 1 ...
       $ target         : chr [1:48] "wk ahead inc flu hosp" "wk ahead inc flu hosp" "wk ahead inc flu hosp" "wk ahead inc flu hosp" ...
       $ location       : chr [1:48] "06" "06" "06" "06" ...
       $ output_type    : chr [1:48] "mean" "mean" "quantile" "quantile" ...
       $ output_type_id : chr [1:48] NA NA "0.01" "0.025" ...
       $ value          : num [1:48] 1033 1033 0 0 0 ...
