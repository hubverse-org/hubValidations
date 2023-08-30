## code to prepare `sysdata.rda` dataset goes here

valid_ext <- c("csv", "parquet", "arrow")

## code to prepare `json_datatypes` dataset goes here
json_datatypes <- c(
    string = "character",
    boolean = "logical",
    integer = "integer",
    number = "double"
)

usethis::use_data(valid_ext, json_datatypes, overwrite = TRUE, internal = TRUE)
