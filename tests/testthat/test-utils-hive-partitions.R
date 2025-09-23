test_that("extract_partition_df returns coerced tibble with valid partitions", {
  schema <- arrow::schema(country = arrow::utf8(), year = arrow::int32())

  result <- extract_partition_df(
    "data/country=US/year=2024/file.parquet",
    schema
  )

  expect_s3_class(result, "tbl_df")
  expect_named(result, c("country", "year"))
  expect_equal(result$country, "US")
  expect_equal(result$year, 2024L)
})

test_that("extract_partition_df coerces empty values to NA and respects schema", {
  schema <- arrow::schema(country = arrow::utf8(), year = arrow::int32())

  result <- extract_partition_df("data/country=/year=2024/", schema)

  expect_true(is.na(result$country))
  expect_equal(result$year, 2024L)
})

test_that("extract_partition_df handles special Hive NA placeholder", {
  schema <- arrow::schema(topic = arrow::utf8(), year = arrow::int32())

  result <- extract_partition_df(
    "data/topic=__HIVE_DEFAULT_PARTITION__/year=2024/",
    schema
  )

  expect_true(is.na(result$topic))
  expect_equal(result$year, 2024L)
})


test_that("extract_partition_df errors if schema is missing a partition key", {
  schema <- arrow::schema(year = arrow::int32()) # Missing 'country'

  expect_error(
    extract_partition_df("data/country=US/year=2024/", schema),
    regexp = "Partition key.*country.*missing in.*schema"
  )
})

test_that("extract_partition_df handles multiple missing keys in schema", {
  schema <- arrow::schema(foo = arrow::utf8()) # Missing both

  expect_error(
    extract_partition_df("data/country=US/year=2024/", schema),
    regexp = "Partition keys?.*country.*year.*missing in.*schema"
  )
})

test_that("extract_partition_df returns NULL if no partitions are present", {
  schema <- arrow::schema(foo = arrow::utf8())
  expect_null(extract_partition_df("data/file.parquet", schema))
})
