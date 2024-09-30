test_that("file content with default settings matches snapshot", {
  # Use with_tempdir to automatically manage the temporary directory
  withr::with_tempdir({
    # Create the custom check file with default settings. Snapshot message
    expect_snapshot(
      create_custom_check("check_default")
    )

    # Define the file path
    check_file_path <- fs::path("src/validations/R/check_default.R")

    # Ensure the file was created
    expect_true(
      fs::file_exists(check_file_path)
    )

    # Read the contents of the created file
    file_contents <- readLines(check_file_path)

    # Capture a snapshot of the file content
    expect_snapshot(cat(file_contents, sep = "\n"))
  })
})

test_that("Fully featured file content matches snapshot", {
  # Use with_tempdir to automatically manage the temporary directory
  withr::with_tempdir({
    # Create the custom check file with all logical arguments set to TRUE
    suppressMessages(
      create_custom_check("check_full",
        error = TRUE, conditional = TRUE,
        error_object = TRUE, extra_args = TRUE
      )
    )

    # Define the file path
    check_file_path <- fs::path("src/validations/R/check_full.R")

    # Ensure the file was created
    expect_true(fs::file_exists(check_file_path))

    # Read the contents of the created file
    file_contents <- readLines(check_file_path)

    # Capture a snapshot of the file content
    expect_snapshot(cat(file_contents, sep = "\n"))
  })
})

test_that("file content with non-default locations matches snapshot", {
  # Use with_tempdir to automatically manage the temporary directory
  withr::with_tempdir({
    # Set a non-default path for r_dir and hub
    non_default_r_dir <- "custom_validations/R"
    hub_path <- "path_to_hub"
    fs::dir_create(hub_path)

    # Create the custom check file with non-default locations
    suppressMessages(
      create_custom_check("check_non_default",
        hub_path = hub_path, r_dir = non_default_r_dir,
        error = FALSE, conditional = TRUE,
        error_object = FALSE, extra_args = TRUE
      )
    )
    # Define the file path in the custom directory
    check_file_path <- fs::path(hub_path, non_default_r_dir, "check_non_default.R")

    # Ensure the file was created
    expect_true(fs::file_exists(check_file_path))

    # Read the contents of the created file
    file_contents <- readLines(check_file_path)

    # Capture a snapshot of the file content
    expect_snapshot(cat(file_contents, sep = "\n"))
  })
})

test_that("create_custom_check fails with invalid name", {
  expect_error(
    create_custom_check(123),
    "Assertion on 'name' failed: Must be of type 'character'"
  )
  expect_error(
    create_custom_check(c("check", "check2")),
    "Assertion on 'name' failed: Must have length 1"
  )
})

test_that("create_custom_check fails with invalid hub_path", {
  expect_error(
    create_custom_check("check", hub_path = c("path1", "path2")),
    "Assertion on 'hub_path' failed: Must have length 1"
  )
})

test_that("create_custom_check fails with non-existent hub_path", {
  expect_error(
    create_custom_check("check", hub_path = "random_hub_path"),
    "Assertion on 'hub_path' failed: Directory 'random_hub_path' does not exist."
  )
})

test_that("create_custom_check fails with invalid r_dir", {
  expect_error(
    create_custom_check("check",
      r_dir = c("dir1", "dir2")
    ),
    "Assertion on 'r_dir' failed: Must have length 1"
  )
})

test_that("create_custom_check fails with invalid error argument", {
  expect_error(
    create_custom_check("check", error = "not_a_logical"),
    "Assertion on 'error' failed: Must be of type 'logical'"
  )
  expect_error(
    create_custom_check("check", error = c(TRUE, FALSE)),
    "Assertion on 'error' failed: Must have length 1"
  )
})

test_that("create_custom_check fails with invalid conditional argument", {
  expect_error(
    create_custom_check("check", conditional = "not_a_logical"),
    "Assertion on 'conditional' failed: Must be of type 'logical'"
  )
  expect_error(
    create_custom_check("check", conditional = c(TRUE, FALSE)),
    "Assertion on 'conditional' failed: Must have length 1"
  )
})

test_that("create_custom_check fails with invalid error_object argument", {
  expect_error(
    create_custom_check("check", error_object = "not_a_logical"),
    "Assertion on 'error_object' failed: Must be of type 'logical'"
  )
})

test_that("create_custom_check fails with invalid extra_args argument", {
  expect_error(
    create_custom_check("check", extra_args = "not_a_logical"),
    "Must be of type 'logical'"
  )
})

test_that("create_custom_check overwrites when file already exists and overwrite is TRUE", {
  # Simulate that file already exists and overwrite is FALSE
  withr::with_tempdir({
    fs::dir_create("src/validations/R/", recurse = TRUE)
    fs::file_create("src/validations/R/check_overwite.R")
    expect_true(
      suppressMessages(
        create_custom_check("check_overwite", overwrite = TRUE)
      )
    )
    expect_snapshot(
      cat(readLines("src/validations/R/check_overwite.R"), sep = "\n")
    )
  })
})

test_that("create_custom_check fails when file already exists and overwrite is FALSE", {
  # Simulate that file already exists and overwrite is FALSE
  withr::with_tempdir({
    fs::dir_create("src/validations/R/", recurse = TRUE)
    fs::file_create("src/validations/R/check_exists.R")
    expect_error(
      create_custom_check("check_exists"),
      "already exists"
    )
  })
})
