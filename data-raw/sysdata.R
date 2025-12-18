## code to prepare `sysdata.rda` dataset goes here

valid_ext <- c("csv", "parquet", "arrow")

## code to prepare `json_datatypes` dataset goes here
json_datatypes <- c(
  string = "character",
  boolean = "logical",
  integer = "integer",
  number = "double"
)

## code to prepare compress_codec vector of compression libraries used by arrow write_parquet
compress_codec <- c(
  "snappy",
  "gzip",
  "gz",
  "brotli",
  "zstd",
  "lz4",
  "lzo",
  "bz2"
)

usethis::use_data(
  valid_ext,
  json_datatypes,
  compress_codec,
  overwrite = TRUE,
  internal = TRUE
)
