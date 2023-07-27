test_that("check_valid_round_id works", {
    hub_path <- system.file("testhubs/simple", package = "hubUtils")
    file_path <- "test/file.csv"

    expect_snapshot(
        check_valid_round_id("2022-10-29",
                             file_path,
                             hub_path)
    )
    expect_snapshot(
        check_valid_round_id("invalid-round_id",
                             file_path,
                             hub_path)
    )
})
