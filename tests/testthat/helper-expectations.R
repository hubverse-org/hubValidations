# The first class of each element of `x`, such as each check in a
# `hub_validations` object or each column of a tibble.
first_classes <- function(x) purrr::map_chr(x, ~ class(.x)[1])

# Expect a tibble with `n_rows` rows and the column names and classes in `types`.
# For each column named in `values`, also expect its sorted unique values, with
# `NA` last.
expect_tbl <- function(x, n_rows, types, values = list()) {
  testthat::expect_s3_class(x, "tbl_df")
  testthat::expect_equal(nrow(x), n_rows)
  testthat::expect_equal(first_classes(x), types)
  for (col in names(values)) {
    testthat::expect_equal(
      sort(unique(x[[col]]), na.last = TRUE, method = "radix"),
      values[[col]],
      label = col
    )
  }
}

# Expect an arrow Table, or a list of them, holding the same data as the
# tibble, or list of tibbles, `tbl`. Each Table must also have the arrow column
# types that `arrow::arrow_table()` gives the corresponding tibble.
expect_arrow_tbl <- function(x, tbl) {
  if (is.list(x) && !is.data.frame(x)) {
    testthat::expect_length(x, length(tbl))
    purrr::walk2(x, tbl, expect_arrow_tbl)
    return(invisible(x))
  }
  testthat::expect_s3_class(x, "Table")
  testthat::expect_equal(arrow_types(x), arrow_types(arrow::arrow_table(tbl)))
  testthat::expect_equal(tibble::as_tibble(x), tbl)
}

# Expect `x`, a grid or template built with a `compound_taskid_set` override,
# to match `tbl`, built without one, apart from its sample rows. An override
# changes only the sample IDs, so the sample rows are snapshotted.
expect_spl_override <- function(x, tbl) {
  is_spl <- x$output_type == "sample"
  testthat::expect_equal(x[!is_spl, ], tbl[tbl$output_type != "sample", ])
  testthat::expect_snapshot(x[is_spl, ])
}

# `x` with every column converted to character.
as_chr <- function(x) {
  dplyr::mutate(x, dplyr::across(dplyr::everything(), as.character))
}

# The arrow type of each column of the arrow Table `x`, named by column.
arrow_types <- function(x) {
  purrr::map_chr(x$schema$fields, ~ .x$type$ToString()) |>
    purrr::set_names(names(x))
}

# The quantile levels the simple and flusight test hubs accept.
hub_quantiles <- c(0.01, 0.025, seq(0.05, 0.95, by = 0.05), 0.975, 0.99)

# The locations the simple and flusight test hubs accept, sorted.
# fmt: skip
hub_locations <- c(
  "01", "02", "04", "05", "06", "08", "09", "10", "11", "12", "13", "15", "16",
  "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29",
  "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42",
  "44", "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56", "72",
  "78", "US"
)

# The output type IDs of the model output grid of the flusight test hub, sorted
# as `expect_tbl()` sorts them.
flusight_output_type_ids <- c(
  as.character(hub_quantiles),
  "decrease",
  "increase",
  "large_decrease",
  "large_increase",
  "stable",
  NA
)

# Column classes of the model output grid of the flusight test hub in hubUtils.
flusight_grid_types <- c(
  forecast_date = "Date",
  target = "character",
  horizon = "integer",
  location = "character",
  output_type = "character",
  output_type_id = "character"
)

# Column classes of the model output grid of the simple test hub in hubUtils,
# for rounds without an `age_group` task ID.
simple_grid_types <- c(
  origin_date = "Date",
  target = "character",
  horizon = "integer",
  location = "character",
  output_type = "character",
  output_type_id = "numeric"
)

# Expected results of the config check on a valid hub.
valid_config <- c(valid_config = "check_success")

# Expected results of the file checks on a valid model output file.
file_checks <- c(
  file_exists = "check_success",
  file_name = "check_success",
  file_location = "check_success",
  round_id_valid = "check_success",
  file_format = "check_success",
  file_n = "check_success",
  metadata_exists = "check_success"
)

# Expected results of the data checks on the valid model output files the
# tests use from the simple and flusight test hubs. These files have quantile
# but no cdf or pmf output.
data_checks <- c(
  file_read = "check_success",
  valid_round_id_col = "check_success",
  unique_round_id = "check_success",
  match_round_id = "check_success",
  colnames = "check_success",
  col_types = "check_success",
  valid_vals = "check_success",
  rows_unique = "check_success",
  req_vals = "check_success",
  value_col_valid = "check_success",
  value_col_non_desc = "check_success",
  value_col_sum1 = "check_info"
)

# Expected results of the sample checks on a valid file in the samples test
# hub.
spl_checks <- c(
  spl_mt_unique = "check_success",
  spl_compound_taskid_set = "check_success",
  spl_overlap = "check_success",
  spl_non_compound_tid = "check_success",
  spl_n = "check_success"
)

# Expected results of the data and sample checks on a valid file in the
# samples test hub. The file has pmf output but no quantile or cdf output.
spl_data_checks <- c(
  replace(
    data_checks,
    c("value_col_non_desc", "value_col_sum1"),
    c("check_info", "check_success")
  ),
  spl_checks
)

# Column classes of the model output grid of the simple test hub in hubUtils,
# for rounds with an `age_group` task ID.
simple_age_grid_types <- append(
  simple_grid_types,
  c(age_group = "character"),
  after = 4L
)
