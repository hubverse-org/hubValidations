## code to prepare `sysdata.rda` dataset goes here

valid_ext <- c("csv", "parquet", "arrow")

usethis::use_data(valid_ext, overwrite = TRUE, internal = TRUE)
