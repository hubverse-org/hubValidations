# Read a model output file

Read a model output file

## Usage

``` r
read_model_out_file(
  file_path,
  hub_path = ".",
  coerce_types = c("hub", "chr", "none"),
  output_type_id_datatype = c("from_config", "auto", "character", "double", "integer",
    "logical", "Date")
)
```

## Arguments

- file_path:

  character string. Path to the file being validated relative to the
  hub's model-output directory.

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

  character. What to coerce column types to on read.

  - `hub`: (default) read in (`csv`) or coerce (`parquet`, `arrow`) to
    hub schema. When coercing data types using the `hub` schema, the
    `output_type_id_datatype` can also be used to set the
    `output_type_id` column data type manually.

  - `chr`: read in (`csv`) or coerce (`parquet`, `arrow`) all columns to
    character.

  - `none`: No coercion. Use `arrow` `read_*` function defaults.

- output_type_id_datatype:

  character string. One of `"from_config"`, `"auto"`, `"character"`,
  `"double"`, `"integer"`, `"logical"`, `"Date"`. Defaults to
  `"from_config"` which uses the setting in the
  `output_type_id_datatype` property in the `tasks.json` config file if
  available. If the property is not set in the config, the argument
  falls back to `"auto"` which determines the `output_type_id` data type
  automatically from the `tasks.json` config file as the simplest data
  type required to represent all output type ID values across all output
  types in the hub. When only point estimate output types (where
  `output_type_id`s are `NA`,) are being collected by a hub, the
  `output_type_id` column is assigned a `character` data type when
  auto-determined. Other data type values can be used to override
  automatic determination. Note that attempting to coerce
  `output_type_id` to a data type that is not valid for the data (e.g.
  trying to coerce`"character"` values to `"double"`) will likely result
  in an error or potentially unexpected behaviour so use with care.

## Value

a tibble of contents of the model output file.
