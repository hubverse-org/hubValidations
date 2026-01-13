# Read a single target data file

Read a single target data file

## Usage

``` r
read_target_file(
  target_file_path,
  hub_path,
  coerce_types = c("target", "chr", "none"),
  date_col = NULL,
  na = c("NA", "")
)
```

## Arguments

- target_file_path:

  Character string. Path to the target data file being validated
  relative to the hub's `target-data` directory.

- hub_path:

  Either a character string path to a local Modeling Hub directory or an
  object of class `<SubTreeFileSystem>` created using functions
  [`s3_bucket()`](https://arrow.apache.org/docs/r/reference/s3_bucket.html)
  or
  [`gs_bucket()`](https://arrow.apache.org/docs/r/reference/gs_bucket.html)
  by providing a string S3 or GCS bucket name or path to a Modeling Hub
  directory stored in the cloud. For more details consult the [Using
  cloud storage (S3,
  GCS)](https://arrow.apache.org/docs/r/articles/fs.html) in the `arrow`
  package. The hub must be fully configured with valid `admin.json` and
  `tasks.json` files within the `hub-config` directory.

- coerce_types:

  character string. What to coerce column types to on read.

  - `target`: (default) read in (`csv`) or coerce (`parquet`) to
    expected schema by target type (See
    [`hubData::create_timeseries_schema()`](https://hubverse-org.github.io/hubData/reference/create_timeseries_schema.html)
    and
    [`hubData::create_oracle_output_schema()`](https://hubverse-org.github.io/hubData/reference/create_oracle_output_schema.html)
    for details). When coercing data types using the `target` schema,
    the `output_type_id_datatype` can also be used to set the
    `output_type_id` column data type manually.

  - `chr`: read in (`csv`) or coerce (`parquet`) all columns to
    character.

  - `none`: No coercion. Use `arrow` `read_*` function defaults.

- date_col:

  Optional column name to be interpreted as date. Default is `NULL`.
  Useful when the required date column is a partitioning column in the
  target data and does not have the same name as a date typed task ID
  variable in the config.

- na:

  A character vector of strings to interpret as missing values. Only
  applies to CSV files. The default is `c("NA", "")`. Useful when actual
  character string `"NA"` values are used in the data. In such a case,
  use empty cells to indicate missing values in your files and set
  `na = ""`.

## Value

a tibble of contents of the target data file.

## Examples

``` r
# download example hub
hub_path <- system.file("testhubs/v5/target_file",
  package = "hubUtils"
)
# read in time-series file
read_target_file("time-series.csv", hub_path)
#> # A tibble: 66 × 4
#>    target_end_date target       location observation
#>    <date>          <chr>        <chr>          <dbl>
#>  1 2022-10-22      flu_hosp_inc 02                 3
#>  2 2022-10-22      flu_hosp_inc 01               141
#>  3 2022-10-22      flu_hosp_inc US              2380
#>  4 2022-10-29      flu_hosp_inc 02                14
#>  5 2022-10-29      flu_hosp_inc 01               262
#>  6 2022-10-29      flu_hosp_inc US              4353
#>  7 2022-11-05      flu_hosp_inc 02                10
#>  8 2022-11-05      flu_hosp_inc 01               360
#>  9 2022-11-05      flu_hosp_inc US              6571
#> 10 2022-11-12      flu_hosp_inc 02                20
#> # ℹ 56 more rows
read_target_file("time-series.csv", hub_path, coerce_types = "chr")
#> # A tibble: 66 × 4
#>    target_end_date target       location observation
#>    <chr>           <chr>        <chr>    <chr>      
#>  1 2022-10-22      flu_hosp_inc 02       3          
#>  2 2022-10-22      flu_hosp_inc 01       141        
#>  3 2022-10-22      flu_hosp_inc US       2380       
#>  4 2022-10-29      flu_hosp_inc 02       14         
#>  5 2022-10-29      flu_hosp_inc 01       262        
#>  6 2022-10-29      flu_hosp_inc US       4353       
#>  7 2022-11-05      flu_hosp_inc 02       10         
#>  8 2022-11-05      flu_hosp_inc 01       360        
#>  9 2022-11-05      flu_hosp_inc US       6571       
#> 10 2022-11-12      flu_hosp_inc 02       20         
#> # ℹ 56 more rows
# read in oracle-output file
read_target_file("oracle-output.csv", hub_path)
#> # A tibble: 627 × 6
#>    location target_end_date target       output_type output_type_id oracle_value
#>    <chr>    <date>          <chr>        <chr>       <chr>                 <dbl>
#>  1 US       2022-10-22      flu_hosp_ra… cdf         1                         1
#>  2 US       2022-10-22      flu_hosp_ra… cdf         2                         1
#>  3 US       2022-10-22      flu_hosp_ra… cdf         3                         1
#>  4 US       2022-10-22      flu_hosp_ra… cdf         4                         1
#>  5 US       2022-10-22      flu_hosp_ra… cdf         5                         1
#>  6 US       2022-10-22      flu_hosp_ra… cdf         6                         1
#>  7 US       2022-10-22      flu_hosp_ra… cdf         7                         1
#>  8 US       2022-10-22      flu_hosp_ra… cdf         8                         1
#>  9 US       2022-10-22      flu_hosp_ra… cdf         9                         1
#> 10 US       2022-10-22      flu_hosp_ra… cdf         10                        1
#> # ℹ 617 more rows
read_target_file("oracle-output.csv", hub_path, coerce_types = "chr")
#> # A tibble: 627 × 6
#>    location target_end_date target       output_type output_type_id oracle_value
#>    <chr>    <chr>           <chr>        <chr>       <chr>          <chr>       
#>  1 US       2022-10-22      flu_hosp_ra… cdf         1              1           
#>  2 US       2022-10-22      flu_hosp_ra… cdf         2              1           
#>  3 US       2022-10-22      flu_hosp_ra… cdf         3              1           
#>  4 US       2022-10-22      flu_hosp_ra… cdf         4              1           
#>  5 US       2022-10-22      flu_hosp_ra… cdf         5              1           
#>  6 US       2022-10-22      flu_hosp_ra… cdf         6              1           
#>  7 US       2022-10-22      flu_hosp_ra… cdf         7              1           
#>  8 US       2022-10-22      flu_hosp_ra… cdf         8              1           
#>  9 US       2022-10-22      flu_hosp_ra… cdf         9              1           
#> 10 US       2022-10-22      flu_hosp_ra… cdf         10             1           
#> # ℹ 617 more rows
```
