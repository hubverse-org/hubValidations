# ---- create file ----
# library(dplyr)
# library(tibble)
hub_path <- system.file("testhubs/simple", package = "hubValidations")
model_id <- "team1-goodmodel"
round_id <- "2022-10-15"
submit_dir <- fs::path(hub_path, "model-output", model_id)
tmpl_file <- fs::dir_ls(submit_dir)[1]

df <- switch(fs::path_ext(tmpl_file),
  csv = arrow::read_csv_arrow(tmpl_file),
  parquet = arrow::read_parquet(tmpl_file),
  arrow = arrow::read_feather(tmpl_file)
)

# missing columns
missing_col <- df
missing_col$origin_date <- as.Date(round_id)
testthis::use_testdata(missing_col, subdir = "files", overwrite = TRUE)


# multiple round IDs in rid columns
df <- tibble::add_column(df, age_group = "65+", .before = "output_type")
multiple_rids <- df
multiple_rids$origin_date[1:3] <- "2022-10-15"
testthis::use_testdata(multiple_rids, subdir = "files", overwrite = TRUE)


## CREATE hub-spl test files
## Create files ----
set.seed(123)
create_spl_file("2022-10-22")

# Coarser samples ----
create_spl_file("2022-10-29",
  compound_taskid_set = list(
    NULL,
    c("reference_date", "location")
  )
)

create_spl_file("2022-11-05",
  compound_taskid_set = list(
    NULL,
    c("reference_date", "horizon")
  )
)
