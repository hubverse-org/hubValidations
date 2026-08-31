test_that("assert_tbl_chr accepts an all character table", {
  expect_null(
    assert_tbl_chr(tibble::tibble(location = "US", horizon = "1"))
  )
})

test_that("assert_tbl_chr reports the columns that are not character", {
  tbl <- tibble::tibble(
    origin_date = as.Date("2022-10-08"),
    location = "US",
    horizon = 1L,
    value = 0.5
  )
  expect_snapshot(assert_tbl_chr(tbl), error = TRUE)
  expect_snapshot(assert_tbl_chr(tbl["horizon"]), error = TRUE)
})

test_that("a typed table is rejected by every function that takes tbl_chr", {
  # Derived from the signatures rather than listed, so a function added later
  # is covered without anyone remembering to add it here.
  ns <- asNamespace("hubValidations")
  fns <- Filter(
    \(nm) "tbl_chr" %in% names(formals(get(nm, envir = ns))),
    getNamespaceExports("hubValidations")
  )
  expect_gte(length(fns), 13L)
  tbl <- tibble::tibble(location = "US", horizon = 1L)

  for (fn in fns) {
    expect_error(
      do.call(fn, list(tbl_chr = tbl)),
      "Every column of .* must be character",
      info = fn
    )
  }
})
