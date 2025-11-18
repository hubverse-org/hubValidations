# Parse model output file metadata from file name

Parse model output file metadata from file name

## Usage

``` r
parse_file_name(file_path, file_type = c("model_output", "model_metadata"))
```

## Arguments

- file_path:

  Character string. A model output file name. Can include parent
  directories which are ignored.

- file_type:

  Character string. Type of file name being parsed. One of
  `"model_output"` or `"model_metadata"`.

## Value

A list with the following elements:

- `round_id`: The round ID the model output is associated with (`NA` for
  model metadata files.)

- `team_abbr`: The team responsible for the model.

- `model_abbr`: The name of the model.

- `model_id`: The unique model ID derived from the concatenation of
  `<team_abbr>-<model_abbr>`.

- `ext`: The file extension.

- `compression_ext`: optional. The compression extension if present.

## Details

File names are allowed to contain the following compression extension
prefixes: .snappy, .gzip, .gz, .brotli, .zstd, .lz4, .lzo, .bz2. These
extension prefixes are now extracted when parsing the file name and
returned as `compression_ext` element if present.

## Examples

``` r
parse_file_name("hub-baseline/2022-10-15-hub-baseline.csv")
#> $round_id
#> [1] "2022-10-15"
#> 
#> $team_abbr
#> [1] "hub"
#> 
#> $model_abbr
#> [1] "baseline"
#> 
#> $model_id
#> [1] "hub-baseline"
#> 
#> $ext
#> [1] "csv"
#> 
parse_file_name("hub-baseline/2022-10-15-hub-baseline.gzip.parquet")
#> $round_id
#> [1] "2022-10-15"
#> 
#> $team_abbr
#> [1] "hub"
#> 
#> $model_abbr
#> [1] "baseline"
#> 
#> $model_id
#> [1] "hub-baseline"
#> 
#> $ext
#> [1] "parquet"
#> 
#> $compression_ext
#> [1] "gzip"
#> 
```
