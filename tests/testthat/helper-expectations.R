# The first class of each element of `x`, such as each check in a
# `hub_validations` object or each column of a tibble.
first_classes <- function(x) purrr::map_chr(x, ~ class(.x)[1])

# Expect a tibble with `n_rows` distinct rows and the column names and classes
# in `types`. Every column in `types` must be checked in one of three ways:
# - `values`: for each column named, the sorted unique values, with `NA` last.
# - `counts`: the expected `dplyr::count()` of `x` by the columns it names,
#   which also pins which values of those columns appear together.
# - `unchecked`: columns deliberately left out, such as those pinned by an
#   exact check elsewhere in the test.
expect_tbl <- function(
  x,
  n_rows,
  types,
  values = list(),
  counts = NULL,
  unchecked = character()
) {
  testthat::expect_s3_class(x, "tbl_df")
  testthat::expect_equal(nrow(x), n_rows)
  testthat::expect_equal(nrow(dplyr::distinct(x)), n_rows)
  testthat::expect_equal(first_classes(x), types)
  count_cols <- setdiff(names(counts), "n")
  missing <- setdiff(names(types), c(names(values), count_cols, unchecked))
  testthat::expect(
    length(missing) == 0L,
    paste(
      "Columns not checked by `values`, `counts` or `unchecked`:",
      paste(missing, collapse = ", ")
    )
  )
  for (col in names(values)) {
    testthat::expect_equal(
      sort(unique(x[[col]]), na.last = TRUE, method = "radix"),
      values[[col]],
      label = col
    )
  }
  if (!is.null(counts)) {
    testthat::expect_equal(
      dplyr::count(x, dplyr::across(dplyr::all_of(count_cols))),
      counts
    )
  }
}

# Expect an arrow Table, or a list of them, holding the same data as the
# tibble, or list of tibbles, `tbl`. `types` gives the expected arrow type of
# each column, named by column, as literal strings such as `"int32"`.
expect_arrow_tbl <- function(x, tbl, types) {
  if (is.list(x) && !is.data.frame(x)) {
    testthat::expect_length(x, length(tbl))
    purrr::walk2(x, tbl, \(x, tbl) expect_arrow_tbl(x, tbl, types))
    return(invisible(x))
  }
  testthat::expect_s3_class(x, "Table")
  testthat::expect_equal(arrow_types(x), types[names(x)])
  testthat::expect_equal(tibble::as_tibble(x), tbl)
}

# The arrow types of an all character table with the columns of `tbl`.
string_types <- function(tbl) {
  purrr::set_names(rep("string", ncol(tbl)), names(tbl))
}

# Expect `x`, a grid or template built with a `compound_taskid_set` override,
# to match `tbl`, built without one, apart from the sample IDs. An override
# changes only how rows are grouped into samples, so `x` must hold the same
# rows as `tbl`, and its sample rows the sample IDs `spl_ids`, in row order.
expect_spl_override <- function(x, tbl, spl_ids) {
  is_spl <- x$output_type == "sample"
  tbl_spl <- tbl[tbl$output_type == "sample", ]
  testthat::expect_equal(x[!is_spl, ], tbl[tbl$output_type != "sample", ])
  sort_rows <- function(y) {
    y <- y[names(y) != "output_type_id"]
    dplyr::arrange(y, dplyr::pick(dplyr::everything()))
  }
  testthat::expect_equal(sort_rows(x[is_spl, ]), sort_rows(tbl_spl))
  testthat::expect_equal(x$output_type_id[is_spl], spl_ids)
}

# Class vectors of check results.
success_class <- c(
  "check_success",
  "hub_check",
  "rlang_message",
  "message",
  "condition"
)
failure_class <- c(
  "check_failure",
  "hub_check",
  "rlang_error",
  "error",
  "condition"
)
error_class <- c(
  "check_error",
  "hub_check",
  "rlang_error",
  "error",
  "condition"
)

# Class vector of validation warnings.
warning_class <- c(
  "validation_warning",
  "rlang_warning",
  "warning",
  "condition"
)

# Expect a validations object with exactly the class vector `class`, holding
# checks whose first classes are `checks`. With `where`, also expect the
# object and each of its checks to name `where` as the file validated.
expect_validations <- function(x, class, checks, where = NULL) {
  testthat::expect_s3_class(x, class, exact = TRUE)
  testthat::expect_equal(first_classes(x), checks)
  if (!is.null(where)) {
    testthat::expect_equal(attr(x, "where"), where)
    testthat::expect_equal(
      unname(purrr::map_chr(x, ~ as.character(.x$where))),
      rep(where, length(x))
    )
  }
}

# Expect a check result with exactly the class vector `class`, and the given
# `where` and `call`.
expect_check <- function(x, class, where, call) {
  testthat::expect_s3_class(x, class, exact = TRUE)
  testthat::expect_equal(x$where, where)
  testthat::expect_equal(x$call, call)
}

# `x` with every column converted to character. Base `as.character()` rather
# than `hubData::coerce_to_character()`, which the code under test uses, so
# that the expected value does not come from the code being tested.
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

# Expected results of the metadata checks that run before the schema check
# on a metadata file in the simple test hub.
metadata_checks <- c(
  metadata_schema_exists = "check_success",
  metadata_file_exists = "check_success",
  metadata_file_ext = "check_success",
  metadata_file_location = "check_success"
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

# Expected results of the data checks on a valid model output file without
# pmf output, so the pmf sum check reports `check_info`.
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
  spl_ids = "check_success",
  spl_mt_unique = "check_success",
  spl_compound_taskid_set = "check_success",
  spl_overlap = "check_success",
  spl_non_compound_tid = "check_success",
  spl_n = "check_success"
)

# Wrap every sample `output_type_id` of `tbl` in braces, so sample "1" becomes
# "s{id1}". Check messages must show such IDs as submitted.
brace_spl_ids <- function(tbl) {
  is_spl <- tbl$output_type == "sample"
  tbl$output_type_id[is_spl] <- paste0("s{id", tbl$output_type_id[is_spl], "}")
  tbl
}

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

# Expected results of the checks on a valid model output file in the
# ci-testhub-simple hub. The hub has no sample output types, so the sample
# checks are skipped.
valid_file_checks <- c(
  file_checks,
  data_checks,
  replace(spl_checks, names(spl_checks), "check_info")
)

# Expected results of the checks on the same file when its metadata file is
# missing, as on the test-mod-del branch of ci-testhub-simple.
no_metadata_file_checks <- replace(
  valid_file_checks,
  "metadata_exists",
  "check_failure"
)

# Expect a passing check result carrying the single warning that samples in
# modeling task 2 are coarser than configured.
expect_coarser_warning <- function(res) {
  testthat::expect_null(res$errors)
  testthat::expect_length(res$warnings, 1L)
  testthat::expect_s3_class(res$warnings[[1]], warning_class, exact = TRUE)
  testthat::expect_equal(
    res$warnings[[1]]$message,
    paste(
      "Coarser-than-configured `compound_taskid_set` detected for modeling",
      "task 2. See check message for specifics."
    )
  )
  testthat::expect_equal(
    res$warnings[[1]]$call,
    "coarser_compound_taskid_set_warnings"
  )
}
